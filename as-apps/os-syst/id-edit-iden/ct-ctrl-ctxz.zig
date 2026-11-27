// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared context every command uses
// Flo: hold allocators, Io, config, repo root, clock, runner > data dirs > native paths
// I/O: command args > paths, run ids; stdout writer
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const osys = @import("ut-osys-adap.zig");
const runm = @import("ru-cmdz-runn.zig");
const tick = @import("ut-faul-tick.zig");
pub const Erro = error{NoRepo};
pub const Ctxz = struct {
allo: std.mem.Allocator,
gpaz: std.mem.Allocator,
iozz: std.Io,
conf: cfgz.Conf,
ladd: ladz.Ladd,
outw: *std.Io.Writer,
home: []const u8,
repo: []const u8,
nowf: *const fn (iozz: std.Io) i64,
runn: runm.Runn,
faul: ?*tick.Tick = null,
pub fn nowz(self: *const Ctxz) i64 { return self.nowf(self.iozz); }
pub fn tenaRoot(self: *const Ctxz) ![]u8 {
const raww = if (osys.wind) self.conf.tena_loca_wind else self.conf.tena_loca_unix;
if (osys.absz(raww)) return osys.nati(self.allo, raww);
return std.fs.path.join(self.allo, &.{ self.home, try osys.nati(self.allo, raww) });
}
pub fn dirzData(self: *const Ctxz) ![]u8 { return std.fs.path.join(self.allo, &.{ try self.tenaRoot(), try osys.nati(self.allo, self.conf.apps_data_loca) }); }
pub fn step(self: *const Ctxz) !void { if (self.faul) |tck| try tck.step(); }
};
pub fn realNow(iozz: std.Io) i64 { return std.Io.Clock.real.now(iozz).toSeconds(); }
pub fn stamTxt(allo: std.mem.Allocator, nowz: i64) ![]u8 {
const secs: std.time.epoch.EpochSeconds = .{ .secs = @intCast(@max(nowz, 0)) };
const yday = secs.getEpochDay().calculateYearDay();
const mday = yday.calculateMonthDay();
const dsec = secs.getDaySeconds();
return std.fmt.allocPrint(allo, "{d:0>4}{d:0>2}{d:0>2}-{d:0>2}{d:0>2}{d:0>2}", .{ yday.year, @intFromEnum(mday.month), mday.day_index + 1, dsec.getHoursIntoDay(), dsec.getMinutesIntoHour(), dsec.getSecondsIntoMinute() });
}
fn markOk(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8, conf: cfgz.Conf) bool {
const path = std.fs.path.join(allo, &.{ dirz, conf.hubz_dirz, conf.hubz_conf_name }) catch return false;
return if (std.Io.Dir.cwd().statFile(iozz, path, .{})) |_| true else |_| false;
}
pub fn repoFind(allo: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, cwdz: []const u8, exed: ?[]const u8) ![]const u8 {
if (conf.repo_root.len > 0) return osys.nati(allo, conf.repo_root);
for ([_]?[]const u8{ cwdz, exed }) |start| {
var curr: []const u8 = start orelse continue;
while (true) {
if (markOk(allo, iozz, curr, conf)) return curr;
curr = std.fs.path.dirname(curr) orelse break;
}
}
return Erro.NoRepo;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
