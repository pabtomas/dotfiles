const std = @import ("std");

const index = @import ("index");
const Log = index.Log;

pub const Request = struct
{
  const KindTag = enum { spin, kill, bar, progress, log, };
  pub const Kind = union (KindTag)
  {
    spin: [] const u8,
    kill: [] const u8,
    bar: u32,
    progress: void,
    log: Log.Header,
  };

  kind: @This ().Kind,
  data: ?[] const u8,
};
