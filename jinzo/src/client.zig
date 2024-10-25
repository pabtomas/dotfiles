const std = @import ("std");
const libcurl = @import ("libcurl");

const Logger = @import ("logger.zig").Logger;
const Options = @import ("options.zig").Options;

const ApiVersionResponse = struct
{
  Components: [] struct
  {
    Name: [] const u8,
    Details: struct
    {
      ApiVersion: [] const u8 = "",
    },
  },
};

const start = [_] u8 { '*', '<', '>', '{', '}', '{', '}', };

fn debugCallback (_: *libcurl.libcurl.CURL,
  @"type": libcurl.libcurl.curl_infotype, data: [*c] c_char, size: c_uint,
  clientp: *anyopaque) callconv (.C) c_int
{
  const logger: *Logger = @alignCast (@ptrCast (clientp));
  const slice = @as ([*] u8, @ptrCast (data))[0 .. size];

  var buf = std.ArrayList (u8).init (logger.allocator.*);
  defer buf.deinit ();
  var writer = buf.writer ();

  // Keep '\x0D' here: libcurl places weird carriage return in its output
  var any_it = std.mem.tokenizeAny (u8, slice, "\n\x0D");

  while (any_it.next ()) |token|
  {
    if ((@"type" == libcurl.libcurl.CURLINFO_DATA_IN or
         @"type" == libcurl.libcurl.CURLINFO_DATA_OUT or
         @"type" == libcurl.libcurl.CURLINFO_SSL_DATA_IN or
         @"type" == libcurl.libcurl.CURLINFO_SSL_DATA_OUT) and
        std.json.validate (logger.allocator.*, token) catch return 1)
    {
      var parsed = std.json.parseFromSlice (std.json.Value, logger.allocator.*,
        token, .{ .ignore_unknown_fields = true, }) catch return 1;
      defer parsed.deinit ();

      if (std.meta.activeTag (parsed.value) == .array or
        std.meta.activeTag (parsed.value) == .object)
      {
        std.json.stringify (parsed.value, .{ .whitespace = .indent_2, }, writer) catch return 1;
        continue;
      }
    }
    writer.print ("\n{c} {s}\n", .{ start [@"type"], token, }) catch return 1;
  }
  var scalar_it = std.mem.tokenizeScalar (u8, buf.items, '\n');
  while (scalar_it.next ()) |token|
    logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = logger.allocator.dupe (u8, token) catch return 1, .allocated = true, }) catch return 1;
  return 0;
}

pub const Client = struct
{
  inventory: std.json.Value,
  allocator: *const std.mem.Allocator,
  ca_bundle: libcurl.Buffer,
  easy: libcurl.Easy,
  api_version: [] const u8 = "1.25",

  pub fn init (allocator: *const std.mem.Allocator) !@This ()
  {
    var self: @This () = .{
      .inventory = .{ .object = std.json.ObjectMap.init (allocator.*), },
      .allocator = allocator,
      .ca_bundle = try libcurl.allocCABundle (allocator.*),
      .easy      = undefined,
    };
    self.easy = try libcurl.Easy.init (self.allocator.*, .{ .ca_bundle = self.ca_bundle, });
    return self;
  }

  pub fn deinit (self: *@This ()) void
  {
    self.allocator.free (self.api_version);
    @constCast (&self.inventory.object.get ("ENV").?.object).deinit ();
    self.inventory.object.deinit ();
    self.ca_bundle.deinit ();
    self.easy.deinit ();
  }

  pub fn preprocess (self: *@This (), logger: *Logger, opts: *const Options) !void
  {
    try self.addContextVars (logger, opts);

    //client.expandJqIntoInventory ();
    //client.expandJqIntoMain ();
    //client.resolveIncludes ();
    //client.castArraysToObjects ();
    //client.expandExtends ();
    //client.sortTasks ();
  }

  pub fn run (self: *@This (), logger: *Logger, opts: *const Options) void
  {
    _ = self; _ = logger; _ = opts;
    std.debug.print ("TODO", .{});
  }

  fn requestGet (self: @This (), uri: [:0] const u8) !libcurl.Easy.Response
  {
    const resp = try self.easy.get (uri);
    if (resp.status_code < 200 or resp.status_code > 299) return error.HttpRequestFailed;
    return resp;
  }

  fn addContextVars (self: *@This (), logger: *Logger, opts: *const Options) !void
  {
    var url_buf: [32] u8 = undefined;

    try self.easy.setDebugdata (logger);
    try self.easy.setDebugfunction (debugCallback);
    try self.easy.setVerbose (true);

    try self.easy.setUnixSocketPath (opts.getDockerHost ());

    var resp = try self.requestGet (try std.fmt.bufPrintZ (&url_buf, "http://v{s}/version", .{ self.api_version, }));
    defer resp.deinit ();

    const api_version_parsed = try std.json.parseFromSlice (ApiVersionResponse,
      self.allocator.*, resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer api_version_parsed.deinit ();

    for (0 .. api_version_parsed.value.Components.len) |i|
    {
      if (std.mem.eql (u8, api_version_parsed.value.Components [i].Name, "Engine"))
      {
        self.api_version = try self.allocator.dupe (u8, api_version_parsed.value.Components [i].Details.ApiVersion);
        break;
      }
    }

    resp.deinit ();
    resp = try self.requestGet (try std.fmt.bufPrintZ (&url_buf, "http://v{s}/version", .{ self.api_version, }));

    var parsed = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer parsed.deinit ();
    try self.inventory.object.put ("VERSION", parsed.value);

    resp.deinit ();
    resp = try self.requestGet (try std.fmt.bufPrintZ (&url_buf, "http://v{s}/info", .{ self.api_version, }));

    parsed.deinit ();
    parsed = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });
    try self.inventory.object.put ("INFO", parsed.value);

    var env_map = try std.process.getEnvMap (self.allocator.*);
    defer env_map.deinit ();

    var env_value = std.json.Value { .object = std.json.ObjectMap.init (self.allocator.*), };

    var it = env_map.iterator ();
    while (it.next ()) |env_var|
      try env_value.object.put (env_var.key_ptr.*, std.json.Value { .string = env_var.value_ptr.*, });

    try self.inventory.object.put ("ENV", env_value);

    var env_buf = std.ArrayList (u8).init (logger.allocator.*);
    defer env_buf.deinit ();

    try std.json.stringify (env_value, .{ .whitespace = .indent_2, }, env_buf.writer ());

    try logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = "ENV map:", .allocated = false, });

    var scalar_it = std.mem.tokenizeScalar (u8, env_buf.items, '\n');
    while (scalar_it.next ()) |token|
      try logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = try self.allocator.dupe (u8, token), .allocated = true, });

    try logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = "Preprocessing: Context defined", .allocated = false, });
  }

  fn expandJqIntoInventory (self: @This ()) void
  {
    // TODO: write_datasources_header
    // TODO: expand_datasources_into_datasources
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn expandJqIntoMain (self: @This ()) void
  {
    // TODO: expand_datasources_into_main
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn resolveIncludes (self: @This ()) void
  {
    // TODO: resolve_includes
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn castArraysToObjects (self: @This ()) void
  {
    // TODO: convert_to_objects
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn expandExtends (self: @This ()) void
  {
    // TODO: expand_extends
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn sortTasks (self: @This ()) void
  {
    // TODO: topological_sort
    _ = self;
    std.debug.print ("TODO", .{});
  }
};
