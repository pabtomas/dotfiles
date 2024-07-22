pub const stream = @import ("stream.zig");
pub const Stream = stream.Stream;
pub const log = @import ("log.zig");
pub const Log = log.Log;
pub const queue = @import ("queue.zig");
pub const Queue = queue.Queue;
pub const request = @import ("request.zig");
pub const Request = request.Request;
pub const spin = @import ("spin.zig");
pub const Spin = spin.Spin;
pub const bar = @import ("bar.zig");
pub const Bar = bar.Bar;
pub const Color = @import ("color.zig").Color;

pub const space: u16 = 1;
pub const time_length: u16 = 8 + space;
pub const level_length: u16 = 5 + space;
pub const header_length: u16 = time_length + level_length;
