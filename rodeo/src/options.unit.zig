const std = @import ("std");

const index = @import ("index");
const prepare = index.prepare;
const Logger = index.Logger;
const Stream = index.Stream;
const Options = index.Options;

const ArgIterator = struct
{
  sequence: [] const [:0] const u8,
  index: usize = 0,

  pub fn init (items: [] const [:0] const u8) @This ()
  {
    return .{ .sequence = items, };
  }

  pub fn next (self: *@This()) ?[:0] const u8
  {
    if (self.index >= self.sequence.len) return null;
    const result = self.sequence [self.index];
    self.index = self.index + 1;
    return result;
  }
};

test "parse: rodeo"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo -v -q"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-v", "-q", });
  try std.testing.expectError (error.UncompatibleOpts, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: rodeo -qv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-qv", });
  try std.testing.expectError (error.UncompatibleOpts, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: rodeo -vv -vv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-vv", "-vv", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.VERB, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo -vvvv --verbose --verbose"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-vvvv", "--verbose", "--verbose", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (opts.incr_warning);
  try std.testing.expectEqual (.VERB, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo --quiet -qqq"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "--quiet", "-qqq", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.ERROR, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo --verbose --verbose -hVv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "--verbose", "--verbose", "-hVv", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.TRACE, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo --version --version --help -hVhVhV"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "--version", "--version", "--help", "-hVhVhV", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo -vfqvvvhVv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-vfqvvvhVv", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.NOTE, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqualStrings ("qvvvhVv", opts.file.?);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo -hhhfhhh -fvqvqvqvvvq --file=awesome.json"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-hhhfhhr", "-fvqvqvqvvvq", "--file=awesome.json", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqualStrings ("awesome.json", opts.file.?);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo --unknown-opt"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "--unknown-opt", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (1, opts.rules.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: rodeo -f"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-f", });
  try std.testing.expectError (error.MissingArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: rodeo --file="
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "--file=", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: rodeo -f ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "-f", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: rodeo ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "rodeo", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}
