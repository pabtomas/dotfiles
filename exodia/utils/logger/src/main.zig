const root = @This ();
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

  header: @This ().Header,
  message: [] const u8,
  first: bool = true,

  fn init (request: *Request) @This ()
  {
    return .{
      .header = request.kind.log,
      .message = request.data.?.message,
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

  message: [] const u8,
  birth: datetime.Datetime,

  fn init (message: [] const u8) @This ()
  {
    return .{
      .message = message,
      .birth = datetime.Datetime.now (),
    };
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

  fn render (self: *@This (), first: bool) !void
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

  fn incr (self: *@This ()) void
  {
    std.debug.assert (self.progress < self.max);
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

const Request = struct
{
  const DataTag = enum { message, max, };
  const Data = union (DataTag)
  {
    message: [] const u8,
    max: u32,
  };

  const KindTag = enum { buffer, flush, spin, kill, bar, progress, log, };
  const Kind = union (KindTag)
  {
    buffer: [] const u8,
    flush: [] const u8,
    spin: [] const u8,
    kill: [] const u8,
    bar: void,
    progress: void,
    log: Log.Header,
  };

  kind: @This ().Kind,
  data: ?@This ().Data = null,
};

const Queue = struct
{
  id: [] const u8,
  list: std.DoublyLinkedList (Request) = .{},

  fn init (id: [] const u8) @This ()
  {
    return .{ .id = id, };
  }

  fn append (self: *@This (), allocator: *const std.mem.Allocator, request: Request) !void
  {
    const node = try allocator.create (std.DoublyLinkedList (Request).Node);
    node.* = .{ .data = request, };
    self.list.append (node);
  }
};

const Logger = struct
{
  const space: u16 = 1;
  const time_length: u16 = 8 + @This ().space;
  const level_length: u16 = 5 + @This ().space;
  const header_length: u16 = @This ().time_length + @This ().level_length;

  const stderr_file = std.io.getStdErr ();
  const stderr_writer = stderr_file.writer ();
  var buffered_stderr = std.io.bufferedWriter (stderr_writer);
  var stderr = buffered_stderr.writer ();

  var cols: ?u16 = null;

  mutex: std.Thread.Mutex = .{},
  requests: Queue,
  spins: std.StringHashMap (Spin),
  buffers: std.StringHashMap (Queue),
  bar: Bar = undefined,
  allocator: *const std.mem.Allocator,
  looping: bool = true,

  fn init (nproc: u32, allocator: *const std.mem.Allocator) !@This ()
  {
    if (@This ().stderr_file.supportsAnsiEscapeCodes ()) @This ().cols = 0;
    var self: @This () = .{
      .requests  = Queue.init ("root"),
      .allocator = allocator,
      .spins     = undefined,
      .buffers   = undefined,
    };
    self.spins = std.StringHashMap (Spin).init (self.allocator.*);
    self.buffers = std.StringHashMap (Queue).init (self.allocator.*);
    try self.spins.ensureTotalCapacity (nproc);
    try self.buffers.ensureTotalCapacity (nproc);
    return self;
  }

  fn deinit (self: *@This ()) void
  {
    self.looping = false;
  }

  fn enqueue (self: *@This (), request: Request) !void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();
    try self.requests.append (self.allocator, request);
  }

  fn returnType (comptime name: [] const [] const u8) type
  {
    var ptr = root;
    for (0 .. name.len - 1) |i| ptr = @field (ptr, name [i]);
    return (@typeInfo (@TypeOf (@field (ptr, name [name.len - 1]))).Fn.return_type orelse void);
  }

  fn enqueueTrace (self: *@This (), comptime name: [] const [] const u8, args: anytype) !@This ().returnType (name)
  {
    comptime var ptr = root;
    comptime var buf: [] const u8 = "";
    inline for (0 .. name.len - 1) |i|
    {
      buf = buf ++ name [i] ++ ".";
      ptr = @field (ptr, name [i]);
    }
    buf = buf ++ name [name.len - 1] ++ " (";
    inline for (0 .. args.len - 1) |i| buf = buf ++ std.fmt.comptimePrint ("{any}, ", .{args[i]});
    buf = buf ++ std.fmt.comptimePrint ("{any})", .{ args [args.len - 1], });
    try self.enqueue (.{ .kind = .{ .log = .TRACE, }, .data = .{ .message = buf, }, });
    return @call (.auto, @field (ptr, name [name.len - 1]), args);
  }

  fn dequeue (self: *@This ()) !bool
  {
    if (!self.mutex.tryLock ()) return false;
    defer self.mutex.unlock ();
    var log_rendered = false;
    while (self.requests.list.popFirst ()) |request|
    {
      log_rendered = try self.response (&request.data) or log_rendered;
      self.allocator.destroy (request);
    }
    return log_rendered;
  }

  fn logResponse (self: *@This (), request: *Request) !void
  {
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.log);
    std.debug.assert (std.meta.activeTag (request.data.?) == Request.Data.message);
    var log = Log.init (request);
    var looping = true;
    while (looping)
    {
      looping = try log.render ();
      try self.animation ();
    }
  }

  fn spinResponse (self: *@This (), request: *Request) void
  {
    std.debug.assert (self.spins.count () < self.spins.capacity ());
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.spin);
    std.debug.assert (request.kind.spin.len > 0);
    std.debug.assert (!self.spins.contains (request.kind.spin));
    std.debug.assert (request.data != null);
    std.debug.assert (std.meta.activeTag (request.data.?) == Request.Data.message);
    self.spins.putAssumeCapacity (request.kind.spin, Spin.init (request.data.?.message));
  }

  fn killResponse (self: *@This (), request: *Request) void
  {
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.kill);
    std.debug.assert (request.kind.kill.len > 0);
    std.debug.assert (self.spins.remove (request.kind.kill));
  }

  fn bufferResponse (self: *@This (), request: *Request) !void
  {
    std.debug.assert (self.buffers.count () < self.buffers.capacity ());
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.buffer);
    std.debug.assert (request.kind.buffer.len > 0);
    if (!self.buffers.contains (request.kind.buffer))
      self.buffers.putAssumeCapacity (request.kind.buffer, Queue.init (request.kind.buffer));
    try self.buffers.getPtr (request.kind.buffer).?.append (self.allocator, request.*);
  }

  fn flushResponse (self: *@This (), request: *Request) void
  {
    std.debug.assert (self.buffers.count () > 0);
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.flush);
    std.debug.assert (request.kind.flush.len > 0);
    std.debug.assert (self.buffers.contains (request.kind.flush));
    while (self.buffers.getPtr (request.kind.flush).?.list.pop ()) |node| self.requests.list.prepend (node);
  }

  fn barResponse (self: *@This (), request: *Request) void
  {
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.bar);
    std.debug.assert (request.data != null);
    std.debug.assert (std.meta.activeTag (request.data.?) == Request.Data.max);
    std.debug.assert (request.data.?.max > 0);
    self.bar = Bar.init (request.data.?.max);
  }

  fn progressResponse (self: *@This ()) void
  {
    self.bar.incr ();
  }

  fn response (self: *@This (), request: *Request) !bool
  {
    var log_rendered = false;
    switch (request.kind)
    {
      .buffer   => try self.bufferResponse (request),
      .flush    => self.flushResponse (request),
      .spin     => self.spinResponse (request),
      .kill     => self.killResponse (request),
      .bar      => self.barResponse (request),
      .progress => self.progressResponse (),
      .log      => {
                     try self.logResponse (request);
                     log_rendered = true;
                   },
    }
    return log_rendered;
  }

  fn animation (self: *@This ()) !void
  {
    var spin_rendered = false;
    var it = self.spins.keyIterator ();
    while (it.next ()) |key|
    {
      try self.spins.getPtr (key.*).?.render (!spin_rendered);
      spin_rendered = true;
    }
    const bar_rendered = try self.bar.render (!spin_rendered);
    try @This ().clearFromCursorToScreenEnd ();
     for (0 .. self.spins.count ()) |i|
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
      self.spins.deinit ();
      self.buffers.deinit ();
      JdzGlobalAllocator.deinit ();
      JdzGlobalAllocator.deinitThread ();
    }
    try @This ().hideCursor ();
    while (self.looping or self.requests.list.len > 0 or self.bar.running
      or self.spins.count () > 0 or self.buffers.count () > 0)
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

