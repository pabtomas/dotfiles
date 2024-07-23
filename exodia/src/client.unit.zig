const std = @import ("std");

test "client"
{
  const allocator = std.testing.allocator;

  var client = http.Client { .allocator = allocator };
  defer client.deinit ();

  const uri = try std.Uri.parse ("/var/run/docker.sock");
    const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
    defer allocator.free(buf);
    var req = try client.open(.GET, uri, .{
        .server_header_buffer = buf,
    });
    defer req.deinit();
}
