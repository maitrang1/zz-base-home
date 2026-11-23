// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared context + path helpers every command uses
// Flo: hold allocator, Io, config, OS rules > resolve user paths to normalized absolute > data dir
// I/O: command args > normalized paths, data dir; stdout writer
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const osys = @import("ut-osys-adap.zig");
pub const Ctxz = struct {
allo: std.mem.Allocator,
iozz: std.Io,
conf: cfgz.Conf,
ladd: ladz.Ladd,
outw: *std.Io.Writer,
osy: osys.Osys,
home: []const u8,
cwdz: []const u8,
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
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