fn mainHandled (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = .{ .message = "Test", }, });
  try logger.enqueue (.{ .kind = .{ .log = .WARN, }, .data = .{ .message = "Test", }, });
  try logger.enqueueTrace (&[_][] const u8 { "std", "debug", "print", }, .{ "{s}\n", .{ "Test", } });
  try logger.enqueue (.{ .kind = .{ .spin = "cache", }, .data = .{ .message = "In progress ...", }, });
  std.time.sleep (5_000_000_000);
  try logger.enqueue (.{ .kind = .{ .kill = "cache", }, });

  //var looping = true;
  //while (looping)
  //{
  //}
}

fn mainWith (allocator: *const std.mem.Allocator) !void
{
  const nproc = try std.Thread.getCpuCount ();
  var logger = try Logger.init (@intCast (nproc), allocator);

  const thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });
  defer thread.join ();
  defer logger.deinit ();

  mainHandled (&logger) catch |err| try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = .{ .message = @errorName (err), }, });
}

fn fatal (err: [] const u8) void
{
  const now = datetime.Datetime.now ();
  std.debug.print ("{d:0>2}:{d:0>2}:{d:0>2} \x1B[38;5;215m\x1B[1mFATAL\x1B[m {s}\n",
    .{ now.time.hour, now.time.minute, now.time.second, err, });
}

pub fn main () void
{
  const allocator = JdzGlobalAllocator.allocator ();
  mainWith (&allocator) catch |err| fatal (@errorName (err));
}

test "leak"
{
  const allocator = std.testing.allocator;
  try mainWith (&allocator);
}
