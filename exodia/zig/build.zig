const std = @import ("std");

var ansiterm: *std.Build.Module = undefined;
var datetime: *std.Build.Module = undefined;
var jdz: *std.Build.Module = undefined;
var termsize: *std.Build.Module = undefined;

fn loggerModule (builder: *std.Build, target: *const std.Build.ResolvedTarget,
  optimize: *const std.builtin.OptimizeMode) !*std.Build.Module
{
  const index_submodule = builder.createModule (.{
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "logger", "index.zig", }), },
    .target = target.*,
    .optimize = optimize.*,
  });

  var logger_module: *std.Build.Module = undefined;

  for ([_][] const u8 { "bar", "color", "log", "logger", "queue", "request", "spin", }) |submodule_name|
  {
    const submodule = builder.createModule (.{
      .root_source_file = .{ .cwd_relative = try builder.build_root.join (
        builder.allocator, &.{ "src", "logger", try std.fmt.allocPrint (builder.allocator, "{s}.zig", .{ submodule_name, }) }), },
      .target = target.*,
      .optimize = optimize.*,
    });

    index_submodule.addImport (submodule_name, submodule);
    submodule.addImport ("index", index_submodule);

    if (std.mem.eql (u8, submodule_name, "logger")) logger_module = submodule;
  }

  index_submodule.addImport ("ansiterm", ansiterm);
  index_submodule.addImport ("termsize", termsize);
  index_submodule.addImport ("datetime", datetime);
  index_submodule.addImport ("jdz", jdz);

  return logger_module;
}

fn import (step: *std.Build.Step.Compile, logger: *std.Build.Module, options: *std.Build.Module) void
{
  step.root_module.addImport ("datetime", datetime);
  step.root_module.addImport ("jdz", jdz);
  step.root_module.addImport ("logger", logger);
  step.root_module.addImport ("options", options);
}

fn module (builder: *std.Build, target: *const std.Build.ResolvedTarget,
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

  ansiterm = module (builder, &target, &optimize, "ansi-term");
  termsize = module (builder, &target, &optimize, "termsize");
  datetime = module (builder, &target, &optimize, "zig-datetime");
  jdz = module (builder, &target, &optimize, "jdz_allocator");

  const logger = try loggerModule (builder, &target, &optimize);
  const options = builder.createModule (.{
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "options.zig", }), },
    .target = target,
    .optimize = optimize,
  });
  options.addImport ("logger", logger);

  const exodia = builder.addExecutable (.{
    .name = "exodia",
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  import (exodia, logger, options);

  const unit_tests = builder.addTest (.{
    .target = target,
    .optimize = optimize,
    .test_runner = .{ .cwd_relative = try builder.build_root.join (builder.allocator,
      &.{ "test", "runner.zig", }), },
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
  });
  unit_tests.step.dependOn (builder.getInstallStep ());

  const run_unit_tests = builder.addRunArtifact (unit_tests);
  if (builder.args) |args| for (args) |arg| run_unit_tests.addArg (builder.dupe (arg));

  const test_step = builder.step ("test", "Run tests");
  test_step.dependOn (&run_unit_tests.step);

  import (unit_tests, logger, options);

  builder.installArtifact (exodia);
}
