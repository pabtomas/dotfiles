const c = @cImport ({
  @cInclude ("jv.h");
  @cInclude ("jq.h");
});

pub const Jq = struct
{
  pub const ExitCode = enum (i8)
  {
    OK            =  0,
    OK_NULL_KIND  = -1,
    ERROR_SYSTEM  =  2,
    ERROR_COMPILE =  3,
    OK_NO_OUTPUT  = -4,
    ERROR_UNKNOWN =  5,

    fn toError (self: @This ()) !void
    {
      switch (self)
      {
        .ERROR_SYSTEM => return error.JqSystemError,
        .ERROR_COMPILE => return error.JqCompileError,
        .ERROR_UNKNOWN => return error.JqUnknownError,
        else => {},
      }
    }
  };

  handle: *c.jq_state,

  pub fn init () !@This () {
    return if (c.jq_init ()) |handle|
      .{
        .handle = handle,
       }
    else
       error.JqInit;
  }
};
