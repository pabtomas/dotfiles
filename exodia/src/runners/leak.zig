const std = @import ("std");
const builtin = @import ("builtin");

const Status = enum
{
  ok,
  fail,
  skip,
  leak,
  text,

  fn color (self: @This ()) std.io.tty.Color
  {
    return switch (self)
    {
      .ok   => .green,
      .fail => .red,
      .leak => .yellow,
      .skip => .cyan,
      else  => .reset,
    };
  }
};

const Printer = struct
{
  writer: std.fs.File.Writer,
  tty_conf: std.io.tty.Config,

  fn init () @This ()
  {
    return .{
      .writer = std.io.getStdErr ().writer (),
      .tty_conf = .escape_codes,
    };
  }

  fn print (self: @This (), status: Status, comptime format: [] const u8, args: anytype) !void
  {
    try self.tty_conf.setColor (self.writer, status.color ());
    try self.writer.print (format ++ "\n", args);
    try self.tty_conf.setColor (self.writer, .reset);
  }
};

pub fn main () !void
{
  const printer = Printer.init ();

  var ok: usize = 0;
  var fail: usize = 0;
  var skip: usize = 0;
  var leak: usize = 0;

  for (builtin.test_functions) |func|
  {
    if (!std.mem.endsWith (u8, func.name, ".leak")) continue;
    std.testing.allocator_instance = .{};
    var status: Status = .ok;

    const result = func.func ();

    if (std.testing.allocator_instance.deinit () == .leak)
    {
      status = .leak;
      leak += 1;
    } else if (result) |_| {
      ok += 1;
    } else |err| {
      switch (err) {
        error.SkipZigTest => {
          status = .skip;
          skip += 1;
        },
        else => {
          status = .fail;
          fail += 1;
          try printer.print (status, "[{s}: {s}] \"{s}\"\n", .{ @tagName (status), @errorName (err), func.name });
          if (@errorReturnTrace ()) |trace| std.debug.dumpStackTrace (trace.*);
          continue;
        },
      }
    }
    try printer.print (status, "[{s}] \"{s}\"", .{ @tagName (status), func.name });
  }

  const total = ok + fail + skip + leak;
  try printer.print (.text, "*" ** 80 ++ "\nFor {d} test{s}:", .{ total, if (total > 1) "s" else "" });
  try printer.print (.ok, "- {d} test{s} succeded", .{ ok, if (ok > 1) "s" else "" });
  try printer.print (.fail, "- {d} test{s} failed", .{ fail, if (fail > 1) "s" else "" });
  try printer.print (.leak, "- {d} test{s} leaked", .{ leak, if (leak > 1) "s" else "" });
  try printer.print (.skip, "- {d} test{s} skipped", .{ skip, if (skip > 1) "s" else "" });
}
