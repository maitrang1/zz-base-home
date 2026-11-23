// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build a test context on a fake machine
// Flo: root of fake machine > conf with one scan root + tena inside it > Ctxz with a capture writer, a fixed clock and a mock tool runner
// I/O: allocator, writer, root, conf > Ctxz (mock reachable via makeMock)
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const osys = @import("ut-osys-adap.zig");
const mock = @import("te-mock-runn.zig");
pub const NOWZ: i64 = 1_700_000_000;
pub fn fixdNow(iozz: std.Io) i64 { _ = iozz; return NOWZ; }
pub fn makeMock(allo: std.mem.Allocator, outw: *std.Io.Writer, root: []const u8, base: cfgz.Conf, json: bool, mck: *mock.Mock) !cx.Ctxz {
var conf = base;
const tena = try std.fmt.allocPrint(allo, "{s}/zz-tena", .{root});
const rootz = try allo.dupe([]const u8, &.{root});
conf.scan_root_list = rootz;
conf.tena_loca_wind = tena;
conf.tena_loca_unix = tena;
const cwdz = try std.process.currentPathAlloc(std.testing.io, allo);
return .{ .allo = allo, .gpaz = std.testing.allocator, .iozz = std.testing.io, .conf = conf, .ladd = .{ .json = json }, .outw = outw, .osy = osys.host, .home = root, .cwdz = cwdz, .nowf = fixdNow, .runn = mck.runn() };
}
pub fn make(allo: std.mem.Allocator, outw: *std.Io.Writer, root: []const u8, base: cfgz.Conf, json: bool) !cx.Ctxz {
const mck = try allo.create(mock.Mock);
mck.* = .{};
return makeMock(allo, outw, root, base, json, mck);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
