// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build a test context on a fake machine
// Flo: root of fake machine > conf with one scan root + tena inside it > Ctxz with a capture writer
// I/O: allocator, writer, root, conf > Ctxz
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const osys = @import("ut-osys-adap.zig");
pub fn make(allo: std.mem.Allocator, outw: *std.Io.Writer, root: []const u8, base: cfgz.Conf, json: bool) !cx.Ctxz {
var conf = base;
const tena = try std.fmt.allocPrint(allo, "{s}/zz-tena", .{root});
const rootz = try allo.dupe([]const u8, &.{root});
conf.scan_root_list = rootz;
conf.tena_loca_wind = tena;
conf.tena_loca_unix = tena;
const cwdz = try std.process.currentPathAlloc(std.testing.io, allo);
return .{ .allo = allo, .iozz = std.testing.io, .conf = conf, .ladd = .{ .json = json }, .outw = outw, .osy = osys.host, .home = root, .cwdz = cwdz };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
