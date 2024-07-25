const std = @import ("std");

const logger_zig = @import ("logger.zig");
pub const Logger = logger_zig.Logger;
pub const Stream = logger_zig.Stream;

pub const Options = @import ("options.zig").Options;

pub const Lambdas = @import ("lambdas.zig").Lambdas;

pub fn prepare (logger: *Logger, stderr: *Stream, allocator: *const std.mem.Allocator) !void
{
  const devnull = try std.fs.openFileAbsolute ("/dev/null", .{ .mode = .write_only, });
  stderr.* = .{
    .cols   = null,
    .buffer = std.io.bufferedWriter (devnull.writer ()),
    .writer = undefined,
  };
  stderr.writer = stderr.buffer.writer ();
  logger.* = try Logger.init (8, allocator, stderr);
}
