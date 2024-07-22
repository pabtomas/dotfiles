const std = @import ("std");

const ansiterm = @import ("ansiterm");
const termsize = @import ("termsize");

pub const Stream = struct
{
  const size = 4096;
  buffer: std.io.BufferedWriter (size, std.fs.File.Writer),
  writer: std.io.BufferedWriter (size, std.fs.File.Writer).Writer,
  cols: ?u16,

  // We do not need to print the whole 4096 sized buffer
  pub fn format (self: @This (), comptime _: [] const u8, _: std.fmt.FormatOptions, writer: anytype) !void
  {
    try writer.print ("{s}{c} ", .{ @typeName (@This ()), '{', });
    inline for (@typeInfo (@This ()).Struct.fields, 0 ..) |field, i|
    {
      const comma = if (i < @typeInfo (@This ()).Struct.fields.len - 1) "," else "";
      if (std.mem.eql (u8, field.name, "cols"))
        try writer.print (".{s} = {?}{s} ", .{ field.name, self.cols, comma, })
      else
        try writer.print (".{s} = {s}{s} ", .{ field.name, @typeName (field.type), comma, });
    }
    try writer.print ("{c}", .{ '}', });
  }

  pub fn flush (self: *@This ()) ! void
  {
    try self.buffer.flush ();
  }

  pub fn updateCols (self: *@This ()) !void
  {
    if (self.cols != null) self.cols = (try termsize.termSize (std.io.getStdErr ())).?.width;
  }

  pub fn clearFromCursorToLineEnd (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.clear.clearFromCursorToLineEnd (self.writer);
  }

  pub fn clearFromCursorToScreenEnd (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.clear.clearFromCursorToScreenEnd (self.writer);
  }

  pub fn showCursor (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.showCursor (self.writer);
  }

  pub fn hideCursor (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.hideCursor (self.writer);
  }

  pub fn cursorStartLine (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.setCursorColumn (self.writer, 0);
  }

  pub fn cursorPreviousLine (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.cursorPreviousLine (self.writer, 1);
  }

  pub fn updateStyle (self: @This (), style: ansiterm.style.Style) !void
  {
    if (self.cols != null) try ansiterm.format.updateStyle (self.writer, style, null);
  }

  pub fn resetStyle (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.format.resetStyle (self.writer);
  }

  pub fn writeAll (self: @This (), str: [] const u8) !void
  {
    try self.writer.writeAll (str);
  }

  pub fn writeByte (self: @This (), byte: u8) !void
  {
    try self.writer.writeByte (byte);
  }
};
