const std = @import ("std");
const mustache = @import ("mustache");

pub fn generic (generics: std.json.Value, context: mustache.LambdaContext) !void
{
  const inner = try context.renderAlloc (context.allocator, context.inner_text);
  defer context.allocator.free (inner);

  const params = try std.json.parseFromSlice (std.json.Value, context.allocator.*,
    inner, .{ .ignore_unknown_fields = false, });
  defer params.deinit ();

  const name = params.object.get ("name").?.string;
  const override = params.object.get ("override").?;

  var obj = generics.object.get (name).?;
  var it = override.keyIterator ();
  while (it.next ()) |key|
    try obj.object.put (key, override.object.get (key).?);
  const str = try std.json.stringifyAlloc (context.allocator, obj, .{ .whitespace = .minified, });
  defer context.allocator.free (str);
  try context.writeFormat ("{s}", .{ str, });
}
