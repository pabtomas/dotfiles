const std = @import ("std");

const Unit = struct
{
  pub const logger = @import ("logger.unit.zig");
  pub const options = @import ("options.unit.zig");
  pub const lambdas = @import ("lambdas.unit.zig");
};

comptime
{
  std.testing.refAllDeclsRecursive (Unit);
}
