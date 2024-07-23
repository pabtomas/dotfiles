const std = @import ("std");

const logger_zig = @import ("logger.zig");
const Logger = logger_zig.Logger;
const Log = logger_zig.Log;
const Stream = logger_zig.Stream;

fn uncompatibleOpts (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "-q and -v options can not be combined", .allocated = false, });
  return error.UncompatibleOpts;
}

fn emptyArg (logger: *Logger) !void
{
  try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "Empty CLI arg", .allocated = false, });
  return error.EmptyArg;
}

pub const Options = struct
{
  const DEFAULT_FILE = "exodia.zon";

  help: bool = false,
  version: bool = false,
  log_level: Log.Header,
  file: ?[] const u8 = null,
  rules: std.DoublyLinkedList ([] const u8) = .{},
  allocator: *const std.mem.Allocator,

  incr_warning: bool = false,

  pub fn deinit (self: *@This ()) void
  {
    if (self.file) |path| self.allocator.free (path);
    while (self.rules.pop ()) |node| self.allocator.destroy (node);
  }

  fn decrLogLevel (self: *@This (), logger: *Logger) !void
  {
    if (self.log_level == .ERROR) return // -qq skip WARN messages
    else if (self.log_level.gt (.INFO)) try uncompatibleOpts (logger)
    else self.log_level = self.log_level.decr ();
  }

  fn incrLogLevel (self: *@This (), logger: *Logger) !void
  {
    if (self.log_level == .VERB)
    {
      if (!self.incr_warning)
      {
        try logger.enqueue (.{ .kind = .{ .log = .WARN, }, .data = "-v can not be used more than 4 times", .allocated = false, });
        self.incr_warning = true;
      }
    } else if (self.log_level.lt (.INFO)) try uncompatibleOpts (logger)
    else self.log_level = self.log_level.incr ();
  }

  fn setFile (self: *@This (), arg: [] const u8) !void
  {
    std.debug.assert (arg.len > 0);
    if (self.file) |path| self.allocator.free (path);
    self.file = try self.allocator.dupe (u8, arg);
  }

  fn addRule (self: *@This (), arg: [] const u8) !void
  {
    std.debug.assert (arg.len > 0);
    var node = try self.allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = arg;
    self.rules.append (node);
  }

  fn any (comptime T: type) [] const u8
  {
    const fields = @typeInfo (T).Enum.fields;
    var result: [fields.len] u8 = undefined;
    for (&result, fields) |*r, f| r.* = f.value;
    const final = result;
    return &final;
  }

  fn short (comptime T: type, comptime field: T) [] const u8 { return "-" ++ std.fmt.comptimePrint ("{c}", .{ @intFromEnum (field), }); }
  fn long (comptime T: type, comptime field: T) [] const u8 { return "--" ++ @tagName (field); }

  const Arg = enum (u8)
  {
    const any = Options.any (@This ());

    fn contains (str: [] const u8) bool
    {
      inline for (@typeInfo (@This ()).Enum.fields) |field|
        if (std.mem.eql (u8, str, field.name [0 .. field.name.len])) return true;
      return false;
    }

    fn short (comptime self: @This ()) [] const u8 { return Options.short (@This (), self); }
    fn long (comptime self: @This ()) [] const u8 { return Options.long (@This (), self); }

    file = 'f',
  };

  const NoArg = enum (u8)
  {
    const any = Options.any (@This ());

    fn short (comptime self: @This ()) [] const u8 { return Options.short (@This (), self); }
    fn long (comptime self: @This ()) [] const u8 { return Options.long (@This (), self); }

    help = 'h',
    quiet = 'q',
    verbose = 'v',
    version = 'V',
  };

  // Handle '-abc' the same as '-a -bc' for short-form no-arg options
  fn handleContractedShortNoArg (allocator: *const std.mem.Allocator, list: *std.DoublyLinkedList ([] const u8), arg: [] const u8) !bool
  {
    if (!std.mem.startsWith (u8, arg, "-") or arg.len <= 2 or
      std.mem.indexOfAny (u8, arg [1 ..], @This ().NoArg.any) != 0)
        return false;
    var node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = try std.fmt.allocPrint (allocator.*, "-{s}", .{ arg [2 ..], });
    list.prepend (node);
    node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = arg [0 .. 2];
    list.prepend (node);
    return true;
  }

  // Handle '-foo' the same as '-f oo' for short-form 1-arg options
  fn handleContractedShortArg (allocator: *const std.mem.Allocator, list: *std.DoublyLinkedList ([] const u8), arg: [] const u8) !bool
  {
    if (!std.mem.startsWith (u8, arg, "-") or arg.len <= 2
      or std.mem.indexOfAny (u8, arg [1 ..], @This ().Arg.any) != 0)
        return false;
    var node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = arg [2 ..];
    list.prepend (node);
    node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = arg [0 .. 2];
    list.prepend (node);
    return true;
  }

  // Handle '--file=file1' the same as '--file file1' for long-form 1-arg options
  fn handleEqualLongArg (allocator: *const std.mem.Allocator, list: *std.DoublyLinkedList ([] const u8), arg: [] const u8) !bool
  {
    const equal_index = std.mem.indexOfScalar (u8, arg, '=');
    if (!std.mem.startsWith (u8, arg, "--") or arg.len <= 3
      or equal_index == null or !@This ().Arg.contains (arg [2 .. equal_index.?]))
        return false;
    var node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = arg [equal_index.? + 1 ..];
    list.prepend (node);
    node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
    node.data = arg [0 .. equal_index.?];
    list.prepend (node);
    return true;
  }

  fn shift (list: *std.DoublyLinkedList ([] const u8),
    first: **std.DoublyLinkedList ([] const u8).Node, arg: *[] const u8, logger: *Logger) !void
  {
    if (list.popFirst ()) |node|
    {
      first.* = node;
      if (first.*.data.len == 0) try emptyArg (logger)
      else arg.* = first.*.data;
    } else {
      try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "Shifted a null arg", .allocated = false, });
      return error.MissingArg;
    }
  }

  pub fn parse (allocator: *const std.mem.Allocator, it: anytype, logger: *Logger) !@This ()
  {
    var arena_instance = std.heap.ArenaAllocator.init (allocator.*);
    defer arena_instance.deinit ();
    const arena = arena_instance.allocator ();

    var list: std.DoublyLinkedList ([] const u8) = .{};
    var node: *std.DoublyLinkedList ([] const u8).Node = undefined;

    _ = it.next ();
    while (it.next ()) |arg|
    {
      node = try arena.create (std.DoublyLinkedList ([] const u8).Node);
      node.data = arg [0 .. arg.len];
      list.append (node);
    }

    var self: @This () = .{
      .log_level = logger.log_level,
      .allocator = allocator,
    };
    var first: *std.DoublyLinkedList ([] const u8).Node = undefined;
    var arg: [] const u8 = undefined;

    while (list.len > 0)
    {
      try shift (&list, &first, &arg, logger);
      try logger.enqueue (.{ .kind = .{ .log = .VERB, }, .data = try std.fmt.allocPrint (logger.allocator.*, "arg = '{s}'", .{ arg, }), .allocated = true, });

      if (try handleContractedShortNoArg (&arena, &list, arg)) continue;
      if (try handleContractedShortArg (&arena, &list, arg)) continue;
      if (try handleEqualLongArg (&arena, &list, arg)) continue;

      if (std.mem.eql (u8, arg, NoArg.help.short ()) or std.mem.eql (u8, arg, NoArg.help.long ())) self.help = true
      else if (std.mem.eql (u8, arg, NoArg.version.short ()) or std.mem.eql (u8, arg, NoArg.version.long ())) self.version = true
      else if (std.mem.eql (u8, arg, NoArg.quiet.short ()) or std.mem.eql (u8, arg, NoArg.quiet.long ())) try self.decrLogLevel (logger)
      else if (std.mem.eql (u8, arg, NoArg.verbose.short ()) or std.mem.eql (u8, arg, NoArg.verbose.long ())) try self.incrLogLevel (logger)
      else if (std.mem.eql (u8, arg, Arg.file.short ()) or std.mem.eql (u8, arg, Arg.file.long ())) {
        try shift (&list, &first, &arg, logger);
        try self.setFile (arg);
      } else if (arg.len > 0) try self.addRule (arg)
      else try emptyArg (logger);
    }

    return self;
  }
};
