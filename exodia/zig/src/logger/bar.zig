const std = @import ("std");

const index = @import ("index");

const datetime = index.datetime;

const Logger = index.Logger;
const Color = index.Color;

const colors: [10] u8 = .{ 204, 203, 209, 215, 221, 227, 191, 155, 119, 83, };
const offsets: [7] *const [3:0] u8 = .{ "▏", "▎", "▍", "▌", "▋", "▊", "▉", };
const coef = 10;

fn top (logger: *Logger, first: bool) !void
{
  if (!first) try logger.writeByte ('\n');
  try logger.writeByte (' ');
  try logger.updateStyle (.{
    .foreground = .{ .Fixed = @intFromEnum (Color.white), },
    .font_style = .{ .bold = true, },
  });
  for (0 .. (logger.cols.? - 6)) |_| try logger.writeAll ("▁");
  try logger.clearFromCursorToLineEnd ();
  try logger.writeByte ('\n');
}

fn bottom (logger: *Logger) !void
{
  try logger.writeByte (' ');
  for (0 .. (logger.cols.? - 6)) |_| try logger.writeAll ("▔");
  try logger.resetStyle ();
  try logger.clearFromCursorToLineEnd ();
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

  fn middle (self: *@This (), logger: *Logger, term_max: u32) !void
  {
    const offset_index = self.term_cursor % (offsets.len + 1);
    const percent = (self.term_cursor * 100) / term_max;
    var buffer: [4] u8 = undefined;
    var i: u16 = 8;

    try logger.writeAll ("▕");
    try logger.updateStyle (.{
      .background = .{ .Fixed = colors [@min (percent / colors.len, colors.len - 1)], },
      .font_style = .{ .bold = true, },
    });
    while (i <= self.term_cursor) { try logger.writeByte (' '); i = i + 8; }
    try logger.resetStyle ();
    try logger.updateStyle (.{
      .foreground = .{ .Fixed = colors [@min (percent / colors.len, colors.len - 1)], },
      .font_style = .{ .bold = true, },
    });
    if (self.term_cursor < term_max and (offset_index > 0)) try logger.writeAll (offsets [offset_index - 1]);
    try logger.resetStyle ();
    if (offset_index == 0) i = i - 8;
    while (i < term_max) { try logger.writeByte (' '); i = i + 8; }
    try logger.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    try logger.writeAll ("▎");
    try logger.writeAll (try std.fmt.bufPrint (&buffer, "{d}%", .{ percent, }));
    try logger.clearFromCursorToLineEnd ();
    try logger.writeByte ('\n');
  }

  pub fn render (self: *@This (), logger: *Logger, first: bool) !bool
  {
    if (logger.cols == null) return false;
    const term_max = (logger.cols.? - 6) * 8;
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

    try top (logger, first);
    try self.middle (logger, term_max);
    try bottom (logger);

    return true;
  }
};
