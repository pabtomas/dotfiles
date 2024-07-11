const std = @import ("std");

const termsize = @import ("termsize");
const datetime = @import ("datetime").datetime;

const EscapeCode = enum
{
  const Color = enum (u8)
  {
    red    = 204,
    yellow = 227,
    green  = 119,
    cyan   = 81,
    blue   = 69,
    purple = 135,
    pink   = 207,
    white  = 15,
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

    fn render (self: @This ()) !void
    {
      var buffer: [3] u8 = undefined;
      try Logger.stderr.writeAll (
        try std.fmt.bufPrint (&buffer, "{d}", .{ @intFromEnum (self), }));
    }
  };

  const Options = struct
  {
    color: ?EscapeCode.Color = null,
  };

  reset,
  bold,
  fg,
  bg,
  erase_until_end_of_line,
  previous_line,

  fn render (self: @This (), options: Options) !void
  {
    return switch (self)
    {
      .reset => try Logger.stderr.writeAll ("\u{001B}[m"),
      .bold  => try Logger.stderr.writeAll ("\u{001B}[1m"),
      .fg    => {
        try Logger.stderr.writeAll ("\u{001B}[38;5;");
        try options.color.?.render ();
        try Logger.stderr.writeByte ('m');
      },
      .bg    => {
        try Logger.stderr.writeAll ("\u{001B}[48;5;");
        try options.color.?.render ();
        try Logger.stderr.writeByte ('m');
      },
      .erase_until_end_of_line => try Logger.stderr.writeAll ("\u{001B}[J"),
      .previous_line => try Logger.stderr.writeAll ("\u{001B}[F"),
    };
  }
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
        try EscapeCode.bold.render (.{});
        switch (self)
        {
          .ERROR => try EscapeCode.fg.render (.{ .color = .red, }),
          .WARN  => try EscapeCode.fg.render (.{ .color = .yellow, }),
          .INFO  => try EscapeCode.fg.render (.{ .color = .green, }),
          .NOTE  => try EscapeCode.fg.render (.{ .color = .cyan, }),
          .DEBUG => try EscapeCode.fg.render (.{ .color = .blue, }),
          .TRACE => try EscapeCode.fg.render (.{ .color = .purple, }),
          .VERB  => try EscapeCode.fg.render (.{ .color = .pink, }),
          .RAW   => {},
        }
        try self.tag ();
        try EscapeCode.reset.render (.{});
      } else if (self != .RAW) {
        try Logger.stderr.writeAll (" " ** Logger.level_length);
      }
      try Logger.stderr.writeAll (message);
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
                         else => return error.NotLogRequest,
                       },
              .message = entry [1 ..],
            };
  }

  fn render (self: *@This ()) !void
  {
    var max_entry_length: usize = undefined;

    while (self.message.len > 0)
    {
      //max_length = @as (usize, (try termsize.termSize (@This ().stderr_file)).?.width - @This ().header_length);
      max_entry_length = @min (10, self.message.len);
      try self.level.render (self.message [0 .. max_entry_length], &self.header);
      self.message = self.message [max_entry_length ..];
      try Logger.stderr.writeByte ('\n');
      try Logger.buffered_stderr.flush (); // don't forget to flush!
    }
  }
};

const Spin = struct
{
  const id_max_length: usize = 128;
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

  id: [id_max_length] u8,
  id_length: usize,
  message: [message_max_length] u8,
  birth: datetime.Datetime,

  fn init (id: [] const u8, message: [] const u8) !@This ()
  {
    if (id.len > id_max_length) return error.SpinIdTooLong;
    var self: @This () = .{
                            .id = undefined,
                            .id_length = id.len,
                            .message = undefined,
                            .birth = datetime.Datetime.now (),
                          };
    const max_entry_length = @as (usize, (try termsize.termSize (Logger.stderr_file)).?.width - Logger.header_length);
    std.mem.copyBackwards (u8, &self.id, id [0 .. id.len]);
    std.mem.copyBackwards (u8, &self.message, message [0 .. @min (max_entry_length, @min (message.len, message_max_length))]);
    return self;
  }

  fn getId (self: @This ()) [] const u8
  {
    return self.id [0 .. self.id_length];
  }

  fn render (self: @This ()) !void
  {
    var now = datetime.Datetime.now ();
    const delta = now.sub (self.birth);
    var buffer: [8] u8 = undefined;
    const ns = @as (u64, @intCast (@max (0, delta.nanoseconds)));
    const sec = @as (u64, @intCast (delta.seconds));
    const days = @as (u64, @intCast (delta.days));
    const elapsed_ds = (days * std.time.s_per_day + sec) * ds_per_s + ns / ns_per_ds;

    try EscapeCode.bold.render (.{});
    try EscapeCode.fg.render (.{ .color = .white, });
    try Logger.stderr.writeAll (
      if (days == 0 and sec < 10) try std.fmt.bufPrint (&buffer, "    {d}.{d:0>2}", .{ sec, ns / ns_per_cs, })
      else if (days == 0 and sec < std.time.s_per_min) try std.fmt.bufPrint (&buffer, "   {d:0>2}.{d:0>2}", .{ sec, ns / ns_per_cs, })
      else if (days == 0 and sec < 10 * std.time.s_per_min) try std.fmt.bufPrint (&buffer, "    {d}:{d:0>2}", .{ sec / std.time.s_per_min, sec % std.time.s_per_min, })
      else if (days == 0 and sec < std.time.s_per_hour) try std.fmt.bufPrint (&buffer, "   {d:0>2}:{d:0>2}", .{ sec / std.time.s_per_min, sec % std.time.s_per_min, })
      else if (days == 0 and sec < 10 * std.time.s_per_hour) try std.fmt.bufPrint (&buffer, " {d}:{d:0>2}:{d:0>2}", .{ sec / std.time.s_per_hour, (sec / std.time.s_per_min) % min_per_hour, sec % std.time.s_per_min, })
      else if (days < 4 or sec < 4 * std.time.s_per_hour) try std.fmt.bufPrint (&buffer, "{d}:{d:0>2}:{d:0>2}", .{ (days * hour_per_day) + (sec / std.time.s_per_hour), (sec / std.time.s_per_min) % min_per_hour, sec % std.time.s_per_min, })
      else "--:--:-- "
    );
    try EscapeCode.fg.render (.{ .color = @enumFromInt (@This ().colors [(elapsed_ds / 5) % @This ().colors.len]), });
    try Logger.stderr.writeAll (@This ().patterns [elapsed_ds % (@This ().patterns.len)]);
    try EscapeCode.fg.render (.{ .color = .white, });
    try Logger.stderr.writeAll (&self.message);
    try EscapeCode.reset.render (.{});
    try EscapeCode.erase_until_end_of_line.render (.{});
    try Logger.stderr.writeByte ('\n');
  }
};

