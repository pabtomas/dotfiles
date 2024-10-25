const std = @import ("std");
// const toolbox = @import ("toolbox");

var ansiterm: *std.Build.Module = undefined;
var datetime: *std.Build.Module = undefined;
var jdz: *std.Build.Module = undefined;
var libcurl: *std.Build.Module = undefined;
var termsize: *std.Build.Module = undefined;
var libjq: *std.Build.Step.Compile = undefined;

fn import (module: *std.Build.Module) void
{
  module.addImport ("ansiterm", ansiterm);
  module.addImport ("datetime", datetime);
  module.addImport ("jdz", jdz);
  module.addImport ("libcurl", libcurl);
  module.addImport ("termsize", termsize);
  module.linkLibrary (libjq);
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

  libjq = builder.dependency ("libjq.zig", .{
    .target = target,
    .optimize = optimize,
  }).artifact ("jq");

  //libcurl = builder.createModule (.{
  //  .root_source_file = .{ .cwd_relative = try builder.build_root.join (
  //    builder.allocator, &.{ "src", "curl.zig", }), },
  //  .target = target,
  //  .optimize = optimize,
  //  .link_libc = true,
  //});
  //libcurl.linkLibrary (try getLibcurl (builder, &target, &optimize));

  const jinzo = builder.addExecutable (.{
    .name = "jinzo",
    .root_source_file = .{ .cwd_relative = try builder.build_root.join (
      builder.allocator, &.{ "src", "main.zig", }), },
    .target = target,
    .optimize = optimize,
  });

  import (&jinzo.root_module);

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
  unit_tests.linkLibC ();
  import (&unit_tests.root_module);

  unit_tests.step.dependOn (builder.getInstallStep ());

  const run_unit_tests = builder.addRunArtifact (unit_tests);

  const unit_step = builder.step ("unit", "Run unit tests");
  unit_step.dependOn (&run_unit_tests.step);

  unit_tests.root_module.addImport ("index", unit_module);

  builder.installArtifact (jinzo);
}

// const Paths = struct
// {
//   // prefixed attributes
//   __curl: [] const u8 = undefined,
// 
//   // mandatory getters
//   pub fn getCurl (self: @This ()) [] const u8 { return self.__curl; }
// 
//   // mandatory init
//   pub fn init (builder: *std.Build) !@This ()
//   {
//     return .{
//       .__curl = try builder.build_root.join (builder.allocator,
//         &.{ "curl", }),
//     };
//   }
// };
// 
// fn getLibcurl (builder: *std.Build, target: *const std.Build.ResolvedTarget,
//   optimize: *const std.builtin.OptimizeMode) !*std.Build.Step.Compile
// {
//   const path = try Paths.init (builder);
// 
//   const dependencies = try toolbox.Dependencies.init (builder, "libcurl.zig",
//   &.{ "curl", },
//   .{
//      .toolbox = .{
//        .name = "tiawl/toolbox",
//        .host = toolbox.Repository.Host.github,
//        .ref = toolbox.Repository.Reference.tag,
//      },
//    }, .{
//      .curl = .{
//        .name = "curl/curl",
//        .host = toolbox.Repository.Host.github,
//        .ref = toolbox.Repository.Reference.tag,
//      },
//    });
// 
//   std.fs.deleteTreeAbsolute (path.getCurl ()) catch |err|
//   {
//     switch (err)
//     {
//       error.FileNotFound => {},
//       else => return err,
//     }
//   };
// 
//   try dependencies.clone (builder, "curl", path.getCurl ());
// 
//   var curl_dir = try std.fs.openDirAbsolute (path.getCurl (),
//     .{ .iterate = true, });
//   var it = curl_dir.iterate ();
// 
//   while (try it.next ()) |*entry|
//   {
//     switch (entry.kind)
//     {
//       .directory => if (std.mem.eql (u8, "include", entry.name) or
//                         std.mem.eql (u8, "lib", entry.name)) continue,
//       else => {},
//     }
//     try std.fs.deleteTreeAbsolute (try std.fs.path.join (
//       builder.allocator, &.{ path.getCurl (), entry.name, }));
//   }
// 
//   const lib = builder.addStaticLibrary (.{
//     .name = "curl",
//     .root_source_file = builder.addWriteFiles ().add ("empty.c", ""),
//     .target = target.*,
//     .optimize = optimize.*,
//   });
// 
//   for ([_][] const u8 {
//     try std.fs.path.join (builder.allocator, &.{ "curl", "lib", }),
//     try std.fs.path.join (builder.allocator, &.{ "curl", "include", }),
//   }) |include| toolbox.addInclude (lib, include);
// 
//   toolbox.addHeader (lib, try std.fs.path.join (builder.allocator,
//     &.{ path.getCurl (), "include", "curl", }), "curl", &.{ ".h", });
// 
//   lib.linkLibC ();
// 
//   lib.defineCMacro("BUILDING_LIBCURL", null);
//   lib.defineCMacro ("HAVE_STRUCT_TIMEVAL", "1");
//   lib.defineCMacro ("HAVE_RECV", "1");
//   lib.defineCMacro ("HAVE_SEND", "1");
//   lib.defineCMacro ("HAVE_SOCKET", "1");
//   lib.defineCMacro("HAVE_POLL_FINE", "1");
//   lib.defineCMacro("HAVE_ARPA_INET_H", "1");
//       lib.defineCMacro("HAVE_FCNTL", "1");
//       lib.defineCMacro("HAVE_LONGLONG", "1");
//     lib.defineCMacro("CURL_DISABLE_LDAP", "1");
//     lib.defineCMacro("CURL_DISABLE_LDAPS", "1");
//     lib.defineCMacro("HAVE_FCNTL_H", "1");
//     lib.defineCMacro("HAVE_FCNTL_O_NONBLOCK", "1");
//     lib.defineCMacro("OS", "\"Linux\"");
//     lib.defineCMacro("HAVE_NETDB_H", "1");
//   lib.defineCMacro("HAVE_POLL_H", "1");
//   lib.defineCMacro("HAVE_POLL", "1");
//   lib.defineCMacro("HAVE_SELECT", "1");
//   lib.defineCMacro("HAVE_STDBOOL_H", "1");
//   lib.defineCMacro("HAVE_STDINT_H", "1");
//   lib.defineCMacro("HAVE_STDIO_H", "1");
//   lib.defineCMacro("HAVE_STDLIB_H", "1");
//   lib.defineCMacro("HAVE_SYS_STAT_H", "1");
//   lib.defineCMacro("HAVE_SYS_TYPES_H", "1");
//   lib.defineCMacro("HAVE_UNISTD_H", "1");
//   lib.defineCMacro ("HAVE_STRUCT_SOCKADDR_STORAGE", "1");
//   lib.defineCMacro ("SIZEOF_CURL_OFF_T", "8");
//   lib.defineCMacro("USE_UNIX_SOCKETS", null);
//   lib.defineCMacro("HAVE_SYS_UN_H", "1");
// 
//   var walker = try curl_dir.walk (builder.allocator);
//   defer walker.deinit ();
// 
//   while (try walker.next ()) |*entry|
//   {
//     switch (entry.kind)
//     {
//       .file => {
//         if (toolbox.isCSource (entry.basename))
//           try toolbox.addSource (lib, path.getCurl (), entry.path, &.{});
//       },
//       else => {},
//     }
//   }
// 
//   return lib;
// }
