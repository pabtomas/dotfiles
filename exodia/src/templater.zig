const std = @import ("std");

const mustache = @import ("mustache");

pub const Templater = struct
{
  inventory: std.json.Value,

  pub fn init (allocator: *const std.mem.Allocator) @This ()
  {
    return .{
      .inventory = .{ .object = std.json.ObjectMap.init (allocator.*), },
    };
  }

  pub fn deinit (self: *@This ()) void
  {
    self.inventory.object.deinit ();
  }

  pub fn getPtr (self: *@This (), key: [] const u8) ?*std.json.Value
  {
    return self.inventory.object.getPtr (key);
  }

  pub fn put (self: *@This (), key: [] const u8, value: *const std.json.Value) !void
  {
    try self.inventory.object.put (key, value.*);
  }

  pub fn index (context: mustache.LambdaContext) !void
  {
    const inner = try context.renderAlloc (context.allocator, context.inner_text);
    defer context.allocator.free (inner);

    const params = try std.json.parseFromSlice (std.json.Value, context.allocator.*,
      inner, .{ .ignore_unknown_fields = false, });
    defer params.deinit ();

    const list = params.object.get ("list").?.array.items;
    const i = params.object.get ("i").?.array.items;
    try context.writeFormat ("{s}", .{ list [i], });
  }
};
