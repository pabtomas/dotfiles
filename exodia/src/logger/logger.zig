const root = @This ();
const std = @import ("std");

const index = @import ("index");

const ansiterm = index.ansiterm;
const jdz = index.jdz;
const JdzGlobalAllocator = jdz.JdzGlobalAllocator (.{});
const termsize = index.termsize;

const Log = index.Log;
const Queue = index.Queue;
const Request = index.Request;
const Spin = index.Spin;
const Bar = index.Bar;

fn returnType (comptime name: [] const [] const u8) type
{
  var ptr = root;
  for (0 .. name.len - 1) |i| ptr = @field (ptr, name [i]);
  return (@typeInfo (@TypeOf (@field (ptr, name [name.len - 1]))).Fn.return_type orelse void);
}

pub const Logger = struct
{
  mutex: std.Thread.Mutex = .{},
  requests: Queue,
  spins: std.StringHashMap (Spin) = undefined,
  buffers: std.StringHashMap (Queue) = undefined,
  bar: Bar = undefined,
  allocator: *const std.mem.Allocator,
  looping: bool = true,
  cols: ?u16 = null,
  stderr_file: std.fs.File,
  stderr_writer: std.fs.File.Writer = undefined,
  buffered_stderr: std.io.BufferedWriter (4096, std.fs.File.Writer) = undefined,
  stderr: std.io.BufferedWriter (4096, std.fs.File.Writer).Writer = undefined,

  pub fn init (nproc: u32, allocator: *const std.mem.Allocator) !@This ()
  {
    var self: @This () = .{
      .requests    = Queue.init ("root"),
      .allocator   = allocator,
      .stderr_file = std.io.getStdErr (),
    };
    if (self.stderr_file.supportsAnsiEscapeCodes ()) self.cols = 0;
    self.stderr_writer = self.stderr_file.writer ();
    self.buffered_stderr = std.io.bufferedWriter (self.stderr_writer);
    self.stderr = self.buffered_stderr.writer ();
    self.spins = std.StringHashMap (Spin).init (self.allocator.*);
    self.buffers = std.StringHashMap (Queue).init (self.allocator.*);
    try self.spins.ensureTotalCapacity (nproc);
    try self.buffers.ensureTotalCapacity (nproc);
    return self;
  }

  pub fn deinit (self: *@This ()) void
  {
    self.looping = false;
  }

  pub fn enqueue (self: *@This (), request: Request) !void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();
    try self.requests.append (self.allocator, request);
  }

  pub fn enqueueTrace (self: *@This (), comptime name: [] const [] const u8, args: anytype) !returnType (name)
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
      looping = try log.render (self);
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
      try self.spins.getPtr (key.*).?.render (self, !spin_rendered);
      spin_rendered = true;
    }
    const bar_rendered = try self.bar.render (self, !spin_rendered);
    try self.clearFromCursorToScreenEnd ();
    for (0 .. self.spins.count ()) |i|
      if (i == 0) try self.cursorStartLine () else try self.cursorPreviousLine ();
    if (bar_rendered) for (0 .. 3) |i|
      if (!spin_rendered and i == 0) try self.cursorStartLine ()
      else try self.cursorPreviousLine ();
    try self.buffered_stderr.flush (); // don't forget to flush!
  }

  fn updateCols (self: *@This ()) !void
  {
    if (self.cols != null) self.cols = (try termsize.termSize (self.stderr_file)).?.width;
  }

  pub fn loop (self: *@This ()) !void
  {
    defer
    {
      self.spins.deinit ();
      self.buffers.deinit ();
      JdzGlobalAllocator.deinitThread ();
    }
    try self.hideCursor ();
    while (self.looping or self.requests.list.len > 0 or self.bar.running
      or self.spins.count () > 0 or self.buffers.count () > 0)
    {
      try self.updateCols ();
      if (!try self.dequeue ()) try self.animation ();
    }
    try self.clearFromCursorToScreenEnd ();
    try self.showCursor ();
    try self.buffered_stderr.flush (); // don't forget to flush!
  }

  pub fn clearFromCursorToLineEnd (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.clear.clearFromCursorToLineEnd (self.stderr);
  }

  fn clearFromCursorToScreenEnd (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.clear.clearFromCursorToScreenEnd (self.stderr);
  }

  fn showCursor (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.showCursor (self.stderr);
  }

  fn hideCursor (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.hideCursor (self.stderr);
  }

  fn cursorStartLine (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.setCursorColumn (self.stderr, 0);
  }

  fn cursorPreviousLine (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.cursorPreviousLine (self.stderr, 1);
  }

  pub fn updateStyle (self: @This (), style: ansiterm.style.Style) !void
  {
    if (self.cols != null) try ansiterm.format.updateStyle (self.stderr, style, null);
  }

  pub fn resetStyle (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.format.resetStyle (self.stderr);
  }

  pub fn writeAll (self: @This (), str: [] const u8) !void
  {
    try self.stderr.writeAll (str);
  }

  pub fn writeByte (self: @This (), byte: u8) !void
  {
    try self.stderr.writeByte (byte);
  }
};
