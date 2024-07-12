const std = @import ("std");

const ansiterm = @import ("ansiterm");
const termsize = @import ("termsize");
const datetime = @import ("datetime").datetime;

const Color = enum (u8)
{
  // log colors
  red    = 204,
  yellow = 227,
  green  = 119,
  cyan   = 81,
  blue   = 69,
  purple = 135,
  pink   = 207,
  white  = 15,

  // spin colors
  @"196" = 196,
  @"202" = 202,
  @"208" = 208,
  @"214" = 214,
  @"220" = 220,
  @"226" = 226,
  @"190" = 190,
  @"154" = 154,
  @"118" = 118,
  @"82" = 82,
  @"46" = 46,
  @"47" = 47,
  @"48" = 48,
  @"49" = 49,
  @"50" = 50,
  @"51" = 51,
  @"45" = 45,
  @"39" = 39,
  @"33" = 33,
  @"27" = 27,
  @"21" = 21,
  @"57" = 57,
  @"93" = 93,
  @"128" = 128,
  @"165" = 165,
  @"201" = 201,
  @"200" = 200,
  @"199" = 199,
  @"198" = 198,
  @"197" = 197,

  // progressbar colors
  @"203" = 203,
  @"209" = 209,
  @"215" = 215,
  @"221" = 221,
  @"191" = 191,
  @"155" = 155,
  @"83" = 83,
};

const Log = struct
{
  const Level = enum
  {
    ERROR, WARN, INFO, NOTE, DEBUG, TRACE, VERB, RAW,

    fn tag (self: @This ()) !void
    {
      if (@tagName (self).len < 4) return;
      if (@tagName (self).len < 5) try Logger.stderr.writeByte (' ');
      try Logger.stderr.writeAll (@tagName (self));
      try Logger.stderr.writeByte (' ');
    }

    fn timestamp (self: @This ()) !void
    {
      if (self == .RAW) return;
      var buffer: [9] u8 = undefined;
      const now = datetime.Datetime.now ();
      try Logger.stderr.writeAll (
        try std.fmt.bufPrint (&buffer, "{d:0>2}:{d:0>2}:{d:0>2} ",
          .{ now.time.hour, now.time.minute, now.time.second, }));
    }

    fn render (self: @This (), message: [] const u8, header: *bool) !void
    {
      try self.timestamp ();
      if (!header.*)
      {
        header.* = true;
        try ansiterm.format.updateStyle (Logger.stderr, .{
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
          }, null);
        try self.tag ();
        try ansiterm.format.resetStyle (Logger.stderr);
      } else if (self != .RAW) {
        try Logger.stderr.writeAll (" " ** Logger.level_length);
      }
      try Logger.stderr.writeAll (message);
      try ansiterm.clear.clearFromCursorToLineEnd (Logger.stderr);
    }
  };

  level: Level,
  message: [] const u8,
  header: bool = false,

  fn init (entry: [] const u8) !@This ()
  {
    return .{
              .level = switch (entry [0])
                       {
                         '0'  => .ERROR,
                         '1'  => .WARN,
                         '2'  => .INFO,
                         '3'  => .NOTE,
                         '4'  => .DEBUG,
                         '5'  => .TRACE,
                         '6'  => .VERB,
                         '-'  => .RAW,
                         else => return error.UnknownLogRequest,
                       },
              .message = entry [1 ..],
            };
  }

  fn render (self: *@This ()) !void
  {
    var max_entry_length: usize = undefined;
    var looping = true;

    while (looping)
    {
      max_entry_length = @min (Logger.cols - Logger.header_length, self.message.len);
      //max_entry_length = @min (10, self.message.len);
      try self.level.render (self.message [0 .. max_entry_length], &self.header);
      self.message = self.message [max_entry_length ..];
      try Logger.stderr.writeByte ('\n');
      try Logger.buffered_stderr.flush (); // don't forget to flush!
      looping = (self.message.len > 0);
    }
  }
};

