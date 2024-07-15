const std = @import ("std");

pub fn build (builder: *std.Build) !void
{
  const target = builder.standardTargetOptions (.{});
  const optimize = std.builtin.OptimizeMode.Debug;

  const logger = builder.addExecutable (.{
    .name = "exodia-logger",
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  const ansiterm = builder.dependency ("ansi-term", .{
    .target = target,
    .optimize = optimize,
  }).module ("ansi-term");

  const termsize = builder.dependency ("termsize", .{
    .target = target,
    .optimize = optimize,
  }).module ("termsize");

  const datetime = builder.dependency ("zig-datetime", .{
    .target = target,
    .optimize = optimize,
  }).module ("zig-datetime");

  const jdz_allocator = builder.dependency ("jdz_allocator", .{
    .target = target,
    .optimize = optimize,
  }).module ("jdz_allocator");

  logger.root_module.addImport ("ansiterm", ansiterm);
  logger.root_module.addImport ("termsize", termsize);
  logger.root_module.addImport ("datetime", datetime);
  logger.root_module.addImport ("jdz", jdz_allocator);

  const unit_tests = builder.addTest (.{
    .target = target,
    .optimize = optimize,
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
  });
  unit_tests.step.dependOn (builder.getInstallStep ());

  const run_unit_tests = builder.addRunArtifact (unit_tests);

  const test_step = builder.step ("test", "Run tests");
  test_step.dependOn (&run_unit_tests.step);

  unit_tests.root_module.addImport ("ansiterm", ansiterm);
  unit_tests.root_module.addImport ("termsize", termsize);
  unit_tests.root_module.addImport ("datetime", datetime);
  unit_tests.root_module.addImport ("jdz", jdz_allocator);

  builder.installArtifact (logger);
}
