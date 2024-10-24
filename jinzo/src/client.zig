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
    self.inventory.object.deinit ();
    self.ca_bundle.deinit ();
    self.easy.deinit ();
  }

  pub fn preprocess (self: *@This (), logger: *Logger, opts: *const Options) !void
  {
    try self.addContextVars (logger, opts);

    //client.buildGenerics ()
    //client.expandTemplatesIntoInv ();
    //client.expandTemplatesIntoMain ();
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

  fn requestGet (self: @This (), uri: [:0] const u8, logger: *Logger) !libcurl.Easy.Response
  {
    const resp = try self.easy.get (uri);
    try logger.enqueue (.{ .kind = .{ .log = .VERB, }, .data = try std.fmt.allocPrint (self.allocator.*, "HTTP {d}", .{ resp.status_code, }), .allocated = true, });
    if (resp.status_code < 200 or resp.status_code > 299) return error.HttpRequestFailed;
    return resp;
  }

  fn printResponseBody (self: @This (), value: *const std.json.Value, logger: *Logger) !void
  {
    var buf = std.ArrayList (u8).init (self.allocator.*);
    defer buf.deinit ();

    try std.json.stringify (value.*, .{ .whitespace = .indent_2, }, buf.writer ());

    var it = std.mem.tokenizeScalar (u8, buf.items, '\n');
    while (it.next ()) |entry|
      try logger.enqueue (.{ .kind = .{ .log = .VERB, }, .data = try self.allocator.dupe (u8, entry), .allocated = true, });
  }

  fn addContextVars (self: *@This (), logger: *Logger, opts: *const Options) !void
  {
    var buf: [32] u8 = undefined;

    // TODO: verbose output
    // try self.easy.setVerbose (true);

    try self.easy.setUnixSocketPath (opts.getDockerHost ());

    var resp = try self.requestGet (try std.fmt.bufPrintZ (&buf, "http://v{s}/version", .{ self.api_version, }), logger);
    defer resp.deinit ();

    const api_version_parsed = try std.json.parseFromSlice (ApiVersionResponse,
      self.allocator.*, resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer api_version_parsed.deinit ();

    const body = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer body.deinit ();

    try self.printResponseBody (&body.value, logger);

    for (0 .. api_version_parsed.value.Components.len) |i|
    {
      if (std.mem.eql (u8, api_version_parsed.value.Components [i].Name, "Engine"))
      {
        self.api_version = try self.allocator.dupe (u8, api_version_parsed.value.Components [i].Details.ApiVersion);
        break;
      }
    }

    resp.deinit ();
    resp = try self.requestGet (try std.fmt.bufPrintZ (&buf, "http://v{s}/version", .{ self.api_version, }), logger);

    var parsed = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer parsed.deinit ();
    try self.inventory.object.put ("VERSION", parsed.value);

    try self.printResponseBody (self.inventory.object.getPtr ("VERSION").?, logger);

    resp.deinit ();
    resp = try self.requestGet (try std.fmt.bufPrintZ (&buf, "http://v{s}/info", .{ self.api_version, }), logger);

    parsed.deinit ();
    parsed = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });
    try self.inventory.object.put ("INFO", parsed.value);

    try self.printResponseBody (self.inventory.object.getPtr ("INFO").?, logger);

    try logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = "Preprocessing: Context defined", .allocated = false, });
  }

  fn buildGenerics (self: @This ()) void
  {
    // TODO: search generics into jinzo.json and build a struct for generic lambda ??
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn expandTemplatesIntoInv (self: @This ()) void
  {
    // TODO: write_datasources_header
    // TODO: expand_datasources_into_datasources
    _ = self;
    std.debug.print ("TODO", .{});
  }

  fn expandTemplatesIntoMain (self: @This ()) void
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
