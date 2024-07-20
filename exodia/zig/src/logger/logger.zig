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

pub const StdErr = struct
{
  buffer: std.io.BufferedWriter (4096, std.fs.File.Writer),
  writer: std.io.BufferedWriter (4096, std.fs.File.Writer).Writer,
};

pub const Logger = struct
{

  mutex: std.Thread.Mutex = .{},
  requests: Queue,
  spins: std.StringHashMap (*std.DoublyLinkedList (Spin).Node),
  nodes: std.DoublyLinkedList (Spin) = .{},
  bar: Bar,
  allocator: *const std.mem.Allocator,
  looping: bool,
  cols: ?u16,
  stderr: *StdErr,

  pub fn init (nproc: u32, allocator: *const std.mem.Allocator, stderr: *StdErr) !@This ()
  {
    var self: @This () = .{
      .requests  = Queue.init ("root"),
      .spins     = std.StringHashMap (*std.DoublyLinkedList (Spin).Node).init (allocator.*),
      .bar       = Bar.init (0),
      .allocator = allocator,
      .looping   = true,
      .cols      = if (std.io.getStdErr ().supportsAnsiEscapeCodes ()) 0 else null,
      .stderr    = stderr,
    };
    try self.spins.ensureTotalCapacity (nproc);
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

  pub fn enqueueTrace (self: *@This (), comptime name: [] const [] const u8, args: anytype, comptime src: std.builtin.SourceLocation) !returnType (name)
  {
    comptime var ptr = root;
    comptime var buf: [] const u8 = std.fmt.comptimePrint ("[{s}:{d} in \"{s}\"] ", .{ src.file, src.line, src.fn_name, });
    inline for (0 .. name.len - 1) |i|
    {
      buf = buf ++ name [i] ++ ".";
      ptr = @field (ptr, name [i]);
    }
    buf = buf ++ name [name.len - 1] ++ " (";
    inline for (0 .. args.len - 1) |i| buf = buf ++ std.fmt.comptimePrint ("{any}, ", .{args[i]});
    buf = buf ++ std.fmt.comptimePrint ("{any})", .{ args [args.len - 1], });
    try self.enqueue (.{ .kind = .{ .log = .TRACE, }, .data = buf, });
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
    std.debug.assert (request.data != null);
    var log = Log.init (request);
    var looping = true;

    while (looping)
    {
      looping = try log.render (self);
      try self.animation ();
    }
  }

  fn spinResponse (self: *@This (), request: *Request) !void
  {
    std.debug.assert (self.spins.count () < self.spins.capacity ());
    std.debug.assert (self.nodes.len < self.spins.capacity ());
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.spin);
    std.debug.assert (request.kind.spin.len > 0);
    std.debug.assert (!self.spins.contains (request.kind.spin));
    std.debug.assert (request.data != null);
    var node = try self.allocator.create (std.DoublyLinkedList (Spin).Node);
    node.data = Spin.init (request.data.?);
    self.spins.putAssumeCapacity (request.kind.spin, node);
    self.nodes.append (node);
  }

  fn killResponse (self: *@This (), request: *Request) void
  {
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.kill);
    std.debug.assert (request.kind.kill.len > 0);
    std.debug.assert (self.nodes.len > 0);
    std.debug.assert (self.spins.contains (request.kind.kill));
    self.nodes.remove (self.spins.get (request.kind.kill).?);
    self.allocator.destroy (self.spins.get (request.kind.kill).?);
    std.debug.assert (self.spins.remove (request.kind.kill));
  }

  fn barResponse (self: *@This (), request: *Request) void
  {
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.bar);
    std.debug.assert (request.kind.bar > 0);
    self.bar = Bar.init (request.kind.bar);
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
      .spin     => try self.spinResponse (request),
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
    var it = self.nodes.first;
    while (it) |node| : (it = node.next)
    {
      try node.data.render (self, !spin_rendered);
      spin_rendered = true;
    }
    const bar_rendered = try self.bar.render (self, !spin_rendered);
    try self.clearFromCursorToScreenEnd ();
    for (0 .. self.spins.count ()) |i|
      if (i == 0) try self.cursorStartLine () else try self.cursorPreviousLine ();
    if (bar_rendered) for (0 .. 3) |i|
      if (!spin_rendered and i == 0) try self.cursorStartLine ()
      else try self.cursorPreviousLine ();
    try self.stderr.buffer.flush (); // don't forget to flush!
  }

  fn updateCols (self: *@This ()) !void
  {
    if (self.cols != null) self.cols = (try termsize.termSize (std.io.getStdErr ())).?.width;
  }

  pub fn loop (self: *@This ()) !void
  {
    defer
    {
      self.spins.deinit ();
      JdzGlobalAllocator.deinitThread ();
    }
    try self.hideCursor ();
    while (self.looping or self.requests.list.len > 0 or self.bar.running or self.spins.count () > 0)
    {
      try self.updateCols ();
      if (!try self.dequeue ()) try self.animation ();
    }
    try self.clearFromCursorToScreenEnd ();
    try self.showCursor ();
    try self.stderr.buffer.flush (); // don't forget to flush!
  }

  pub fn clearFromCursorToLineEnd (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.clear.clearFromCursorToLineEnd (self.stderr.writer);
  }

  fn clearFromCursorToScreenEnd (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.clear.clearFromCursorToScreenEnd (self.stderr.writer);
  }

  fn showCursor (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.showCursor (self.stderr.writer);
  }

  fn hideCursor (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.hideCursor (self.stderr.writer);
  }

  fn cursorStartLine (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.setCursorColumn (self.stderr.writer, 0);
  }

  fn cursorPreviousLine (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.cursor.cursorPreviousLine (self.stderr.writer, 1);
  }

  pub fn updateStyle (self: @This (), style: ansiterm.style.Style) !void
  {
    if (self.cols != null) try ansiterm.format.updateStyle (self.stderr.writer, style, null);
  }

  pub fn resetStyle (self: @This ()) !void
  {
    if (self.cols != null) try ansiterm.format.resetStyle (self.stderr.writer);
  }

  pub fn writeAll (self: @This (), str: [] const u8) !void
  {
    try self.stderr.writer.writeAll (str);
  }

  pub fn writeByte (self: @This (), byte: u8) !void
  {
    try self.stderr.writer.writeByte (byte);
  }
};
