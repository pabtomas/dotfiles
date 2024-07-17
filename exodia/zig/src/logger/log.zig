const std = @import ("std");

const index = @import ("index");

const datetime = index.datetime;

const Logger = index.Logger;
const Request = index.Request;
const Color = index.Color;

pub const Log = struct
{
  pub const Header = enum
  {
    ERROR, WARN, INFO, NOTE, DEBUG, TRACE, VERB, RAW,

    fn tag (self: @This (), logger: *const Logger) !void
    {
      if (@tagName (self).len < 4) return;
      if (@tagName (self).len < 5) try logger.writeByte (' ');
      try logger.writeAll (@tagName (self));
      try logger.writeByte (' ');
    }

    fn timestamp (self: @This (), logger: *const Logger) !void
    {
      if (self == .RAW) return;
      var buffer: [9] u8 = undefined;
      const now = datetime.Datetime.now ();
      try logger.writeAll (
        try std.fmt.bufPrint (&buffer, "{d:0>2}:{d:0>2}:{d:0>2} ",
          .{ now.time.hour, now.time.minute, now.time.second, }));
    }

    fn render (self: @This (), logger: *const Logger, message: [] const u8, first: *bool) !void
    {
      try self.timestamp (logger);
      if (first.*)
      {
        first.* = false;
        try logger.updateStyle (.{
          .foreground = switch (self)
            {
              .ERROR => .{ .Fixed = @intFromEnum (Color.red), },
              .WARN  => .{ .Fixed = @intFromEnum (Color.yellow), },
              .INFO  => .{ .Fixed = @intFromEnum (Color.green), },
              .NOTE  => .{ .Fixed = @intFromEnum (Color.cyan), },
              .DEBUG => .{ .Fixed = @intFromEnum (Color.blue), },
              .TRACE => .{ .Fixed = @intFromEnum (Color.purple), },
              .VERB  => .{ .Fixed = @intFromEnum (Color.pink), },
              .RAW   => .Default,
            },
          .font_style = .{ .bold = true, },
        });
        try self.tag (logger);
        try logger.resetStyle ();
      } else if (self != .RAW) {
        try logger.writeAll (" " ** index.level_length);
      }
      try logger.writeAll (message);
      try logger.clearFromCursorToLineEnd ();
    }
  };

  header: @This ().Header,
  message: [] const u8,
  first: bool = true,

  pub fn init (request: *Request) @This ()
  {
    return .{
      .header = request.kind.log,
      .message = request.data.?.message,
    };
  }

  pub fn render (self: *@This (), logger: *const Logger) !bool
  {
    var max_entry_length: usize = undefined;

    max_entry_length = if (logger.cols == null) self.message.len
                       else @min (logger.cols.? - index.header_length, self.message.len);
    try self.header.render (logger, self.message [0 .. max_entry_length], &self.first);
    self.message = self.message [max_entry_length ..];
    try logger.writeByte ('\n');
    return (self.message.len > 0);
  }
};