// TODO: getters/setters
const Logger = struct
{
  const queue_size: usize = 1024;
  const spins_size: usize = 128;

  const space: u16 = 1;
  const time_length: u16 = 8 + space;
  const level_length: u16 = 5 + space;
  const header_length: u16 = time_length + level_length;

  const stderr_file = std.io.getStdErr ();
  const stderr_writer = stderr_file.writer ();
  var buffered_stderr = std.io.bufferedWriter (stderr_writer);
  var stderr = buffered_stderr.writer ();

  queue: std.BoundedArray ([] const u8, queue_size),
  mutex: std.Thread.Mutex = .{},
  condition: std.Thread.Condition = .{},
  looping: bool = true,
  spins: std.BoundedArray (Spin, spins_size),

  fn init () !@This ()
  {
    if (!@This ().stderr_file.supportsAnsiEscapeCodes ())
      return error.UnsupportedAnsiEscapeCodes;

    return .{
              .queue = try std.BoundedArray ([] const u8, queue_size).init (0),
              .spins = try std.BoundedArray (Spin, spins_size).init (0),
            };
  }

  fn deinit (self: *@This ()) void
  {
    self.looping = false;
  }

  fn add (self: *@This (), entry: [] const u8) void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();

    while (self.queue.slice ().len == queue_size) self.condition.wait (&self.mutex);

    self.queue.appendAssumeCapacity (entry);
  }

  fn spin_response (self: *@This (), entry: [] const u8) !void
  {
    if (self.spins.slice ().len == spins_size) return error.MaxSpinsReached;

    var it = std.mem.tokenizeScalar (u8, entry [2 ..], 0);
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
      if (std.mem.eql (u8, self.spins.get (index).getId (), entry [1 ..])) break;
      std.debug.print ("'{s}' {} '{s}' {}\n", .{self.spins.get (index).getId(),self.spins.get (index).getId().len, entry [1 ..], entry [1 ..].len});
      index = index + 1;
    } else return error.UnknownSpinId;

    _ = self.spins.orderedRemove (index);
  }

  fn response (self: *@This (), entry: [] const u8) !void
  {
    switch (entry [0])
    {
      'S'  => try self.spin_response (entry),
      'K'  => try self.kill_response (entry),
      else => { var log = try Log.init (entry); try log.render (); },
    }
  }

  fn empty (self: *@This ()) !bool
  {
    if (!self.mutex.tryLock ()) return true;
    defer self.mutex.unlock ();

    var index: usize = 0;
    while (index < self.queue.slice ().len)
    {
      try self.response (self.queue.swapRemove (index));
      index = index + 1;
    }

    while (self.queue.popOrNull ()) |entry| try self.response (entry);

    self.condition.signal ();

    return (index == 0);
  }

  fn animation (self: @This ()) !void
  {
    for (self.spins.slice ()) |spin| try spin.render ();
    for (self.spins.slice ()) |_| try EscapeCode.previous_line.render (.{});
    try Logger.buffered_stderr.flush (); // don't forget to flush!
  }

  fn loop (self: *@This ()) !void
  {
    while (self.looping or self.queue.slice ().len > 0)
    {
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

  const buffer_size: usize = 65536;
  var buffer_array: std.BoundedArray (u8, buffer_size) = undefined;
  const buffer = buffer_array.writer ();

  var dupe_buffer: [buffer_size] u8 = undefined;
  var fba = std.heap.FixedBufferAllocator.init (&dupe_buffer);
  const allocator = fba.allocator();

  const thread = try std.Thread.spawn (.{}, Logger.loop, .{ &logger, });
  defer thread.join ();
  defer logger.deinit ();

  var looping = true;

  while (looping)
  {
    buffer_array = try std.BoundedArray (u8, buffer_size).init (0);

    stdin.streamUntilDelimiter (buffer, '\n', buffer_size) catch |err| {
      if (err == error.EndOfStream) looping = false else return err;
    };

    if (looping or buffer_array.slice ().len > 0)
      logger.add (try allocator.dupe (u8, buffer_array.slice ()));
  }
}
