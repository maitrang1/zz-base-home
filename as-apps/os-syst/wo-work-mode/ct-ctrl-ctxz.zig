// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared context + helpers every command uses
// Flo: hold allocator, Io, runner, config, clock > run a tool or a logged step > emit facts
// I/O: command facts > stdout text/JSON, exit Code
// ===================================================================
const std = @import("std");
const builtin = @import("builtin");
const runm = @import("ru-cmdz-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const stat = @import("st-stat-file.zig");
const CF = .{ .notez = 200 };
pub const Ctxz = struct {
allo: std.mem.Allocator,
iozz: std.Io,
runn: runm.Runn,
conf: cfgz.Conf,
home: []const u8,
devi: []const u8,
ladd: ladz.Ladd,
prof: []const u8,
outw: *std.Io.Writer,
nowf: *const fn (iozz: std.Io) i64,
ostg: std.Target.Os.Tag = builtin.os.tag,
cpum: []const u8 = builtin.cpu.model.name,
pub fn nowz(self: *const Ctxz) i64 { return self.nowf(self.iozz); }
pub fn tenaRoot(self: *const Ctxz) ![]u8 { const raw = if (self.ostg == .windows) self.conf.tena_loca_wind else self.conf.tena_loca_unix; return if (std.fs.path.isAbsolute(raw)) self.allo.dupe(u8, raw) else std.fs.path.join(self.allo, &.{ self.home, raw }); }
pub fn dirzData(self: *const Ctxz) ![]u8 { return stat.dirzOf(self.allo, try self.tenaRoot(), self.conf.apps_data_loca); }
pub fn pathStat(self: *const Ctxz, name: []const u8) ![]u8 { return stat.pathOf(self.allo, try self.dirzData(), name); }
pub fn stamGet(self: *const Ctxz, name: []const u8) ?stat.Stam { const path = self.pathStat(name) catch return null; return stat.stamRead(self.allo, self.iozz, path); }
pub fn stamPut(self: *const Ctxz, name: []const u8, stam: stat.Stam) !void { try stat.stamWrit(self.allo, self.iozz, try self.dirzData(), try self.pathStat(name), stam); }
pub fn emit(self: *const Ctxz, facts: []const fcts.Fact) !exit.Code {
if (self.ladd.json) try fcts.rendJson(self.outw, facts) else try fcts.rendText(self.outw, facts);
return fcts.codeOf(facts);
}
pub fn tool(self: *const Ctxz, argv: []const []const u8, envp: []const runm.Envp) !?runm.Outp { return self.runn.exec(self.allo, argv, envp) catch |err| switch (err) { runm.Erro.ToolAbsent => return null, else => return err }; }
pub fn step(self: *const Ctxz, facts: *std.ArrayList(fcts.Fact), name: []const u8, argv: []const []const u8, envp: []const runm.Envp) !?runm.Outp {
const outp = (try self.tool(argv, envp)) orelse { try facts.append(self.allo, mkfa(name, .bloc, try std.fmt.allocPrint(self.allo, "tool absent: {s}", .{argv[0]}))); return null; };
if (outp.code != 0) { try facts.append(self.allo, mkfa(name, .fail, try std.fmt.allocPrint(self.allo, "exit {d}: {s}", .{ outp.code, clip(trim(if (outp.errz.len > 0) outp.errz else outp.outz)) }))); return null; }
try facts.append(self.allo, mkfa(name, .okay, ""));
return outp;
}
};
pub fn mkfa(name: []const u8, stav: fcts.Stat, note: []const u8) fcts.Fact { return .{ .name = name, .stat = stav, .note = note }; }
pub fn trim(text: []const u8) []const u8 { return std.mem.trim(u8, text, " \r\n\t"); }
pub fn clip(text: []const u8) []const u8 { return text[0..@min(text.len, CF.notez)]; }
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
