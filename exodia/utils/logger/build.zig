const std = @import ("std");

pub fn build (builder: *std.Build) void
{
  const target = builder.standardTargetOptions (.{});
  const optimize = std.builtin.OptimizeMode.Debug;
  //const optimize = std.builtin.OptimizeMode.ReleaseFast;

  const logger = builder.addExecutable (.{
    .name = "exodia-logger",
    .root_source_file = builder.path ("src/main.zig"),
    .target = target,
    .optimize = optimize,
  });

  const termsize = builder.dependency ("termsize", .{
    .target = target,
    .optimize = optimize,
  }).module ("termsize");

  const datetime = builder.dependency ("zig-datetime", .{
    .target = target,
    .optimize = optimize,
  }).module ("zig-datetime");

  logger.root_module.addImport ("termsize", termsize);
  logger.root_module.addImport ("datetime", datetime);

  builder.installArtifact (logger);
}
