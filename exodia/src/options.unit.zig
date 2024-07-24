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

test "parse: exodia"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", });
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

test "parse: exodia -v -q"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-v", "-q", });
  try std.testing.expectError (error.UncompatibleOpts, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: exodia -qv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-qv", });
  try std.testing.expectError (error.UncompatibleOpts, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: exodia -vv -vv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-vv", "-vv", });
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

test "parse: exodia -vvvv --verbose --verbose"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-vvvv", "--verbose", "--verbose", });
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

test "parse: exodia --quiet -qqq"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "--quiet", "-qqq", });
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

test "parse: exodia --verbose --verbose -hVv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "--verbose", "--verbose", "-hVv", });
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

test "parse: exodia --version --version --help -hVhVhV"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "--version", "--version", "--help", "-hVhVhV", });
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

test "parse: exodia -vfqvvvhVv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-vfqvvvhVv", });
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

test "parse: exodia -hhhfhhh -fvqvqvqvvvq --file=awesome.zon"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-hhhfhhr", "-fvqvqvqvvvq", "--file=awesome.zon", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqualStrings ("awesome.zon", opts.file.?);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: exodia --unknown-opt"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "--unknown-opt", });
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

test "parse: exodia -f"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-f", });
  try std.testing.expectError (error.MissingArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: exodia --file="
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "--file=", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: exodia -f ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "-f", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: exodia ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "exodia", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}
