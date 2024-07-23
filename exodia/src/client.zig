const std = @import ("std");

const libcurl = @import ("libcurl");
const mustache = @import ("mustache");

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
  api_version: [] const u8 = "1.25";

  pub fn init (allocator: *const std.mem.Allocator, logger: *Logger, opts: *const Options) !@This ()
  {
    var self: @This () = .{
      .inventory = undefined,
      .allocator = allocator,
      .ca_bundle = try libcurl.allocCABundle (allocator.*),
    };
    self.easy = try libcurl.Easy.init (self.allocator.*, .{ .ca_bundle = self.ca_bundle, });
    try self.addContextVars (logger, opts);
    return self;
  }

  fn deinit (self: *@This ()) void
  {
    self.allocator.free (self.api_version);

    // TODO: put in inventory
    VERSION.deinit ();

    // TODO: put in inventory
    INFO.deinit ();

    self.easy.deinit ();
    self.ca_bundle.deinit ();
  }

  fn addContextVars (self: *@This (), logger: *Logger, opts: *const Options) !void
  {
    var buf: [32] u8 = undefined;
    // TODO: verbose output
    // try easy.setVerbose (true);

    // TODO: use opts here to catch DOCKER_HOST and use it
    try self.easy.setUnixSocketPath ("/var/run/docker.sock");

    var bufZ = try std.fmt.bufPrint (&buf, "http://v{s}/version{c}",
      .{ self.api_version, 0, });
    var resp = try self.easy.get (bufZ [0 .. bufZ.len - 1:0]);
    defer resp.deinit ();

    // TODO: print status code

    if (resp.status_code < 200 or resp.status_code > 299) return error.HttpRequestFailed;

    const parsed = try std.json.parseFromSlice (ApiVersionResponse,
      self.allocator.*, resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer parsed.deinit();

    const body = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });
    defer body.deinit();

    // TODO: make a function to print body with logger:
    // try std.json.stringify (body.value, .{ .whitespace = .indent_2, },
    //   logger.stderr.writer);

    for (0 .. parsed.value.Components.len) |i|
    {
      if (std.mem.eql (u8, parsed.value.Components[i].Name, "Engine"))
      {
        self.api_version = try self.allocator.dupe (u8, parsed.value.Components [i].Details.ApiVersion);
        break;
      }
    }

    bufZ = try std.fmt.bufPrint (&buf, "http://v{s}/version{c}", .{ api_version, 0, });
    resp.deinit ();
    resp = try self.easy.get (bufZ [0 .. bufZ.len - 1:0]);

    // TODO: print status code

    if (resp.status_code < 200 or resp.status_code > 299) return error.HttpRequestFailed;

    // TODO: catch VERSION in self.inventory
    const VERSION = try std.json.parseFromSlice (std.json.Value,
      self.allocator.*, resp.body.?.items, .{ .ignore_unknown_fields = true, });

    // TODO: print body with logger

    bufZ = try std.fmt.bufPrint (&buf, "http://v{s}/info{c}", .{ api_version, 0, });
    resp.deinit ();
    resp = try self.easy.get (bufZ [0 .. bufZ.len - 1:0]);

    // TODO: print status code

    if (resp.status_code < 200 or resp.status_code > 299) return error.HttpRequestFailed;

    // TODO: catch INFO in self.inventory
    const INFO = try std.json.parseFromSlice (std.json.Value, self.allocator.*,
      resp.body.?.items, .{ .ignore_unknown_fields = true, });

    // TODO: print body with logger
  }
};
