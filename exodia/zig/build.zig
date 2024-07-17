const std = @import ("std");

var ansiterm: *std.Build.Module = undefined;
var datetime: *std.Build.Module = undefined;
var jdz_allocator: *std.Build.Module = undefined;
var termsize: *std.Build.Module = undefined;

fn loggerModule (builder: *std.Build, target: *const std.Build.ResolvedTarget,
  optimize: *const std.builtin.OptimizeMode) !*std.Build.Module
{
  const index_module = builder.createModule (.{
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "logger", "index.zig", }), },
    .target = target.*,
    .optimize = optimize.*,
  });

  var logger_module: *std.Build.Module = undefined;

  for ([_][] const u8 { "color", "log", "queue", "request", "spin", "bar", "logger", }) |module_name|
  {
    const module = builder.createModule (.{
      .root_source_file = .{ .cwd_relative = try builder.build_root.join (
        builder.allocator, &.{ "src", "logger", try std.fmt.allocPrint (builder.allocator, "{s}.zig", .{ module_name, }) }), },
      .target = target.*,
      .optimize = optimize.*,
    });

    index_module.addImport (module_name, module);
    module.addImport ("index", index_module);

    if (std.mem.eql (u8, module_name, "logger")) logger_module = module;
  }

  index_module.addImport ("ansiterm", ansiterm);
  index_module.addImport ("termsize", termsize);
  index_module.addImport ("datetime", datetime);
  index_module.addImport ("jdz", jdz_allocator);

  return logger_module;
}

pub fn build (builder: *std.Build) !void
{
  const target = builder.standardTargetOptions (.{});
  const optimize = std.builtin.OptimizeMode.Debug;

  ansiterm = builder.dependency ("ansi-term", .{
    .target = target,
    .optimize = optimize,
  }).module ("ansi-term");

  termsize = builder.dependency ("termsize", .{
    .target = target,
    .optimize = optimize,
  }).module ("termsize");

  datetime = builder.dependency ("zig-datetime", .{
    .target = target,
    .optimize = optimize,
  }).module ("zig-datetime");

  jdz_allocator = builder.dependency ("jdz_allocator", .{
    .target = target,
    .optimize = optimize,
  }).module ("jdz_allocator");

  const logger = try loggerModule (builder, &target, &optimize);

  const exodia = builder.addExecutable (.{
    .name = "exodia",
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  exodia.root_module.addImport ("datetime", datetime);
  exodia.root_module.addImport ("jdz", jdz_allocator);
  exodia.root_module.addImport ("logger", logger);

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
  unit_tests.root_module.addImport ("logger", logger);

  builder.installArtifact (exodia);
}
