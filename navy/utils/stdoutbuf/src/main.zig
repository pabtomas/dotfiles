const std = @import ("std");

pub fn main () !void
{
  const stdout_file = std.io.getStdOut ().writer ();
  var bw = std.io.bufferedWriter (stdout_file);
  const stdout = bw.writer ();

  const stdin_file = std.io.getStdIn ().reader ();
  var br = std.io.bufferedReader (stdin_file);
  const stdin = br.reader ();
  var loop = true;
  while (loop)
  {
    stdin.streamUntilDelimiter (stdout, 7, null) catch { loop = false; continue; };
    stdout.writeByte ('\n') catch { loop = false; continue; };
    bw.flush () catch { loop = false; continue; }; // don't forget to flush!
  }
}
