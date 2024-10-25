const std = @import ("std");

const index = @import ("index");
const prepare = index.prepare;
const Logger = index.Logger;
const Stream = index.Stream;

test "enqueue: 1 Request"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "An error message", .allocated = false, });

  try std.testing.expectEqual (1, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "enqueue: 3 Requests"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "An error message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .INFO, }, .data = "An info message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = "A debug message", .allocated = false, });

  try std.testing.expectEqual (3, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "call: std.mem.count"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  const count = try logger.call (&[_][] const u8 { "std", "mem", "count", }, .{ u8, "count me please", "e", }, @src ());

  try std.testing.expectEqual (3, count);

  try std.testing.expectEqual (1, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "enqueueObject: Stream (with .VERB log_level)"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  logger.setLogLevel (.VERB);
  try logger.enqueueObject (@TypeOf (stderr), &stderr, "stderr");

  try std.testing.expectEqual (3, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.VERB, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "enqueueObject: Stream (without .VERB log_level)"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueueObject (@TypeOf (stderr), &stderr, "stderr");

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 1 logRequest (.ERROR)"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "An error message", .allocated = false, });

  try std.testing.expectEqual (1, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 3 logRequests (.ERROR, .INFO, .DEBUG)"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "An error message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .INFO, }, .data = "An info message", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .log = .DEBUG, }, .data = "A debug message", .allocated = false, });

  try std.testing.expectEqual (3, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 1 spinRequest"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .spin = "test", }, .data = "Testing ...", .allocated = false, });

  try std.testing.expectEqual (1, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (!try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (1, logger.spins.count ());
  try std.testing.expectEqual (1, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 3 spinRequests"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .spin = "test", }, .data = "Testing ...", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .spin = "test2", }, .data = "Testing ...", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .spin = "test3", }, .data = "Testing ...", .allocated = false, });

  try std.testing.expectEqual (3, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (!try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (3, logger.spins.count ());
  try std.testing.expectEqual (3, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 1 spinRequest & 1 killRequest"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .spin = "test", }, .data = "Testing ...", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .kill = "test", }, .data = null, .allocated = false, });

  try std.testing.expectEqual (2, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (!try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 3 spinRequests & 2 killRequests"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .spin = "test", }, .data = "Testing ...", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .spin = "test2", }, .data = "Testing ...", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .spin = "test3", }, .data = "Testing ...", .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .kill = "test2", }, .data = null, .allocated = false, });
  try logger.enqueue (.{ .kind = .{ .kill = "test3", }, .data = null, .allocated = false, });

  try std.testing.expectEqual (5, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (!try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (1, logger.spins.count ());
  try std.testing.expectEqual (1, logger.nodes.len);
  try std.testing.expect (logger.spins.get ("test") != null);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);
}

test "dequeue: 1 barRequest"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .bar = 5, }, .data = null, .allocated = false, });

  try std.testing.expectEqual (1, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (!try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (logger.bar.running);
}

test "dequeue: 1 barRequest (max: 5) & 2 ProgressRequests"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
  defer logger.deinit ();

  try logger.enqueue (.{ .kind = .{ .bar = 5, }, .data = null, .allocated = false, });
  for (0 .. 2) |_|
    try logger.enqueue (.{ .kind = .{ .progress = {}, }, .data = null, .allocated = false, });

  try std.testing.expectEqual (3, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (!logger.bar.running);

  try std.testing.expect (!try logger.dequeue ());

  try std.testing.expectEqual (0, logger.requests.list.len);
  try std.testing.expectEqual (0, logger.spins.count ());
  try std.testing.expectEqual (0, logger.nodes.len);
  try std.testing.expectEqual (.INFO, logger.log_level);
  try std.testing.expect (logger.bar.running);
}
