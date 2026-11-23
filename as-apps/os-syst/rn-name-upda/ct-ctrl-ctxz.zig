// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared context + path helpers every command uses
// Flo: hold allocators, Io, config, OS rules, clock > resolve user paths to normalized absolute > data dirs
// I/O: command args > normalized paths, data dirs, run ids; stdout writer
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const osys = @import("ut-osys-adap.zig");
pub const Ctxz = struct {
allo: std.mem.Allocator,
gpaz: std.mem.Allocator,
iozz: std.Io,
conf: cfgz.Conf,
ladd: ladz.Ladd,
outw: *std.Io.Writer,
osy: osys.Osys,
home: []const u8,
cwdz: []const u8,
nowf: *const fn (iozz: std.Io) i64,
pub fn nowz(self: *const Ctxz) i64 { return self.nowf(self.iozz); }
pub fn absOf(self: *const Ctxz, raww: []const u8) ![]u8 {
if (osys.isAbso(self.osy, raww)) return osys.normPath(self.allo, self.osy, raww);
const joined = try std.fmt.allocPrint(self.allo, "{s}/{s}", .{ self.cwdz, raww });
return osys.normPath(self.allo, self.osy, joined);
}
pub fn tenaRoot(self: *const Ctxz) ![]u8 {
const raww = if (self.osy.wind) self.conf.tena_loca_wind else self.conf.tena_loca_unix;
if (osys.isAbso(self.osy, raww)) return osys.normPath(self.allo, self.osy, raww);
return osys.normPath(self.allo, self.osy, try std.fmt.allocPrint(self.allo, "{s}/{s}", .{ self.home, raww }));
}
pub fn dirzData(self: *const Ctxz) ![]u8 { return std.fmt.allocPrint(self.allo, "{s}/{s}", .{ try self.tenaRoot(), self.conf.apps_data_loca }); }
pub fn exists(self: *const Ctxz, norm: []const u8) bool { return if (std.Io.Dir.cwd().statFile(self.iozz, osys.natiForm(self.allo, self.osy, norm) catch return false, .{})) |_| true else |_| false; }
pub fn nati(self: *const Ctxz, norm: []const u8) ![]u8 { return osys.natiForm(self.allo, self.osy, norm); }
};
pub fn realNow(iozz: std.Io) i64 { return std.Io.Clock.real.now(iozz).toSeconds(); }
pub fn stamTxt(allo: std.mem.Allocator, nowz: i64) ![]u8 {
const secs: std.time.epoch.EpochSeconds = .{ .secs = @intCast(@max(nowz, 0)) };
const yday = secs.getEpochDay().calculateYearDay();
const mday = yday.calculateMonthDay();
const dsec = secs.getDaySeconds();
return std.fmt.allocPrint(allo, "{d:0>4}{d:0>2}{d:0>2}-{d:0>2}{d:0>2}{d:0>2}", .{ yday.year, @intFromEnum(mday.month), mday.day_index + 1, dsec.getHoursIntoDay(), dsec.getMinutesIntoHour(), dsec.getSecondsIntoMinute() });
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
