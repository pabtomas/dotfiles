const std = @import ("std");

const mustache = @import ("mustache");

const index = @import ("index");
const Lambdas = index.Lambdas;

test "index"
{
  const allocator = std.testing.allocator;

  // TODO: const template = "list[4] = {{#index}}.{ .i = 4, .list = {{inventory.list}}, }{{/index}}";
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
  var data = std.json.Value { .object = std.json.ObjectMap.init (allocator), };
  try data.object.put ("list", list);
  const result = try mustache.allocRenderTextWithOptions (allocator, template, data, .{ .global_lambdas = Lambdas, });
  defer allocator.free (result);

  try std.testing.expectEqualStrings ("list[4] = T" , result);
}
