const std = @import ("std");

const index = @import ("index.zig");

const datetime = @import ("datetime").datetime;

const Stream = index.Stream;
const Color = index.Color;

const colors: [10] u8 = .{ 204, 203, 209, 215, 221, 227, 191, 155, 119, 83, };
const offsets: [7] *const [3:0] u8 = .{ "▏", "▎", "▍", "▌", "▋", "▊", "▉", };
const coef = 10;

fn top (stream: *Stream, first: bool) !void
{
  if (!first) try stream.writeByte ('\n');
  try stream.writeByte (' ');
  try stream.updateStyle (.{
    .foreground = .{ .Fixed = @intFromEnum (Color.white), },
    .font_style = .{ .bold = true, },
  });
  for (0 .. (stream.cols.? - 6)) |_| try stream.writeAll ("▁");
  try stream.clearFromCursorToLineEnd ();
  try stream.writeByte ('\n');
}

fn bottom (stream: *Stream) !void
{
  try stream.writeByte (' ');
  for (0 .. (stream.cols.? - 6)) |_| try stream.writeAll ("▔");
  try stream.resetStyle ();
  try stream.clearFromCursorToLineEnd ();
}

pub const Bar = struct
{
  max: u32,
  progress: u32,
  term_cursor: u32,
  running: bool,
  last: datetime.Datetime,

  pub fn init (max: u32) @This ()
  {
    return .{
      .max = max,
      .progress = 0,
      .term_cursor = 0,
      .running = (max > 0),
      .last = datetime.Datetime.now (),
    };
  }

  pub fn incr (self: *@This ()) void
  {
    std.debug.assert (self.progress < self.max);
    self.progress = self.progress + 1;
  }

  fn middle (self: *@This (), stream: *Stream, term_max: u32) !void
  {
    const offset_index = self.term_cursor % (offsets.len + 1);
    const percent = (self.term_cursor * 100) / term_max;
    var buffer: [4] u8 = undefined;
    var i: u16 = 8;

    try stream.writeAll ("▕");
    try stream.updateStyle (.{
      .background = .{ .Fixed = colors [@min (percent / colors.len, colors.len - 1)], },
      .font_style = .{ .bold = true, },
    });
    while (i <= self.term_cursor) { try stream.writeByte (' '); i = i + 8; }
    try stream.resetStyle ();
    try stream.updateStyle (.{
      .foreground = .{ .Fixed = colors [@min (percent / colors.len, colors.len - 1)], },
      .font_style = .{ .bold = true, },
    });
    if (self.term_cursor < term_max and (offset_index > 0)) try stream.writeAll (offsets [offset_index - 1]);
    try stream.resetStyle ();
    if (offset_index == 0) i = i - 8;
    while (i < term_max) { try stream.writeByte (' '); i = i + 8; }
    try stream.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    try stream.writeAll ("▎");
    try stream.writeAll (try std.fmt.bufPrint (&buffer, "{d}%", .{ percent, }));
    try stream.clearFromCursorToLineEnd ();
    try stream.writeByte ('\n');
  }

  pub fn render (self: *@This (), stream: *Stream, first: bool) !bool
  {
    if (stream.cols == null) return false;
    const term_max = (stream.cols.? - 6) * 8;
    if (self.term_cursor >= term_max) self.running = false;
    if (!self.running) return false;

    const term_progress = (self.progress * term_max) / self.max;
    var now = datetime.Datetime.now ();
    const delta = now.sub (self.last);
    if (self.term_cursor < term_progress and delta.nanoseconds > 10_000_000)
    {
      const gap = (term_progress - self.term_cursor) / coef;
      const log = std.math.log2 (@max (gap, 2)) - 1;
      const shift = @min (gap, log);
      self.term_cursor = self.term_cursor + std.math.shl (u32, 1, shift);
      self.last = now;
    }

    try top (stream, first);
    try self.middle (stream, term_max);
    try bottom (stream);

    return true;
  }
};
