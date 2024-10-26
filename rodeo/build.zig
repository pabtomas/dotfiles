const std = @import ("std");

var ansiterm: *std.Build.Module = undefined;
var datetime: *std.Build.Module = undefined;
var jdz: *std.Build.Module = undefined;
var libcurl: *std.Build.Module = undefined;
var termsize: *std.Build.Module = undefined;
var libjq: *std.Build.Module = undefined;

fn import (module: *std.Build.Module) void
{
  module.addImport ("ansiterm", ansiterm);
  module.addImport ("datetime", datetime);
  module.addImport ("jdz", jdz);
  module.addImport ("libcurl", libcurl);
  module.addImport ("termsize", termsize);
  module.addImport ("libjq", libjq);
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
  datetime = getModule (builder, &target, &optimize, "zig-datetime");
  jdz = getModule (builder, &target, &optimize, "jdz_allocator");
  libcurl = getModule (builder, &target, &optimize, "curl");
  termsize = getModule (builder, &target, &optimize, "termsize");

  libjq = builder.createModule (.{
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (builder.allocator,
      &.{ "src", "bindings", "libjq", "libjq.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  libjq.linkLibrary (builder.dependency ("libjq.zig", .{
    .target = target,
    .optimize = optimize,
  }).artifact ("jq"));

  const rodeo = builder.addExecutable (.{
    .name = "rodeo",
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "rodeo", "main.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  import (&rodeo.root_module);

  const leak_tests = builder.addTest (.{
    .target = target,
    .optimize = optimize,
    .test_runner = .{ .cwd_relative = try builder.build_root.join (builder.allocator,
      &.{ "src", "rodeo", "runner.zig", }), },
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "rodeo", "main.zig", }), },
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
      builder.allocator, &.{ "src", "rodeo", "unit.index.zig", }), },
  });
  import (unit_module);

  const unit_tests = builder.addTest (.{
    .target = target,
    .optimize = optimize,
    .test_runner = .{ .cwd_relative = try builder.build_root.join (builder.allocator,
      &.{ "src", "rodeo", "runner.zig", }), },
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "rodeo", "unit.zig", }), },
  });
  unit_tests.linkLibC ();
  import (&unit_tests.root_module);

  unit_tests.step.dependOn (builder.getInstallStep ());

  const run_unit_tests = builder.addRunArtifact (unit_tests);

  const unit_step = builder.step ("unit", "Run unit tests");
  unit_step.dependOn (&run_unit_tests.step);

  unit_tests.root_module.addImport ("index", unit_module);

  builder.installArtifact (rodeo);
}