const Spin = struct
{
  const message_max_length: usize = 512;

  const ns_per_cs: u64 = 10_000_000;
  const ns_per_ds: u64 = 100_000_000;
  const ds_per_s: u64 = 10;
  const min_per_hour: u64 = 60;
  const hour_per_day: u64 = 24;

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

  id: [Logger.id_max_length] u8,
  id_length: usize,
  message: [@This ().message_max_length] u8,
  birth: datetime.Datetime,

  fn init (id: [] const u8, message: [] const u8) !@This ()
  {
    if (id.len > Logger.id_max_length) return error.SpinIdTooLong;
    var self: @This () = .{
                            .id = undefined,
                            .id_length = id.len,
                            .message = undefined,
                            .birth = datetime.Datetime.now (),
                          };
    const max_entry_length = Logger.cols - Logger.header_length;
    std.mem.copyBackwards (u8, &self.id, id [0 .. id.len]);
    std.mem.copyBackwards (u8, &self.message, message [0 .. @min (max_entry_length, @min (message.len, @This ().message_max_length))]);
    return self;
  }

  fn chrono (self: @This ()) !u64
  {
    var buffer: [8] u8 = undefined;
    var now = datetime.Datetime.now ();
    const delta = now.sub (self.birth);
    const ns: u64 = @intCast (@max (0, delta.nanoseconds));
    const sec: u64 = @intCast (delta.seconds);
    const days: u64 = @intCast (delta.days);

    try Logger.stderr.writeAll (
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

  fn render (self: @This ()) !void
  {
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .foreground = .{ .Fixed = @intFromEnum (Color.white), },
        .font_style = .{ .bold = true, },
      }, null);
    const elapsed_ds = try self.chrono ();
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .foreground = .{ .Fixed = @This ().colors [(elapsed_ds / 5) % @This ().colors.len], },
        .font_style = .{ .bold = true, },
      }, null);
    try Logger.stderr.writeAll (@This ().patterns [elapsed_ds % (@This ().patterns.len)]);
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .foreground = .{ .Fixed = @intFromEnum (Color.white), },
        .font_style = .{ .bold = true, },
      }, null);
    try Logger.stderr.writeAll (&self.message);
    try ansiterm.format.resetStyle (Logger.stderr);
    try ansiterm.clear.clearFromCursorToLineEnd (Logger.stderr);
    try Logger.stderr.writeByte ('\n');
  }
};

const Buffer = struct
{
  const size: usize = 15000;

  id: [Logger.id_max_length] u8,
  id_length: usize,
  array: std.BoundedArray (u8, @This ().size),
  writer: std.BoundedArray (u8, @This ().size).Writer,

  fn init (id: [] const u8) !@This ()
  {
    if (id.len > Logger.id_max_length) return error.BufferIdTooLong;
    var self: @This () = .{
                            .id = undefined,
                            .id_length = id.len,
                            .array = try std.BoundedArray (u8, @This ().size).init (0),
                            .writer = undefined,
                          };
    std.mem.copyBackwards (u8, &self.id, id [0 .. id.len]);
    self.writer = self.array.writer ();
    return self;
  }
};

