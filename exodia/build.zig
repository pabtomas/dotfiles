const std = @import ("std");

var ansiterm: *std.Build.Module = undefined;
var datetime: *std.Build.Module = undefined;
var jdz: *std.Build.Module = undefined;
var termsize: *std.Build.Module = undefined;

fn import (module: *std.Build.Module) void
{
  module.addImport ("ansiterm", ansiterm);
  module.addImport ("datetime", datetime);
  module.addImport ("jdz", jdz);
  module.addImport ("termsize", termsize);
}

fn getModule (builder: *std.Build, target: *const std.Build.ResolvedTarget,
  optimize: *const std.builtin.OptimizeMode, name: [] const u8) *std.Build.Module
{
  return builder.dependency (name, .{
    .target = target.*,
    .optimize = optimize.*,
  }).module (name);
}

pub fn build (builder: *std.Build) !void
{
  const target = builder.standardTargetOptions (.{});
  const optimize = std.builtin.OptimizeMode.Debug;

  ansiterm = getModule (builder, &target, &optimize, "ansi-term");
  termsize = getModule (builder, &target, &optimize, "termsize");
  datetime = getModule (builder, &target, &optimize, "zig-datetime");
  jdz = getModule (builder, &target, &optimize, "jdz_allocator");

  const exodia = builder.addExecutable (.{
    .name = "exodia",
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  import (&exodia.root_module);

  const leak_tests = builder.addTest (.{
    .target = target,
    .optimize = optimize,
    .test_runner = .{ .cwd_relative = try builder.build_root.join (builder.allocator,
      &.{ "src", "runner.zig", }), },
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
  });
  leak_tests.step.dependOn (builder.getInstallStep ());

  const run_leak_tests = builder.addRunArtifact (leak_tests);
  if (builder.args) |args| for (args) |arg| run_leak_tests.addArg (builder.dupe (arg));

  const leak_step = builder.step ("leak", "Run memory checker");
  leak_step.dependOn (&run_leak_tests.step);

  import (&leak_tests.root_module);

  const unit_module = builder.createModule (.{
    .target = target,
    .optimize = optimize,
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "unit.index.zig", }), },
  });
  import (unit_module);

  const unit_tests = builder.addTest (.{
    .target = target,
    .optimize = optimize,
    .test_runner = .{ .cwd_relative = try builder.build_root.join (builder.allocator,
      &.{ "src", "runner.zig", }), },
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "unit.zig", }), },
  });
  unit_tests.step.dependOn (builder.getInstallStep ());

  const run_unit_tests = builder.addRunArtifact (unit_tests);

  const unit_step = builder.step ("unit", "Run unit tests");
  unit_step.dependOn (&run_unit_tests.step);

  unit_tests.root_module.addImport ("index", unit_module);

  builder.installArtifact (exodia);
}
