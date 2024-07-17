const std = @import ("std");

const datetime = @import ("datetime").datetime;
const jdz = @import ("jdz");
const JdzGlobalAllocator = jdz.JdzGlobalAllocator (.{});

const Logger = @import ("logger").Logger;

fn mainHandled (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = .{ .message = "Test", }, });
  try logger.enqueue (.{ .kind = .{ .log = .WARN, }, .data = .{ .message = "Test", }, });
  //try logger.enqueueTrace (&[_][] const u8 { "std", "debug", "print", }, .{ "{s}\n", .{ "Test", } });
  //try logger.enqueue (.{ .kind = .{ .spin = "cache", }, .data = .{ .message = "In progress ...", }, });
  //std.time.sleep (1_000_000_000);
  //try logger.enqueue (.{ .kind = .{ .kill = "cache", }, });

  //var looping = true;
  //while (looping)
  //{
  //}
}

fn mainWith (allocator: *const std.mem.Allocator) !void
{
  const nproc = try std.Thread.getCpuCount ();
  var logger = try Logger.init (@intCast (nproc), allocator);

  const thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });
  defer {
    logger.deinit ();
    thread.join ();
  }

  mainHandled (&logger) catch |err|
    try logger.enqueue (.{ .kind = .{ .log = .ERROR, },
                           .data = .{ .message = @errorName (err), }, });
}

fn fatal (err: [] const u8) void
{
  const now = datetime.Datetime.now ();
  std.debug.print ("{d:0>2}:{d:0>2}:{d:0>2} \x1B[38;5;215m\x1B[1mFATAL\x1B[m {s}\n",
    .{ now.time.hour, now.time.minute, now.time.second, err, });
}

pub fn main () void
{
  const allocator = JdzGlobalAllocator.allocator ();
  defer JdzGlobalAllocator.deinit ();
  mainWith (&allocator) catch |err| fatal (@errorName (err));
}

test "leak"
{
  const allocator = std.testing.allocator;
  try mainWith (&allocator);
}
