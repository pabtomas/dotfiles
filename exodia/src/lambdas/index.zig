const std = @import ("std");
const mustache = @import ("mustache");

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