const Bar = struct
{
  const colors: [10] u8 = .{ 204, 203, 209, 215, 221, 227, 191, 155, 119, 83, };
  const offsets: [7] *const [3:0] u8 = .{ "▏", "▎", "▍", "▌", "▋", "▊", "▉", };
  const coef = 10;

  max: u32 = 0,
  progress: u32 = 0,
  term_cursor: u32 = 0,
  running: bool = false,
  last: datetime.Datetime = undefined,

  fn init (max: u32) @This ()
  {
    return .{ .max = max, .running = true, .last = datetime.Datetime.now (), };
  }

  fn incr (self: *@This ()) !void
  {
    if (self.progress == self.max) return error.BarMaxReached;
    self.progress = self.progress + 1;
  }

  fn top (_: @This ()) !void
  {
    try Logger.stderr.writeByte (' ');
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .foreground = .{ .Fixed = @intFromEnum (Color.white), },
        .font_style = .{ .bold = true, },
      }, null);
    for (0 .. (Logger.cols - 6)) |_| try Logger.stderr.writeAll ("▁");
    try ansiterm.clear.clearFromCursorToLineEnd (Logger.stderr);
    try Logger.stderr.writeByte ('\n');
  }

  fn middle (self: *@This (), term_max: u32) !void
  {
    const offset_index = self.term_cursor % (@This ().offsets.len + 1);
    const percent = (self.term_cursor * 100) / term_max;
    var buffer: [4] u8 = undefined;
    var i: u16 = 8;

    try Logger.stderr.writeAll ("▕");
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .background = .{ .Fixed = @This ().colors [@min (percent / @This ().colors.len, @This ().colors.len - 1)], },
        .font_style = .{ .bold = true, },
      }, null);
    while (i <= self.term_cursor) { try Logger.stderr.writeByte (' '); i = i + 8; }
    try ansiterm.format.resetStyle (Logger.stderr);
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .foreground = .{ .Fixed = @This ().colors [@min (percent / @This ().colors.len, @This ().colors.len - 1)], },
        .font_style = .{ .bold = true, },
      }, null);
    if (self.term_cursor < term_max and (offset_index > 0)) try Logger.stderr.writeAll (@This ().offsets [offset_index - 1]);
    try ansiterm.format.resetStyle (Logger.stderr);
    if (offset_index == 0) i = i - 8;
    while (i < term_max) { try Logger.stderr.writeByte (' '); i = i + 8; }
    try ansiterm.format.updateStyle (Logger.stderr, .{
        .foreground = .{ .Fixed = @intFromEnum (Color.white), },
        .font_style = .{ .bold = true, },
      }, null);
    try Logger.stderr.writeAll ("▎");
    try Logger.stderr.writeAll (try std.fmt.bufPrint (&buffer, "{d}%", .{ percent, }));
    try ansiterm.clear.clearFromCursorToLineEnd (Logger.stderr);
    try Logger.stderr.writeByte ('\n');
  }

  fn bottom (_: @This ()) !void
  {
    try Logger.stderr.writeByte (' ');
    for (0 .. (Logger.cols - 6)) |_| try Logger.stderr.writeAll ("▔");
    try ansiterm.format.resetStyle (Logger.stderr);
    try ansiterm.clear.clearFromCursorToLineEnd (Logger.stderr);
    try Logger.stderr.writeByte ('\n');
  }

  fn render (self: *@This ()) !bool
  {
    const term_max = (Logger.cols - 6) * 8;
    if (self.term_cursor >= term_max) self.running = false;
    if (!self.running) return false;

    const term_progress = (self.progress * term_max) / self.max;

    var now = datetime.Datetime.now ();
    const delta = now.sub (self.last);
    if (self.term_cursor < term_progress and delta.nanoseconds > 10_000_000)
    {
      const gap = (term_progress - self.term_cursor) / @This ().coef;
      const log = std.math.log2 (@max (gap, 2)) - 1;
      const shift = @min (gap, log);
      self.term_cursor = self.term_cursor + std.math.shl (u32, 1, shift);
      self.last = now;
    }

    try self.top ();
    try self.middle (term_max);
    try self.bottom ();

    return true;
  }
};

