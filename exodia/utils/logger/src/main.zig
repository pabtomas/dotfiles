const std = @import ("std");

const ansiterm = @import ("ansiterm");
const datetime = @import ("datetime").datetime;
const jdz = @import ("jdz");
const JdzGlobalAllocator = jdz.JdzGlobalAllocator (.{});
const termsize = @import ("termsize");

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
  const Header = enum
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

    fn render (self: @This (), message: [] const u8, first: *bool) !void
    {
      try self.timestamp ();
      if (first.*)
      {
        first.* = false;
        try Logger.updateStyle (.{
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
        try self.tag ();
        try Logger.resetStyle ();
      } else if (self != .RAW) {
        try Logger.stderr.writeAll (" " ** Logger.level_length);
      }
      try Logger.stderr.writeAll (message);
      try Logger.clearFromCursorToLineEnd ();
    }
  };

  header: Header,
  message: [] const u8,
  first: bool = true,

  fn init (request: [] const u8) !@This ()
  {
    return .{
      .header = switch (request [0])
      {
        '0'  => .ERROR,
        '1'  => .WARN,
        '2'  => .INFO,
        '3'  => .NOTE,
        '4'  => .DEBUG,
        '5'  => .TRACE,
        '6'  => .VERB,
        '-'  => .RAW,
        else => {
          std.debug.print ("First character: '{c}' [{d:0>3}]\nRequest: '{s}'\n",
            .{ request [0], request [0], request, });
          return error.UnknownLogRequest;
        },
      },
      .message = request [1 ..],
    };
  }

  fn render (self: *@This ()) !bool
  {
    var max_entry_length: usize = undefined;

    max_entry_length = if (Logger.cols == null) self.message.len
                       else @min (Logger.cols.? - Logger.header_length, self.message.len);
    try self.header.render (self.message [0 .. max_entry_length], &self.first);
    self.message = self.message [max_entry_length ..];
    try Logger.stderr.writeByte ('\n');
    return (self.message.len > 0);
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
    std.mem.copyBackwards (u8, &self.id, id [0 .. id.len]);
    std.mem.copyBackwards (u8, &self.message, message [0 .. @min (message.len, @This ().message_max_length)]);
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

  fn render (self: @This (), first: bool) !void
  {
    if (Logger.cols == null) return;
    if (!first) try Logger.stderr.writeByte ('\n');
    try Logger.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    const elapsed_ds = try self.chrono ();
    try Logger.updateStyle (.{
      .foreground = .{ .Fixed = @This ().colors [(elapsed_ds / 5) % @This ().colors.len], },
      .font_style = .{ .bold = true, },
    });
    try Logger.stderr.writeAll (@This ().patterns [elapsed_ds % (@This ().patterns.len)]);
    try Logger.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    const max_entry_length = Logger.cols.? - Logger.header_length;
    try Logger.stderr.writeAll (self.message [0 .. @min (self.message.len, max_entry_length)]);
    try Logger.resetStyle ();
    try Logger.clearFromCursorToLineEnd ();
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

  fn top (_: @This (), first: bool) !void
  {
    if (!first) try Logger.stderr.writeByte ('\n');
    try Logger.stderr.writeByte (' ');
    try Logger.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    for (0 .. (Logger.cols.? - 6)) |_| try Logger.stderr.writeAll ("▁");
    try Logger.clearFromCursorToLineEnd ();
    try Logger.stderr.writeByte ('\n');
  }

  fn middle (self: *@This (), term_max: u32) !void
  {
    const offset_index = self.term_cursor % (@This ().offsets.len + 1);
    const percent = (self.term_cursor * 100) / term_max;
    var buffer: [4] u8 = undefined;
    var i: u16 = 8;

    try Logger.stderr.writeAll ("▕");
    try Logger.updateStyle (.{
      .background = .{ .Fixed = @This ().colors [@min (percent / @This ().colors.len, @This ().colors.len - 1)], },
      .font_style = .{ .bold = true, },
    });
    while (i <= self.term_cursor) { try Logger.stderr.writeByte (' '); i = i + 8; }
    try Logger.resetStyle ();
    try Logger.updateStyle (.{
      .foreground = .{ .Fixed = @This ().colors [@min (percent / @This ().colors.len, @This ().colors.len - 1)], },
      .font_style = .{ .bold = true, },
    });
    if (self.term_cursor < term_max and (offset_index > 0)) try Logger.stderr.writeAll (@This ().offsets [offset_index - 1]);
    try Logger.resetStyle ();
    if (offset_index == 0) i = i - 8;
    while (i < term_max) { try Logger.stderr.writeByte (' '); i = i + 8; }
    try Logger.updateStyle (.{
      .foreground = .{ .Fixed = @intFromEnum (Color.white), },
      .font_style = .{ .bold = true, },
    });
    try Logger.stderr.writeAll ("▎");
    try Logger.stderr.writeAll (try std.fmt.bufPrint (&buffer, "{d}%", .{ percent, }));
    try Logger.clearFromCursorToLineEnd ();
    try Logger.stderr.writeByte ('\n');
  }

  fn bottom (_: @This ()) !void
  {
    try Logger.stderr.writeByte (' ');
    for (0 .. (Logger.cols.? - 6)) |_| try Logger.stderr.writeAll ("▔");
    try Logger.resetStyle ();
    try Logger.clearFromCursorToLineEnd ();
  }

  fn render (self: *@This (), first: bool) !bool
  {
    if (Logger.cols == null) return false;
    const term_max = (Logger.cols.? - 6) * 8;
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

    try self.top (first);
    try self.middle (term_max);
    try self.bottom ();

    return true;
  }
};

const RequestsBuffer = struct
{
  const size: usize = 1024;

  id: [Logger.id_max_length] u8,
  id_length: usize,
  array: std.BoundedArray ([] u8, @This ().size),

  fn init (id: [] const u8) !@This ()
  {
    if (id.len > Logger.id_max_length) return error.RequestsBufferIdTooLong;
    var self: @This () = .{
                            .id = undefined,
                            .id_length = id.len,
                            .array = try std.BoundedArray ([] u8, @This ().size).init (0),
                          };
    std.mem.copyBackwards (u8, &self.id, id [0 .. id.len]);
    return self;
  }
};

const Logger = struct
{
  const spins_size: usize = 128;

  // Here 121 is a magic number: if I increase it to 122: Segfault at runtime
  const buffers_size: usize = 121;
  //const buffers_size = spins_size;

  const id_max_length: usize = 128;

  const buffer_length: usize = 65536;

  const space: u16 = 1;
  const time_length: u16 = 8 + @This ().space;
  const level_length: u16 = 5 + @This ().space;
  const header_length: u16 = @This ().time_length + @This ().level_length;

  const stderr_file = std.io.getStdErr ();
  const stderr_writer = stderr_file.writer ();
  var buffered_stderr = std.io.bufferedWriter (stderr_writer);
  var stderr = buffered_stderr.writer ();

  var cols: ?u16 = null;
  const separator: u8 = 7;

  requests: RequestsBuffer,
  mutex: std.Thread.Mutex = .{},
  condition: std.Thread.Condition = .{},
  looping: bool = true,
  spins: std.BoundedArray (Spin, @This ().spins_size),
  buffers: std.BoundedArray (RequestsBuffer, @This ().buffers_size),
  flush: ?usize = null,
  bar: Bar = undefined,
  allocator: std.mem.Allocator,

  fn init () !@This ()
  {
    if (@This ().stderr_file.supportsAnsiEscapeCodes ()) @This ().cols = 0;
    return .{
      .requests   = try RequestsBuffer.init ("root"),
      .spins      = try std.BoundedArray (Spin, @This ().spins_size).init (0),
      .buffers    = try std.BoundedArray (RequestsBuffer, @This ().buffers_size).init (0),
      .allocator = JdzGlobalAllocator.allocator (),
    };
  }

  fn deinit (self: *@This ()) void
  {
    self.looping = false;
  }

  fn addRequest (self: *@This (), requests: *RequestsBuffer, slice: [] const u8) !void
  {
    if (requests.array.len >= RequestsBuffer.size) return error.RequestsBufferSizeOverflow;

    requests.array.len += 1;
    requests.array.slice ()[requests.array.len - 1] = try self.allocator.alloc (u8, slice.len);
    @memcpy (requests.array.slice ()[requests.array.len - 1], slice);
  }

  fn enqueue (self: *@This (), array: *std.BoundedArray (u8, @This ().buffer_length)) !void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();

    while (self.requests.array.len >= RequestsBuffer.size) self.condition.wait (&self.mutex);

    try self.addRequest (&self.requests, array.slice ());
  }

  fn emptyRequestsBuffer (self: *@This (), requests: *RequestsBuffer) !bool
  {
    var index: usize = 0;
    var log_rendered = false;
    while (index < requests.array.len)
    {
      log_rendered = try self.response (requests.array.swapRemove (index)) or log_rendered;
      index = index + 1;
    }

    while (requests.array.popOrNull ()) |request|
      log_rendered = try self.response (request) or log_rendered;
    return log_rendered;
  }

  fn dequeue (self: *@This ()) !bool
  {
    if (!self.mutex.tryLock ()) return false;
    defer self.mutex.unlock ();
    var looping = true;
    var log_rendered = false;

    while (looping)
    {
      if (self.flush) |flush|
      {
        log_rendered = self.emptyRequestsBuffer (&self.buffers.slice ()[flush]) catch |err| {
          if (err == error.Flushed) return error.FlushOccuredDuringFlush else return err;
        } or log_rendered;
        _ = self.buffers.orderedRemove (flush);
        self.flush = null;
      }

      log_rendered = self.emptyRequestsBuffer (&self.requests) catch |err| {
        if (err == error.Flushed) continue else return err;
      } or log_rendered;

      looping = false;
    }

    self.condition.signal ();

    return log_rendered;
  }

  fn logResponse (self: *@This (), entry: [] const u8) !void
  {
    var log = try Log.init (entry);
    var looping = true;
    while (looping)
    {
      looping = try log.render ();
      try self.animation ();
    }
  }

  fn spinResponse (self: *@This (), entry: [] const u8) !void
  {
    if (self.spins.len == @This ().spins_size) return error.MaxSpinsReached;

    var it = std.mem.tokenizeScalar (u8, entry [2 ..], @This ().separator);
    var index: usize = 0;
    var pair: [2][] const u8 = undefined;
    while (it.next ()) |token|
    {
      switch (index)
      {
        0, 1 => pair [index] = token,
        else => return error.SeparatorInSpinMessageOrSpinId,
      }
      index = index + 1;
    }

    self.spins.appendAssumeCapacity (try Spin.init (pair [0], pair [1]));
  }

  fn killResponse (self: *@This (), entry: [] const u8) !void
  {
    if (self.spins.len == 0) return;

    var index: usize = 0;

    while (index < self.spins.len)
    {
      if (std.mem.eql (u8, self.spins.get (index).id [0 .. self.spins.get (index).id_length], entry [1 ..])) break;
      index = index + 1;
    } else return error.UnknownSpinId;

    _ = self.spins.orderedRemove (index);
  }

  fn bufferResponse (self: *@This (), entry: [] const u8) !void
  {
    if (self.buffers.len == @This ().buffers_size) return error.MaxRequestsBuffersReached;

    var it = std.mem.tokenizeScalar (u8, entry [2 ..], @This ().separator);
    var index: usize = 0;
    var pair: [2][] const u8 = undefined;
    while (it.next ()) |token|
    {
      switch (index)
      {
        0, 1 => pair [index] = token,
        else => return error.SeparatorInRequestsBufferMessageOrRequestsBufferId,
      }
      index = index + 1;
    }

    index = 0;
    while (index < self.buffers.len)
    {
      if (std.mem.eql (u8, self.buffers.get (index).id [0 .. self.buffers.get (index).id_length], pair [0])) break;
      index = index + 1;
    } else self.buffers.appendAssumeCapacity (try RequestsBuffer.init (pair [0]));

    try self.addRequest (&self.buffers.slice ()[index], pair [1]);
  }

  fn flushResponse (self: *@This (), entry: [] const u8) !void
  {
    if (self.buffers.len == 0) return;

    var index: usize = 0;

    while (index < self.buffers.len)
    {
      if (std.mem.eql (u8, self.buffers.get (index).id [0 .. self.buffers.get (index).id_length], entry [1 ..])) break;
      index = index + 1;
    } else return error.UnknownRequestsBufferId;

    self.flush = index;
  }

  fn barResponse (self: *@This (), entry: [] const u8) !void
  {
    self.bar = Bar.init (try std.fmt.parseInt (u32, entry [1 ..], 10));
  }

  fn progressResponse (self: *@This ()) !void
  {
    try self.bar.incr ();
  }

  fn response (self: *@This (), request: [] const u8) !bool
  {
    var log_rendered = false;
    switch (request [0])
    {
      'B'  => try self.bufferResponse (request),
      'F'  => {
                try self.flushResponse (request);
                self.allocator.free (request);
                return error.Flushed;
              },
      'S'  => try self.spinResponse (request),
      'K'  => try self.killResponse (request),
      'P'  => try self.barResponse (request),
      'p'  => try self.progressResponse (),
      else => {
                try self.logResponse (request);
                log_rendered = true;
              },
    }
    self.allocator.free (request);
    return log_rendered;
  }

  fn animation (self: *@This ()) !void
  {
    var spin_rendered = false;
    for (0 .. self.spins.len) |i|
    {
      try self.spins.slice ()[i].render (!spin_rendered);
      spin_rendered = true;
    }
    const bar_rendered = try self.bar.render (!spin_rendered);
    try @This ().clearFromCursorToScreenEnd ();
     for (0 .. self.spins.len) |i|
       if (i == 0) try @This ().cursorStartLine ()
       else try @This ().cursorPreviousLine ();
     if (bar_rendered) for (0 .. 3) |i|
       if (!spin_rendered and i == 0) try @This ().cursorStartLine ()
       else try @This ().cursorPreviousLine ();
    try @This ().buffered_stderr.flush (); // don't forget to flush!
  }

  fn updateCols () !void
  {
    if (@This ().cols != null)
      @This ().cols = (try termsize.termSize (@This ().stderr_file)).?.width;
  }

  fn loop (self: *@This ()) !void
  {
    defer
    {
      @This ().clearFromCursorToScreenEnd () catch {};
      @This ().showCursor () catch {};
      @This ().buffered_stderr.flush () catch {}; // don't forget to flush!
      JdzGlobalAllocator.deinit ();
      JdzGlobalAllocator.deinitThread ();
    }
    try @This ().hideCursor ();
    while (self.looping or self.requests.array.len > 0 or self.bar.running
      or self.spins.len > 0 or self.buffers.len > 0)
    {
      try @This ().updateCols ();
      if (!try self.dequeue ()) try self.animation ();
    }
  }

  fn clearFromCursorToLineEnd () !void
  {
    if (@This ().cols != null)
      try ansiterm.clear.clearFromCursorToLineEnd (@This ().stderr);
  }

  fn clearFromCursorToScreenEnd () !void
  {
    if (@This ().cols != null)
      try ansiterm.clear.clearFromCursorToScreenEnd (@This ().stderr);
  }

  fn showCursor () !void
  {
    if (@This ().cols != null) try ansiterm.cursor.showCursor (@This ().stderr);
  }

  fn hideCursor () !void
  {
    if (@This ().cols != null) try ansiterm.cursor.hideCursor (@This ().stderr);
  }

  fn cursorStartLine () !void
  {
    if (@This ().cols != null)
      try ansiterm.cursor.setCursorColumn (@This ().stderr, 0);
  }

  fn cursorPreviousLine () !void
  {
    if (@This ().cols != null)
      try ansiterm.cursor.cursorPreviousLine (@This ().stderr, 1);
  }

  fn updateStyle (style: ansiterm.style.Style) !void
  {
    if (@This ().cols != null)
      try ansiterm.format.updateStyle (@This ().stderr, style, null);
  }

  fn resetStyle () !void
  {
    if (@This ().cols != null) try ansiterm.format.resetStyle (@This ().stderr);
  }
};

pub fn main () !void
{
  var logger = try Logger.init ();

  const stdin_file = std.io.getStdIn ();
  const stdin_reader = stdin_file.reader ();
  var buffered_stdin = std.io.bufferedReader (stdin_reader);
  const stdin = buffered_stdin.reader ();

  var buffer_array: std.BoundedArray (u8, Logger.buffer_length) = undefined;
  const buffer = buffer_array.writer ();

  const thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });
  defer thread.join ();
  defer logger.deinit ();

  var looping = true;

  while (looping)
  {
    buffer_array = try std.BoundedArray (u8, Logger.buffer_length).init (0);

    stdin.streamUntilDelimiter (buffer, '\n', Logger.buffer_length) catch |err| {
      if (err == error.EndOfStream) looping = false else return err;
    };

    if (looping or buffer_array.len > 0)
      try logger.enqueue (&buffer_array);
  }
}
