const std = @import ("std");

const index = @import ("index.zig");
const Request = index.Request;

pub const Queue = struct
{
  id: [] const u8,
  list: std.DoublyLinkedList (Request) = .{},

  pub fn init (id: [] const u8) @This ()
  {
    return .{ .id = id, };
  }

  pub fn append (self: *@This (), allocator: *const std.mem.Allocator, request: Request) !void
  {
    const node = try allocator.create (std.DoublyLinkedList (Request).Node);
    node.* = .{ .data = request, };
    self.list.append (node);
  }
};
