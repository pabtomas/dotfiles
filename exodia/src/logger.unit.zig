const std = @import ("std");

const index = @import ("index");
const prepare = index.prepare;
const Logger = index.Logger;
const Stream = index.Stream;

test "unit:TODO"
{
  const allocator = std.testing.allocator;
  var stderr: Stream = undefined;
  var logger: Logger = undefined;
  try prepare (&logger, &stderr, &allocator);
}
