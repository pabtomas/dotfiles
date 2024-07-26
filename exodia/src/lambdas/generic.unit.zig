const std = @import ("std");

const mustache = @import ("mustache");

const index = @import ("index");
const Lambdas = index.Lambdas;

test "generic"
{
  const allocator = std.testing.allocator;

  // TODO: const template = "{{#generic}}.{ .name = \"volume\", .override = .{ .ReadOnly = false, }, }{{/generic}}";
  const template = "{{#generic}}{ \"name\": \"volume\", \"override\": { \"ReadOnly\": false, }, }{{/generic}}";

  // TODO: const generics =
  //  \\.{
  //  \\  "generics": .{
  //  \\    "volume": .{
  //  \\      "Type": "volume",
  //  \\      "VolumeOptions": .{},
  //  \\    },
  //  \\  },
  //  \\}
  const generics =
    \\{
    \\  "generics": {
    \\    "volume": {
    \\      "Type": "volume",
    \\      "VolumeOptions": {},
    \\    },
    \\  },
    \\}
  ;
  var value = try std.json.parseFromSlice (std.json.Value, allocator, generics, .{});
  defer value.deinit ();

  const result = try mustache.allocRenderTextWithOptions (allocator, template, generics, .{ .global_lambdas = Lambdas, });
  defer allocator.free (result);

  try std.testing.expectEqualStrings ("{\"Type\":\"volume\",\"VolumeOptions\":{},\"ReadOnly\":false}", result);
}
