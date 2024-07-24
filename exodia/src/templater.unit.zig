const std = @import ("std");

const mustache = @import ("mustache");

const Templater = @import ("templater.zig").Templater;

test "index"
{
  const allocator = std.testing.allocator;
  var templater = Templater.init (&allocator);
  defer templater.deinit ();

  // TODO: const template = "list[5] = {{#index}}.{ .i = 4, .list = {{inventory.list}}, }{{/index}}";
  const template = "list[4] = {{#index}}{ \"i\" = 4, \"list\" = {{inventory.list}}, }{{/index}}";

  var array = std.ArrayList (std.json.Value).init (allocator);
  defer array.deinit ();
  try array.appendSlice (&[_] std.json.Value {
    std.json.Value { .string = "A", },
    std.json.Value { .string = "Z", },
    std.json.Value { .string = "E", },
    std.json.Value { .string = "R", },
    std.json.Value { .string = "T", },
    std.json.Value { .string = "Y", },
  });
  const list = std.json.Value { .array = array, };
  try templater.put ("list", &list);
  const result = try mustache.allocRenderText (allocator, template, templater);
  defer allocator.free (result);

  try std.testing.expectEqualStrings ("list[4] = T" , result);
}
