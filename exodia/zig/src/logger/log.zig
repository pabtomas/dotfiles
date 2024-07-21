const std = @import ("std");

const index = @import ("index");

const datetime = index.datetime;

const Logger = index.Logger;
const Request = index.Request;
const Color = index.Color;

pub const Log = struct
{
  pub const Header = enum (usize)
  {
    const colors = [7] Color { .@"204", .@"227", .@"119", .@"81", .@"69", .@"135", .@"207", };

    ERROR = 0, WARN, INFO, NOTE, DEBUG, TRACE, VERB, RAW, EMPTY,

    fn tag (self: @This (), logger: *const Logger) !void
    {
      if (@tagName (self).len < 4) return;
      if (@tagName (self).len < 5) try logger.writeByte (' ');
      try logger.writeAll (@tagName (self));
      try logger.writeByte (' ');
    }

    pub fn incr (self: @This ()) @This ()
    {
      std.debug.assert (self != .VERB);
      std.debug.assert (self != .EMPTY);
      std.debug.assert (self != .RAW);
      return @enumFromInt (@intFromEnum (self) + 1);
    }

    pub fn decr (self: @This ()) @This ()
    {
      std.debug.assert (self != .ERROR);
      std.debug.assert (self != .EMPTY);
      std.debug.assert (self != .RAW);
      return @enumFromInt (@intFromEnum (self) - 1);
    }

    pub fn lt (self: @This (), other: @This ()) bool
    {
      std.debug.assert (self != .EMPTY);
      std.debug.assert (self != .RAW);
      std.debug.assert (other != .EMPTY);
      std.debug.assert (other != .RAW);
      return @intFromEnum (self) < @intFromEnum (other);
    }

    pub fn gt (self: @This (), other: @This ()) bool
    {
      std.debug.assert (self != .EMPTY);
      std.debug.assert (self != .RAW);
      std.debug.assert (other != .EMPTY);
      std.debug.assert (other != .RAW);
      return @intFromEnum (self) > @intFromEnum (other);
    }

    fn timestamp (self: @This (), logger: *Logger) !void
    {
      if (self == .RAW) return;
      var buffer: [9] u8 = undefined;
      const now = datetime.Datetime.now ();
      try logger.writeAll (
        try std.fmt.bufPrint (&buffer, "{d:0>2}:{d:0>2}:{d:0>2} ",
          .{ now.time.hour, now.time.minute, now.time.second, }));
    }

    fn render (self: @This (), logger: *Logger, message: [] const u8) !void
    {
      try self.timestamp (logger);
      if (self == .EMPTY)
      {
        try logger.writeAll (" " ** index.level_length);
      } else if (self != .RAW) {
        try logger.updateStyle (.{
          .foreground = switch (self)
            {
              .RAW, .EMPTY => .Default,
              else => .{ .Fixed = @intFromEnum (@This ().colors [@intFromEnum (self)]), },
            },
          .font_style = .{ .bold = true, },
        });
        try self.tag (logger);
        try logger.resetStyle ();
      }
      try logger.writeAll (message);
      try logger.clearFromCursorToLineEnd ();
    }
  };

  header: @This ().Header,
  message: [] const u8,

  pub fn init (request: *Request) @This ()
  {
    return .{
      .header = request.kind.log,
      .message = request.data.?,
    };
  }

  pub fn render (self: *@This (), logger: *Logger) !bool
  {
    var max_entry_length: usize = undefined;

    max_entry_length = if (logger.cols == null) self.message.len
                       else @min (logger.cols.? - index.header_length, self.message.len);
    try self.header.render (logger, self.message [0 .. max_entry_length]);
    self.message = self.message [max_entry_length ..];
    if (self.header != .EMPTY and self.header != .RAW) self.header = .EMPTY;
    try logger.writeByte ('\n');
    return (self.message.len > 0);
  }
};
