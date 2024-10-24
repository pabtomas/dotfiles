const root = @This ();
const std = @import ("std");

const jdz = @import ("jdz");
const JdzGlobalAllocator = jdz.JdzGlobalAllocator (.{});

const index_zig = @import ("logger/index.zig");
pub const Log = index_zig.Log;
pub const Stream = index_zig.Stream;
const Queue = index_zig.Queue;
const Request = index_zig.Request;
const Spin = index_zig.Spin;
const Bar = index_zig.Bar;

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
  spins: std.StringHashMap (*std.DoublyLinkedList (Spin).Node),
  nodes: std.DoublyLinkedList (Spin) = .{},
  bar: Bar,
  allocator: *const std.mem.Allocator,
  looping: bool,
  log_level: Log.Header,
  stream: *Stream,
  nproc: usize,

  pub fn init (nproc: usize, allocator: *const std.mem.Allocator, stream: *Stream) !@This ()
  {
    var self: @This () = .{
      .requests  = Queue.init ("root"),
      .spins     = std.StringHashMap (*std.DoublyLinkedList (Spin).Node).init (allocator.*),
      .bar       = Bar.init (0),
      .allocator = allocator,
      .looping   = true,
      .log_level = .INFO,
      .stream    = stream,
      .nproc     = nproc,
    };
    try self.spins.ensureTotalCapacity (@intCast (nproc));
    return self;
  }

  pub fn deinit (self: *@This ()) void
  {
    self.requests.deinit (self.allocator);
    while (self.nodes.pop ()) |node| self.allocator.destroy (node);
    self.spins.deinit ();
    JdzGlobalAllocator.deinitThread ();
  }

  pub fn stop (self: *@This ()) void
  {
    self.looping = false;
  }

  pub fn setLogLevel (self: *@This (), log_level: Log.Header) void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();
    self.log_level = log_level;
  }

  pub fn enqueue (self: *@This (), request: Request) !void
  {
    self.mutex.lock ();
    defer self.mutex.unlock ();
    try self.requests.append (self.allocator, request);
  }

  pub fn call (self: *@This (), comptime name: [] const [] const u8, args: anytype, comptime src: std.builtin.SourceLocation) !returnType (name)
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
    try self.enqueue (.{ .kind = .{ .log = .TRACE, }, .data = buf, .allocated = false, });
    return @call (.auto, @field (ptr, name [name.len - 1]), args);
  }

  pub fn enqueueObject (self: *@This (), comptime T: type, obj: *const T, obj_name: [] const u8) !void
  {
    var buf: [4096 * 1024] u8 = undefined;
    if (self.log_level == .VERB)
    {
      inline for (@typeInfo (@TypeOf (obj.*)).Struct.fields) |field|
        try self.enqueue (.{ .kind = .{ .log = .VERB, }, .data = try self.allocator.dupe (u8, try std.fmt.bufPrint (&buf, "{s}.{s} = {any}", .{ obj_name, field.name, @field (obj.*, field.name), })), .allocated = true, });
        // This failed with unwrapped error.NoSpaceLeft:
        // try self.enqueue (.{ .kind = .{ .log = .VERB, }, .data = try std.fmt.allocPrint (self.allocator.*, "{s}.{s} = {any}", .{ obj_name, field.name, @field (obj.*, field.name), }), .allocated = true, });
    }
  }

  pub fn dequeue (self: *@This ()) !bool
  {
    if (!self.mutex.tryLock ()) return false;
    defer self.mutex.unlock ();
    var log_rendered = false;
    while (self.requests.popFirst ()) |request|
    {
      defer
      {
        if (request.data.allocated) self.allocator.free (request.data.data.?);
        self.allocator.destroy (request);
      }
      log_rendered = try self.response (&request.data) or log_rendered;
    }
    return log_rendered;
  }

  fn logResponse (self: *@This (), request: *Request) !bool
  {
    std.debug.assert (std.meta.activeTag (request.kind) == Request.Kind.log);
    std.debug.assert (request.data != null);
    if (request.kind.log != .RAW and request.kind.log.gt (self.log_level)) return false;
    var log = Log.init (request);
    var looping = true;

    while (looping)
    {
      looping = try log.render (self.stream);
      try self.animation ();
    }
    return true;
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
      .log      => log_rendered = try self.logResponse (request),
    }
    return log_rendered;
  }

  fn animation (self: *@This ()) !void
  {
    var spin_rendered = false;
    var it = self.nodes.first;
    while (it) |node| : (it = node.next)
    {
      try node.data.render (self.stream, !spin_rendered);
      spin_rendered = true;
    }
    const bar_rendered = try self.bar.render (self.stream, !spin_rendered);
    try self.stream.clearFromCursorToScreenEnd ();
    for (0 .. self.spins.count ()) |i|
      if (i == 0) try self.stream.cursorStartLine () else try self.stream.cursorPreviousLine ();
    if (bar_rendered) for (0 .. 3) |i|
      if (!spin_rendered and i == 0) try self.stream.cursorStartLine ()
      else try self.stream.cursorPreviousLine ();
    try self.stream.flush (); // don't forget to flush!
  }

  pub fn loop (self: *@This ()) !void
  {
    defer self.deinit ();
    try self.stream.hideCursor ();
    while (self.looping or self.requests.list.len > 0 or self.bar.running or self.spins.count () > 0)
    {
      try self.stream.updateCols ();
      if (!try self.dequeue ()) try self.animation ();
    }
    try self.stream.clearFromCursorToScreenEnd ();
    try self.stream.showCursor ();
    try self.stream.flush (); // don't forget to flush!
  }
};
