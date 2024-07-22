const std = @import ("std");

const logger_zig = @import ("logger.zig");
pub const Logger = logger_zig.Logger;
pub const Stream = logger_zig.Stream;

pub const Options = @import ("options.zig").Options;

pub fn prepare (logger: *Logger, stderr: *Stream, allocator: *const std.mem.Allocator) !void
{
  stderr.* = .{
    .cols   = null,
    .buffer = std.io.bufferedWriter (std.io.getStdErr ().writer ()),
    .writer = undefined,
  };
  stderr.writer = stderr.buffer.writer ();
  logger.* = try Logger.init (1, allocator, stderr);
}
