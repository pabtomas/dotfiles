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

test "parse: mana"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana -v -q"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-v", "-q", });
  try std.testing.expectError (error.UncompatibleOpts, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana -qv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-qv", });
  try std.testing.expectError (error.UncompatibleOpts, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana -vv -vv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-vv", "-vv", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.VERB, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana -vvvv --verbose --verbose"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-vvvv", "--verbose", "--verbose", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (opts.incr_warning);
  try std.testing.expectEqual (.VERB, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana --quiet -qqq"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--quiet", "-qqq", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.ERROR, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana --verbose --verbose -hVv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--verbose", "--verbose", "-hVv", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.TRACE, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana --version --version --help -hVhVhVM first.jq"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--version", "--version", "--help", "-hVhVhV", "-M", "first.jq" });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (1, opts.modules.items.len);
  try std.testing.expectEqualStrings ("first.jq", opts.modules.items [0]);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana --module=--version -M --module --module first.jq"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--module=--version", "-M", "--module", "--module", "first.jq", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (3, opts.modules.items.len);
  try std.testing.expectEqualStrings ("--version", opts.modules.items [0]);
  try std.testing.expectEqualStrings ("--module", opts.modules.items [1]);
  try std.testing.expectEqualStrings ("first.jq", opts.modules.items [2]);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana -vfqvvvhVv"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-vfqvvvhVv", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.NOTE, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqualStrings ("qvvvhVv", opts.file.?);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana -hhhfhhh -fvqvqvqvvvq --file=awesome.json"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-hhhfhhr", "-fvqvqvqvvvq", "--file=awesome.json", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (0, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqualStrings ("awesome.json", opts.file.?);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana --unknown-opt"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--unknown-opt", });
  var opts = try Options.parse (&allocator, &it, &logger);
  defer opts.deinit ();
  logger.deinit ();
  try std.testing.expect (!opts.help);
  try std.testing.expect (!opts.version);
  try std.testing.expect (!opts.incr_warning);
  try std.testing.expectEqual (.INFO, opts.log_level);
  try std.testing.expectEqual (1, opts.rules.len);
  try std.testing.expectEqual (0, opts.modules.items.len);
  try std.testing.expectEqual (null, opts.file);
  try std.testing.expectEqual (null, opts.docker_host);
}

test "parse: mana -f"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-f", });
  try std.testing.expectError (error.MissingArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana --file="
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--file=", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana -f ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-f", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana -M"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-M", });
  try std.testing.expectError (error.MissingArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana --module="
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "--module=", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana -M ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "-M", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}

test "parse: mana ''"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);

  var it = ArgIterator.init (&[_][:0] const u8 { "mana", "", });
  try std.testing.expectError (error.EmptyArg, Options.parse (&allocator, &it, &logger));
  logger.deinit ();
}