// TODO: getters/setters
const Logger = struct
{
  const logs_size: usize = 1024;
  const spins_size: usize = 128;
  const buffers_size = spins_size;

  const id_max_length: usize = 128;

  const space: u16 = 1;
  const time_length: u16 = 8 + space;
  const level_length: u16 = 5 + space;
  const header_length: u16 = time_length + level_length;

  const stderr_file = std.io.getStdErr ();
  const stderr_writer = stderr_file.writer ();
  var buffered_stderr = std.io.bufferedWriter (stderr_writer);
  var stderr = buffered_stderr.writer ();

  var cols: u16 = undefined;
  const separator: u8 = 7;

  logs: std.BoundedArray ([] const u8, logs_size),
  mutex: std.Thread.Mutex = .{},
  condition: std.Thread.Condition = .{},
  looping: bool = true,
  spins: std.BoundedArray (Spin, spins_size),
  buffers: std.BoundedArray (Buffer, buffers_size),
  bar: Bar = undefined,

  fba_buffer: [Buffer.size] u8 = undefined,
  fba: std.heap.FixedBufferAllocator,
  allocator: std.mem.Allocator,

  fn init () !@This ()
  {
    if (!@This ().stderr_file.supportsAnsiEscapeCodes ())
      return error.UnsupportedAnsiEscapeCodes;

    var fba_buffer: [Buffer.size] u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init (&fba_buffer);
    return .{
              .logs       = try std.BoundedArray ([] const u8, logs_size).init (0),
              .spins      = try std.BoundedArray (Spin, spins_size).init (0),
              .buffers    = try std.BoundedArray (Buffer, buffers_size).init (0),
              .fba_buffer = fba_buffer,
              .fba        = fba,
              .allocator  = fba.allocator (),
            };
  }

  fn deinit (self: *@This ()) void
  {
    self.looping = false;
  }

  fn enqueue (self: *@This (), array: std.BoundedArray (u8, Buffer.size)) !void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();

    while (self.logs.slice ().len == logs_size) self.condition.wait (&self.mutex);

    self.logs.appendAssumeCapacity (self.allocator.dupe (u8, array.slice ()) catch |err| blk: {
      if (err == error.OutOfMemory)
      {
        self.fba.reset ();
        self.allocator = self.fba.allocator ();
        break :blk try self.allocator.dupe (u8, array.slice ());
      } else return err;
    });
  }

  fn empty (self: *@This ()) !bool
  {
    if (!self.mutex.tryLock ()) return true;
    defer self.mutex.unlock ();

    var index: usize = 0;
    while (index < self.logs.slice ().len)
    {
      try self.response (self.logs.swapRemove (index));
      index = index + 1;
    }

    while (self.logs.popOrNull ()) |entry| try self.response (entry);

    self.condition.signal ();

    return (index == 0);
  }

  fn log_response (self: *@This (), entry: [] const u8) !void
  {
    var log = try Log.init (entry);
    try log.render ();
    try self.animation ();
  }

  fn spin_response (self: *@This (), entry: [] const u8) !void
  {
    if (self.spins.slice ().len == spins_size) return error.MaxSpinsReached;

    var it = std.mem.tokenizeScalar (u8, entry [2 ..], @This ().separator);
    var index: usize = 0;
    var pair: [2][] const u8 = undefined;
    while (it.next ()) |token|
    {
      switch (index)
      {
        0, 1 => pair [index] = token,
        else => return error.NullCharacterInSpinMessageOrSpinId,
      }
      index = index + 1;
    }

    self.spins.appendAssumeCapacity (try Spin.init (pair [0], pair [1]));
  }

  fn kill_response (self: *@This (), entry: [] const u8) !void
  {
    if (self.spins.slice ().len == 0) return;

    var index: usize = 0;

    while (index < self.spins.slice ().len)
    {
      if (std.mem.eql (u8, self.spins.get (index).id [0 .. self.spins.get (index).id_length], entry [1 ..])) break;
      index = index + 1;
    } else return error.UnknownSpinId;

    _ = self.spins.orderedRemove (index);
  }

  fn buffer_response (self: *@This (), entry: [] const u8) !void
  {
    if (self.buffers.slice ().len == buffers_size) return error.MaxBuffersReached;

    var it = std.mem.tokenizeScalar (u8, entry [2 ..], @This ().separator);
    var index: usize = 0;
    var pair: [2][] const u8 = undefined;
    while (it.next ()) |token|
    {
      switch (index)
      {
        0, 1 => pair [index] = token,
        else => return error.NullCharacterInBufferMessageOrBufferId,
      }
      index = index + 1;
    }

    index = 0;
    while (index < self.buffers.slice ().len)
    {
      if (std.mem.eql (u8, self.buffers.get (index).id [0 .. self.buffers.get (index).id_length], pair [0])) break;
      index = index + 1;
    } else self.buffers.appendAssumeCapacity (try Buffer.init (pair [0]));

    if (self.buffers.get (index).array.slice ().len + pair [1].len + 1 >= Buffer.size) return error.BufferSizeOverflow;
    self.buffers.slice ()[index].array.appendSliceAssumeCapacity (pair [1]);
    self.buffers.slice ()[index].array.appendAssumeCapacity (@This ().separator);
  }

  fn flush_response (self: *@This (), entry: [] const u8) !void
  {
    if (self.buffers.slice ().len == 0) return;

    var index: usize = 0;

    while (index < self.buffers.slice ().len)
    {
      if (std.mem.eql (u8, self.buffers.get (index).id [0 .. self.buffers.get (index).id_length], entry [1 ..])) break;
      index = index + 1;
    } else return error.UnknownBufferId;

    var it = std.mem.tokenizeScalar (u8, self.buffers.get (index).array.slice (), @This ().separator);
    while (it.next ()) |token| try self.log_response (token);

    _ = self.buffers.orderedRemove (index);
  }

  fn bar_response (self: *@This (), entry: [] const u8) !void
  {
    self.bar = Bar.init (try std.fmt.parseInt (u32, entry [1 ..], 10));
  }

  fn progress_response (self: *@This ()) !void
  {
    try self.bar.incr ();
  }

  fn response (self: *@This (), entry: [] const u8) !void
  {
    switch (entry [0])
    {
      'B'  => try self.buffer_response (entry),
      'F'  => try self.flush_response (entry),
      'S'  => try self.spin_response (entry),
      'K'  => try self.kill_response (entry),
      'P'  => try self.bar_response (entry),
      'p'  => try self.progress_response (),
      else => try self.log_response (entry),
    }
    self.allocator.free (entry);
  }

  fn animation (self: *@This ()) !void
  {
    for (self.spins.slice ()) |spin| try spin.render ();
    const rendered_bar = try self.bar.render ();
    try ansiterm.clear.clearFromCursorToScreenEnd (@This ().stderr);
    for (self.spins.slice ()) |_| try ansiterm.cursor.cursorPreviousLine (@This ().stderr, 1);
    if (rendered_bar) for (0 .. 3) |_| try ansiterm.cursor.cursorPreviousLine (@This ().stderr, 1);
    try @This ().buffered_stderr.flush (); // don't forget to flush!
  }

  fn loop (self: *@This ()) !void
  {
    try ansiterm.cursor.hideCursor (@This ().stderr);
    defer
    {
      ansiterm.clear.clearFromCursorToScreenEnd (@This ().stderr) catch {};
      ansiterm.cursor.showCursor (@This ().stderr) catch {};
      @This ().buffered_stderr.flush () catch {}; // don't forget to flush!
    }
    while (self.looping or self.logs.slice ().len > 0 or self.bar.running
      or self.spins.slice ().len > 0 or self.buffers.slice ().len > 0)
    {
      @This ().cols = (try termsize.termSize (@This ().stderr_file)).?.width;
      if (try self.empty ()) try self.animation ();
    }
  }
};

pub fn main () !void
{
  var logger = try Logger.init ();

  const stdin_file = std.io.getStdIn ();
  const stdin_reader = stdin_file.reader ();
  var buffered_stdin = std.io.bufferedReader (stdin_reader);
  const stdin = buffered_stdin.reader ();

  var buffer_array: std.BoundedArray (u8, Buffer.size) = undefined;
  const buffer = buffer_array.writer ();

  const thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });
  defer thread.join ();
  defer logger.deinit ();

  var looping = true;

  while (looping)
  {
    buffer_array = try std.BoundedArray (u8, Buffer.size).init (0);

    stdin.streamUntilDelimiter (buffer, '\n', Buffer.size) catch |err| {
      if (err == error.EndOfStream) looping = false else return err;
    };

    if (looping or buffer_array.slice ().len > 0)
      try logger.enqueue (buffer_array);
  }
}
