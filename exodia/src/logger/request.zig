const std = @import ("std");

const index = @import ("index");
const Log = index.Log;

pub const Request = struct
{
  const DataTag = enum { message, max, };
  pub const Data = union (DataTag)
  {
    message: [] const u8,
    max: u32,
  };

  const KindTag = enum { buffer, flush, spin, kill, bar, progress, log, };
  pub const Kind = union (KindTag)
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
