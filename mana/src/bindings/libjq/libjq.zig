const std = @import ("std");

const c = @cImport ({
  @cInclude ("jv.h");
  @cInclude ("jq.h");
  @cInclude ("util.h");
});

pub const Jq = struct
{
  handle: *c.jq_state,
  allocator: std.mem.Allocator,
  lib_search_paths: c.jv,

  pub fn init (allocator: std.mem.Allocator) !@This ()
  {
    return if (c.jq_init ()) |handle|
      .{
        .handle = handle,
        .allocator = allocator,
        .lib_search_paths = c.jv_null (),
       }
    else
       error.JqInit;
  }

  pub fn compile (self: @This (), program: [] const u8) !void
  {
    const compiled = c.jq_compile (self.handle, try self.allocator.dupeZ (u8, program));
    if (compiled == 0) return error.JqCompileError;
  }

  pub fn setLibraryPaths (self: *@This (), paths: *const std.ArrayList ([] const u8)) !void
  {
    if (paths.items.len > 0)
    {
      self.lib_search_paths = c.jv_array_sized (@intCast (paths.items.len));
      for (paths.items) |path|
        self.lib_search_paths = c.jv_array_append (self.lib_search_paths, c.jq_realpath (c.jv_string (path.ptr)));
    } else {
      var env = try std.process.getEnvMap (self.allocator);
      defer env.deinit ();

      var origin: [] const u8 = ".";
      if (env.get ("ORIGIN")) |unwrapped| { if (unwrapped.len > 0) origin = unwrapped; }
      const path1 = try std.fmt.allocPrintZ (self.allocator, "{s}/../lib/jq", .{ origin, });
      defer self.allocator.free (path1);
      const path2 = try std.fmt.allocPrintZ (self.allocator, "{s}/../lib", .{ origin, });
      defer self.allocator.free (path2);

      self.lib_search_paths = c.jv_array_sized (3);
      self.lib_search_paths = c.jv_array_append (self.lib_search_paths, c.jv_string ("~/.jq"));
      self.lib_search_paths = c.jv_array_append (self.lib_search_paths, c.jv_string (path1.ptr));
      self.lib_search_paths = c.jv_array_append (self.lib_search_paths, c.jv_copy (c.jv_string (path2.ptr)));
    }
    c.jq_set_attr (self.handle, c.jv_string ("JQ_LIBRARY_PATH"), c.jv_copy (self.lib_search_paths));
  }

  pub fn deinit (self: *@This ()) void
  {
    c.jq_teardown (@ptrCast (&self.handle));
    // Keep this commented. I had some hardtime understanding how libjq works, it could be useful another time
    // var i = c.jv_array_length (c.jv_copy (self.lib_search_paths));
    // while (i > 0)
    // {
    //   std.debug.print ("[{}]", .{i-1});
    //   std.debug.print (" {s}\n", .{c.jv_string_value (c.jv_array_get (c.jv_copy (self.lib_search_paths), i-1))});
    //   i -= 1;
    // }
    c.jv_free (self.lib_search_paths);
  }
};
