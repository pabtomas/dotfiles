const std = @import ("std");

const logger_module = @import ("logger");
const Logger = logger_module.Logger;
const Log = logger_module.Log;

pub const Options = struct
{
  help: bool = false,
  version: bool = false,
  log_level: Log.Header,
  reset_cache: bool = false,
  file: [] const u8 = "exodia.zon",
  rules: std.DoublyLinkedList ([] const u8) = .{},

  mistake: bool = false,
  incr_warning: bool = false,

  fn decrLogLevel (self: *@This (), logger: *Logger) !void
  {
    if (self.log_level == .ERROR)
    {
      return; // -qq skip WARN messages
    } else if (self.log_level.gt (.INFO)) {
      try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "-q and -v options can not be combined", });
      self.mistake = true;
    } else self.log_level = self.log_level.decr ();
  }

  fn incrLogLevel (self: *@This (), logger: *Logger) !void
  {
    if (self.log_level == .VERB)
    {
      if (!self.incr_warning)
      {
        try logger.enqueue (.{ .kind = .{ .log = .WARN, }, .data = "-v can not be used more than 4 times", });
        self.incr_warning = true;
      }
    } else if (self.log_level.lt (.INFO)) {
      try logger.enqueue (.{ .kind = .{ .log = .ERROR, }, .data = "-q and -v options can not be combined", });
      self.mistake = true;
    } else self.log_level = self.log_level.incr ();
  }

  fn addRule (self: *@This (), allocator: *const std.mem.Allocator, arg: [] const u8) !void
  {
    var node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
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
    @"reset-cache" = 'r',
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
    first: **std.DoublyLinkedList ([] const u8).Node, arg: *[] const u8) void
  {
    first.* = list.popFirst ().?;
    arg.* = first.*.data;
  }

  pub fn parse (allocator: *const std.mem.Allocator, logger: *Logger) !@This ()
  {
    var it = try std.process.argsWithAllocator (allocator.*);

    var list: std.DoublyLinkedList ([] const u8) = .{};
    var node: *std.DoublyLinkedList ([] const u8).Node = undefined;

    _ = it.next ();
    while (it.next ()) |arg|
    {
      node = try allocator.create (std.DoublyLinkedList ([] const u8).Node);
      node.data = arg [0 .. arg.len];
      list.append (node);
    }

    var self: @This () = .{ .log_level = logger.log_level, };
    var first: *std.DoublyLinkedList ([] const u8).Node = undefined;
    var arg: [] const u8 = undefined;

    while (list.len > 0 and !self.mistake)
    {
      shift (&list, &first, &arg);

      if (try handleContractedShortNoArg (allocator, &list, arg)) continue;
      if (try handleContractedShortArg (allocator, &list, arg)) continue;
      if (try handleEqualLongArg (allocator, &list, arg)) continue;

      if (std.mem.eql (u8, arg, NoArg.help.short ()) or std.mem.eql (u8, arg, NoArg.help.long ())) self.help = true
      else if (std.mem.eql (u8, arg, NoArg.version.short ()) or std.mem.eql (u8, arg, NoArg.version.long ())) self.version = true
      else if (std.mem.eql (u8, arg, NoArg.@"reset-cache".short ()) or std.mem.eql (u8, arg, NoArg.@"reset-cache".long ())) self.reset_cache = true
      else if (std.mem.eql (u8, arg, NoArg.quiet.short ()) or std.mem.eql (u8, arg, NoArg.quiet.long ())) try self.decrLogLevel (logger)
      else if (std.mem.eql (u8, arg, NoArg.verbose.short ()) or std.mem.eql (u8, arg, NoArg.verbose.long ())) try self.incrLogLevel (logger)
      else if (std.mem.eql (u8, arg, Arg.file.short ()) or std.mem.eql (u8, arg, Arg.file.long ())) { shift (&list, &first, &arg); self.file = arg; }
      else try self.addRule (allocator, arg);
    }

    return self;
  }
};
