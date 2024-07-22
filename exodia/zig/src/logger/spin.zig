const std = @import ("std");

const index = @import ("index.zig");

const datetime = @import ("datetime").datetime;

const Stream = index.Stream;
const Color = index.Color;

const patterns: [34][] const u8 = .{
  " ⠄     ",
  " ⠔     ",
  " ⠐⠁    ",
  "  ⠉    ",
  "  ⠈⠂   ",
  "   ⠢   ",
  "   ⠠⠄  ",
  "    ⠔  ",
  "    ⠐⠁ ",
  "     ⠉ ",
  "     ⠘ ",
  "     ⠔ ",
  "    ⠠⠄ ",
  "    ⠢  ",
  "   ⠈⠂  ",
  "   ⠉   ",
  "  ⠐⠁   ",
  "  ⠔    ",
  " ⠠⠄    ",
  " ⠢     ",
  " ⠃     ",
  " ⠉     ",
  " ⠈⠂    ",
  "  ⠢    ",
  "  ⠠⠄   ",
  "   ⠔   ",
  "   ⠐⠁  ",
  "    ⠉  ",
  "    ⠈⠂ ",
  "     ⠢ ",
  "     ⠠ ",
} ++ (.{ "       ", } ** 3) ;

const colors: [30] u8 = .{ 196, 202, 208, 214, 220, 226, 190, 154, 118, 82,
  46, 47, 48, 49, 50, 51, 45, 39, 33, 27, 21, 57, 93, 128, 165, 201, 200,
  199, 198, 197, };

const message_max_length: usize = 512;

const ns_per_cs: u64 = 10_000_000;
const ns_per_ds: u64 = 100_000_000;
const ds_per_s: u64 = 10;
const min_per_hour: u64 = 60;
const hour_per_day: u64 = 24;

pub const Spin = struct
{
  message: [] const u8,
  birth: datetime.Datetime,

  pub fn init (message: [] const u8) @This ()
  {
    return .{
      .message = message,
      .birth = datetime.Datetime.now (),
    };
  }

  fn chrono (self: @This (), stream: *Stream) !u64
  {
    var buffer: [8] u8 = undefined;
    var now = datetime.Datetime.now ();
    const delta = now.sub (self.birth);
    const ns: u64 = @intCast (@max (0, delta.nanoseconds));
    const sec: u64 = @intCast (delta.seconds);
    const days: u64 = @intCast (delta.days);

    try stream.writeAll (
      if (days == 0 and sec < 10)
        try std.fmt.bufPrint (&buffer, "    {d}.{d:0>2}",
          .{ sec, ns / ns_per_cs, })
      else if (days == 0 and sec < std.time.s_per_min)
        try std.fmt.bufPrint (&buffer, "   {d:0>2}.{d:0>2}",
          .{ sec, ns / ns_per_cs, })
      else if (days == 0 and sec < 10 * std.time.s_per_min)
        try std.fmt.bufPrint (&buffer, "    {d}:{d:0>2}",
          .{ sec / std.time.s_per_min, sec % std.time.s_per_min, })
      else if (days == 0 and sec < std.time.s_per_hour)
        try std.fmt.bufPrint (&buffer, "   {d:0>2}:{d:0>2}",
          .{ sec / std.time.s_per_min, sec % std.time.s_per_min, })
      else if (days == 0 and sec < 10 * std.time.s_per_hour)
        try std.fmt.bufPrint (&buffer, " {d}:{d:0>2}:{d:0>2}",
          .{ sec / std.time.s_per_hour, (sec / std.time.s_per_min) % min_per_hour, sec % std.time.s_per_min, })
      else if (days < 4 or sec < 4 * std.time.s_per_hour)
        try std.fmt.bufPrint (&buffer, "{d}:{d:0>2}:{d:0>2}",
          .{ (days * hour_per_day) + (sec / std.time.s_per_hour), (sec / std.time.s_per_min) % min_per_hour, sec % std.time.s_per_min, })
      else try std.fmt.bufPrint (&buffer, "--:--:-- ", .{})
    );

    return (days * std.time.s_per_day + sec) * ds_per_s + ns / ns_per_ds;
  }

  pub fn render (self: *@This (), stream: *Stream, first: bool) !void
  {
    if (stream.cols == null) return;
    if (!first) try stream.writeByte ('\n');
    try stream.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    const elapsed_ds = try self.chrono (stream);
    try stream.updateStyle (.{
      .foreground = .{ .Fixed = colors [(elapsed_ds / 5) % colors.len], },
      .font_style = .{ .bold = true, },
    });
    try stream.writeAll (patterns [elapsed_ds % (patterns.len)]);
    try stream.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    const max_entry_length = stream.cols.? - index.header_length;
    try stream.writeAll (self.message [0 .. @min (self.message.len, max_entry_length)]);
    try stream.resetStyle ();
    try stream.clearFromCursorToLineEnd ();
  }
};
