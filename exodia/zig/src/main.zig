const std = @import ("std");

const datetime = @import ("datetime").datetime;
const jdz = @import ("jdz");
const JdzGlobalAllocator = jdz.JdzGlobalAllocator (.{});

const Logger = @import ("logger").Logger;
const StdErr = @import ("logger").StdErr;

fn mainHandled (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "A error message", });
  try logger.enqueue (.{ .kind = .{ .log = .WARN, }, .data = "A warning message", });
  try logger.enqueue (.{ .kind = .{ .log = .RAW, }, .data = "A raw message", });
  try logger.enqueue (.{ .kind = .{ .log = .INFO, }, .data = "A very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very long info message", });
  try logger.enqueueTrace (&[_][] const u8 { "std", "debug", "print", }, .{ "{s}\n", .{ "Test", } }, @src ());
  try logger.enqueue (.{ .kind = .{ .spin = "cache", }, .data = "In progress ...", });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .spin = "cache2", }, .data = "In progress again ...", });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .spin = "cache3", }, .data = "In progress again & again ...", });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache", }, .data = null, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache3", }, .data = null, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache2", }, .data = null, });
  try logger.enqueue (.{ .kind = .{ .bar = 10, }, .data = null, });
  var xoshiro = std.rand.DefaultPrng.init (0);
  var rand = xoshiro.random ();
  for (0 .. 10) |_| {
    std.time.sleep (100_000_000 * (rand.uintAtMost (u32, 8) + 1));
    try logger.enqueue (.{ .kind = .{ .progress = {}, }, .data = null, });
  }
}

fn mainWith (allocator: *const std.mem.Allocator) !void
{
  const nproc = try std.Thread.getCpuCount ();
  var stderr: StdErr = .{
    .buffer = std.io.bufferedWriter (std.io.getStdErr ().writer ()),
    .writer = undefined,
  };
  stderr.writer = stderr.buffer.writer ();
  var logger = try Logger.init (@intCast (nproc), allocator, &stderr);

  // TODO: parse options

  var tasks: std.Thread.WaitGroup = .{};
  tasks.reset ();

  var pool: std.Thread.Pool = undefined;
  try pool.init (std.Thread.Pool.Options {
    .allocator = allocator.*,
    .n_jobs = @intCast (nproc),
  });
  // pool.spawnWg (&tasks, Httpfunction, .{ arg1, arg2, });

  const logger_thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });
  defer {
    logger.deinit ();
    pool.waitAndWork (&tasks);
    logger_thread.join ();
    pool.deinit ();
  }

  mainHandled (&logger) catch |err|
    try logger.enqueue (.{ .kind = .{ .log = .ERROR, },
                           .data = @errorName (err), });
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
