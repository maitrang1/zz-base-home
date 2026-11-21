// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Test helper: build Ctxz with mock runner, fixed clock
// Flo: take writer + mock + config > fill Ctxz > fixed clock
// I/O: test inputs > cx.Ctxz
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const mock = @import("te-mock-runn.zig");
pub const NOWZ: i64 = 1_700_000_000;
pub fn fixdNow(iozz: std.Io) i64 { _ = iozz; return NOWZ; }
pub fn make(allo: std.mem.Allocator, outw: *std.Io.Writer, mck: *mock.Mock, cfgv: cfgz.Conf, home: []const u8, live: bool, json: bool) cx.Ctxz {
var cfg = cfgv; cfg.tena_loca_wind = ""; cfg.tena_loca_unix = "";
return .{ .allo = allo, .iozz = std.testing.io, .runn = mck.runn(), .conf = cfg, .home = home, .devi = "devb", .ladd = .{ .live = live, .json = json }, .prof = "t0", .outw = outw, .nowf = fixdNow };
}
pub fn homeOf(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir) ![]u8 { return std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{tmp.sub_path}); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
