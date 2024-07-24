const std = @import ("std");

const datetime = @import ("datetime").datetime;
const jdz = @import ("jdz");
const JdzGlobalAllocator = jdz.JdzGlobalAllocator (.{});

const logger_zig = @import ("logger.zig");
const Logger = logger_zig.Logger;
const Stream = logger_zig.Stream;
const Options = @import ("options.zig").Options;
const Client = @import ("client.zig").Client;

fn help (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .RAW, }, .data = "HELP: TODO", .allocated = false, });
}

fn version (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .RAW, }, .data = "VERSION: TODO", .allocated = false, });
}

// TODO: use logger.call

fn preprocess (allocator: *const std.mem.Allocator, logger: *Logger, opts: *const Options) !void
{
  try logger.enqueueObject (@TypeOf (opts.*), opts, "opts");
  try logger.enqueueObject (@TypeOf (logger.*), logger, "logger");

  var tasks: std.Thread.WaitGroup = .{};
  tasks.reset ();

  var pool: std.Thread.Pool = undefined;
  try pool.init (std.Thread.Pool.Options {
    .allocator = allocator.*,
    .n_jobs = @intCast (logger.nproc),
  });
  // pool.spawnWg (&tasks, Httpfunction, .{ arg1, arg2, });

  defer {
    pool.waitAndWork (&tasks);
    pool.deinit ();
  }

  var client = try Client.init (allocator);
  defer client.deinit ();

  try client.preprocess (logger, opts);

  if (opts.help) try help (logger);
  if (opts.version) try version (logger);
  if (opts.help or opts.version) return;

  client.run (logger, opts);

  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "An error message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .WARN, }, .data = "A warning message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .RAW, }, .data = "A raw message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .INFO, }, .data = "A very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very long info message", .allocated = false, });
  try logger.call (&[_][] const u8 { "std", "debug", "print", }, .{ "{s}\n", .{ "Test", } }, @src ());
  try logger.enqueue (.{ .kind = .{ .spin = "cache", }, .data = "In progress ...", .allocated = false, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .spin = "cache2", }, .data = "In progress again ...", .allocated = false, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .spin = "cache3", }, .data = "In progress again & again ...", .allocated = false, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache", }, .data = null, .allocated = false, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache3", }, .data = null, .allocated = false, });
  std.time.sleep (1_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache2", }, .data = null, .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .bar = 10, }, .data = null, .allocated = false, });
  var xoshiro = std.rand.DefaultPrng.init (0);
  var rand = xoshiro.random ();
  for (0 .. 10) |_| {
    std.time.sleep (100_000_000 * (rand.uintAtMost (u32, 8) + 1));
    try logger.enqueue (.{ .kind = .{ .progress = {}, }, .data = null, .allocated = false, });
  }
}

fn prepare (allocator: *const std.mem.Allocator) !void
{
  var stderr: Stream = .{
    .cols   = if (std.io.getStdErr ().supportsAnsiEscapeCodes ()) 0 else null,
    .buffer = std.io.bufferedWriter (std.io.getStdErr ().writer ()),
    .writer = undefined,
  };
  stderr.writer = stderr.buffer.writer ();
  var logger = try Logger.init (try std.Thread.getCpuCount (),
    allocator, &stderr);

  var args = try std.process.argsWithAllocator (allocator.*);
  const opts = Options.parse (allocator, &args, &logger) catch |err| blk: {
    switch (err)
    {
      error.MissingArg, error.EmptyArg, error.UncompatibleOpts => {
        break :blk err;
      },
      else => return err,
    }
  };
  logger.setLogLevel ((try opts).log_level);

  const logger_thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });

  defer {
    args.deinit ();
    logger.stop ();
    logger_thread.join ();
  }

  if (!std.meta.isError (opts))
    preprocess (allocator, &logger, &(try opts)) catch |err|
    {
      try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = @errorName (err), .allocated = false, });
      if (@errorReturnTrace ()) |trace| std.debug.dumpStackTrace (trace.*);
    };
}

fn fatal (err: [] const u8) void
{
  const now = datetime.Datetime.now ();
  std.debug.print ("{d:0>2}:{d:0>2}:{d:0>2} \x1B[38;5;215m\x1B[1mFATAL\x1B[m {s}\n",
    .{ now.time.hour, now.time.minute, now.time.second, err, });
  if (@errorReturnTrace ()) |trace| std.debug.dumpStackTrace (trace.*);
}

pub fn main () void
{
  const allocator = JdzGlobalAllocator.allocator ();
  defer JdzGlobalAllocator.deinit ();
  prepare (&allocator) catch |err| fatal (@errorName (err));
}

test "leak"
{
  const allocator = std.testing.allocator;
  try prepare (&allocator);
}
