const std = @import ("std");

const logger_zig = @import ("logger.zig");
pub const Logger = logger_zig.Logger;
pub const Stream = logger_zig.Stream;

pub const Options = @import ("options.zig").Options;

fn write (context: std.fs.File, data: [] const u8) !usize
{
    _ = context;
    return data.len;
}

pub fn prepare (logger: *Logger, stderr: *Stream, allocator: *const std.mem.Allocator) !void
{
  stderr.* = .{
    .cols   = null,
    .buffer = std.io.bufferedWriter ((try std.fs.openFileAbsolute ("/dev/null", .{ .mode = .write_only, })).writer ()),
    .writer = undefined,
  };
  stderr.writer = stderr.buffer.writer ();
  logger.* = try Logger.init (8, allocator, stderr);
}
