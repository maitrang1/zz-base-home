// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build a test context on a fake repo
// Flo: fake paths > conf with tena + repo inside the tmp dir > Ctxz with a capture writer, a fixed clock, a mock runner
// I/O: allocator, writer, Fake, Ladd > Ctxz
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const mock = @import("te-mock-runn.zig");
const fk = @import("te-fake-repo.zig");
pub const NOWZ: i64 = 1_700_000_000;
pub fn fixdNow(iozz: std.Io) i64 { _ = iozz; return NOWZ; }
pub fn make(allo: std.mem.Allocator, outw: *std.Io.Writer, fake: fk.Fake, ladd: ladz.Ladd, mck: *mock.Mock) !cx.Ctxz {
var conf: cfgz.Conf = .{};
conf.tena_loca_wind = fake.tena;
conf.tena_loca_unix = fake.tena;
conf.hubz_wait_seco = 0;
return .{ .allo = allo, .gpaz = std.testing.allocator, .iozz = std.testing.io, .conf = conf, .ladd = ladd, .outw = outw, .home = fake.tena, .repo = fake.repo, .nowf = fixdNow, .runn = mck.runn() };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
