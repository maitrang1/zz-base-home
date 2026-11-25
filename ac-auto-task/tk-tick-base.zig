// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Scheduler data types, limits and small helpers
// Flo: consts > run, chain, job, slot, result types > pure helpers
// I/O: plain values > Jobz, ChaiRunz, RunzSlot and helper fns
// ===================================================================
const std = @import("std"); const stor = @import("taskstore"); const time = @import("tasktime"); const armz = @import("taskarm"); const spaw = @import("spawn"); const regi = @import("registry"); const supe = @import("tasksuper"); const prob = @import("taskprobe"); const conf = @import("store"); const stre = @import("stream");
pub const CF = .{ .tick_msec = 1000, .relo_poll_msec = 3000, .stop_wait_msec = 2000, .stop_slic_msec = 50, .logz_maxz_byte = 1024 * 1024, .retr_base_msec = 1000, .retr_maxz_msec = 30_000, .queu_maxz = 256, .toas_maxz = 3, .work_maxz = 8, .work_wait_msec = 200, .catc_maxz_minu = 7 * 24 * 60, .catc_stag_msec = 15_000, .wake_gapz_msec = 90_000, .chai_maxz = 16, .chai_slac_msec = 60 * 60 * 1000, .chai_fini_maxz = 8, .chai_ring_maxz = 32, .skip_code = 4, .toas_wins = "[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$n=New-Object System.Windows.Forms.NotifyIcon;$n.Icon=[System.Drawing.SystemIcons]::Warning;$n.BalloonTipTitle=$env:CMDRUN_NT;$n.BalloonTipText=$env:CMDRUN_NM;$n.Visible=$true;$n.ShowBalloonTip(8000);Start-Sleep -Milliseconds 9000;$n.Dispose();" };
pub const ArmeReje = struct { iden: []const u8, whyz: []const u8 };
pub const ChaiRunz = struct {
used: bool = false, iden_buff: [128]u8 = undefined, iden_leng: usize = 0, seen: bool = false, boot: bool = false, runn: bool = false, wait: bool = false, indx: usize = 0, next_msec: i64 = 0, dead_msec: i64 = 0, star_msec: i64 = 0, ranz: u32 = 0, fail: u32 = 0, fail_buff: [512]u8 = undefined, fail_leng: usize = 0, abor: bool = false, ring_list: [CF.chai_ring_maxz]?*regi.Ring = @splat(null), ring_coun: usize = 0, step_buff: [128]u8 = undefined, step_leng: usize = 0, paus: bool = false, paus_last: i64 = 0,
pub fn name(self: *const ChaiRunz) []const u8 { return self.iden_buff[0..self.iden_leng]; }
};
pub const ChaiFini = struct { iden_buff: [128]u8 = undefined, iden_leng: usize = 0, ranz: u32 = 0, fail: u32 = 0, fail_buff: [512]u8 = undefined, fail_leng: usize = 0, elap_msec: i64 = 0, nozz_logz: bool = false, abor: bool = false };
pub fn finiPush(chai: *const ChaiRunz, nowz_msec: i64, nozz_logz: bool, abor: bool, fini: []ChaiFini, fini_coun: *usize) void { if (fini_coun.* >= fini.len) return; const item = &fini[fini_coun.*]; item.* = .{ .ranz = chai.ranz, .fail = chai.fail, .elap_msec = nowz_msec - chai.star_msec, .nozz_logz = nozz_logz, .abor = abor }; item.iden_leng = intoDupe(&item.iden_buff, chai.name()).len; item.fail_leng = intoDupe(&item.fail_buff, chai.fail_buff[0..chai.fail_leng]).len; fini_coun.* += 1; }
pub fn ringNote(iozz: std.Io, ring: *regi.Ring, text: []const u8) void { var buff: [512]u8 = undefined; var wrtr: std.Io.Writer = .fixed(&buff); stre.chunWrit(&wrtr, "out", text) catch return; ring.appe(iozz, wrtr.buffered()); }
pub fn ringDrop(chai: *ChaiRunz) void { for (chai.ring_list[0..chai.ring_coun]) |slot| if (slot) |ring| ring.rele(); chai.ring_list = @splat(null); chai.ring_coun = 0; }
pub fn ringSeal(iozz: std.Io, ring: *regi.Ring, code: i32, elap_msec: i64) void { var buff: [256]u8 = undefined; var wrtr: std.Io.Writer = .fixed(&buff); stre.exitWrit(&wrtr, code, elap_msec, "") catch return; ring.appe(iozz, wrtr.buffered()); ring.fini(iozz); }
pub fn membNext(list: []const stor.Task, idsz: []const []const u8, from: usize) usize { var indx = from; while (indx < idsz.len) : (indx += 1) { if (taskFind(list, idsz[indx])) |task| { if (task.on) return indx; } else return indx; } return idsz.len; }
pub fn plusPick(rngz: std.Random, plus: ?std.json.Value) i64 { const unit = [6]i64{ 365 * 86_400_000, 30 * 86_400_000, 86_400_000, 3_600_000, 60_000, 1_000 }; const item: []const std.json.Value = if (plus) |plus_valu| (if (plus_valu == .array) plus_valu.array.items else &.{}) else &.{}; var totl: i64 = 0; for (unit, 0..) |unit_valu, indx| { const pool: []const std.json.Value = if (indx >= item.len) &.{} else switch (item[indx]) { .array => |arra| arra.items, .string => item[indx .. indx + 1], else => &.{} }; if (poolPick(rngz, pool)) |valu| { totl += valu * unit_valu; } else if (indx == 5) { totl += @as(i64, rngz.uintLessThan(u32, 60)) * unit_valu; } } return totl; }
pub fn poolPick(rngz: std.Random, pool: []const std.json.Value) ?i64 { var coun: u64 = 0; for (pool) |item| coun += poolCoun(item); if (coun == 0) return null; var pick = rngz.uintLessThan(u64, coun); for (pool) |item| { const step = poolCoun(item); if (pick < step) return switch (item) { .integer => |valu| valu, .string => |text| stor.plusRang(text).?[0] + @as(i64, @intCast(pick)), else => null }; pick -= step; } return null; }
pub fn poolCoun(item: std.json.Value) u64 { return switch (item) { .integer => |valu| if (valu >= 0) 1 else 0, .string => |text| if (stor.plusRang(text)) |rang| @intCast(rang[1] - rang[0] + 1) else 0, else => 0 }; }
pub fn chaiResu(chai: *ChaiRunz, stat: stor.ChaiStat) void { chai.runn = true; chai.wait = true; chai.boot = true; chai.indx = stat.inde; chai.ranz = stat.ranz; chai.fail = stat.fail; chai.next_msec = stat.next_msec; chai.star_msec = stat.star_msec; }
pub const StarReqz = struct { iden_buff: [128]u8 = undefined, runz_buff: [2048]u8 = undefined, cwdz_buff: [512]u8 = undefined, shel_buff: [32]u8 = undefined, iden: []const u8 = "", runz: []const u8 = "", cwdz: []const u8 = "", shel: []const u8 = "" };
pub const PollReqz = struct { iden_buff: [128]u8 = undefined, iden: []const u8 = "", prob: prob.Prob = undefined };
pub const Jobz = struct {
iden_buff: [128]u8 = undefined, runz_buff: [2048]u8 = undefined, cwdz_buff: [512]u8 = undefined, shel_buff: [32]u8 = undefined, queu_file_buff: [512]u8 = undefined, queu_dirz_buff: [512]u8 = undefined, once_buff: [64]u8 = undefined,
iden: []const u8 = "", runz: []const u8 = "", cwdz: []const u8 = "", shel: []const u8 = "", queu_file: []const u8 = "", queu_dirz: []const u8 = "", once_stam: []const u8 = "",
nozz_logz: bool = false, time_msec: u32 = 0, retr: u32 = 0, dept: u8 = 0, lock_buff: [stor.MAXZ_LOCK]u8 = undefined, lock: []const u8 = "", notz_befo_msec: i64 = 0, atte: u32 = 0, catc: bool = false, iszz_catc: bool = false, chai: bool = false, teez: ?*regi.Ring = null,
};
pub const RunzSlot = struct {
acti: bool = false, iden_buff: [128]u8 = undefined, iden_leng: usize = 0, lock_buff: [stor.MAXZ_LOCK]u8 = undefined, lock_leng: usize = 0, sinc_msec: i64 = 0,
pub fn iden(self: *const RunzSlot) []const u8 { return self.iden_buff[0..self.iden_leng]; }
pub fn lockName(self: *const RunzSlot) []const u8 { return self.lock_buff[0..self.lock_leng]; }
};
pub fn jobzFill(jobz: *Jobz, iden: []const u8, task: stor.Task) void { jobz.* = .{}; jobz.iden = intoDupe(&jobz.iden_buff, iden); jobz.runz = intoDupe(&jobz.runz_buff, task.run); jobz.cwdz = intoDupe(&jobz.cwdz_buff, task.cwd orelse ""); jobz.shel = intoDupe(&jobz.shel_buff, task.shell orelse ""); jobz.lock = intoDupe(&jobz.lock_buff, conf.lockOf(iden)); jobz.nozz_logz = task.noLog orelse false; jobz.time_msec = (task.tmo orelse conf.tune.tmoz_seco) * 1000; jobz.retr = task.@"try" orelse 0; jobz.catc = (task.catc orelse 0) > 0; }
pub fn taskFind(list: []const stor.Task, iden: []const u8) ?stor.Task { for (list) |task| if (std.mem.eql(u8, task.id, iden)) return task; return null; }
pub fn intoDupe(buff: []u8, srcz: []const u8) []const u8 { const leng = @min(buff.len, srcz.len); @memcpy(buff[0..leng], srcz[0..leng]); return buff[0..leng]; }
pub fn jobzClon(gpaz: std.mem.Allocator, srcz: *const Jobz) !*Jobz { const pntr = try gpaz.create(Jobz); pntr.* = srcz.*; pntr.iden = pntr.iden_buff[0..srcz.iden.len]; pntr.runz = pntr.runz_buff[0..srcz.runz.len]; pntr.cwdz = pntr.cwdz_buff[0..srcz.cwdz.len]; pntr.shel = pntr.shel_buff[0..srcz.shel.len]; pntr.queu_file = pntr.queu_file_buff[0..srcz.queu_file.len]; pntr.queu_dirz = pntr.queu_dirz_buff[0..srcz.queu_dirz.len]; pntr.once_stam = pntr.once_buff[0..srcz.once_stam.len]; pntr.lock = pntr.lock_buff[0..srcz.lock.len]; return pntr; }
pub const RunzResu = struct { code: i32, elap_msec: i64, retr: u32 = 0, catc: bool = false };
pub fn logzRota(allo: std.mem.Allocator, iozz: std.Io, full: []const u8) void { const oldz = std.fmt.allocPrint(allo, "{s}.1", .{full}) catch return; std.Io.Dir.rename(.cwd(), full, .cwd(), oldz, iozz) catch {}; }
pub fn logzDirz(allo: std.mem.Allocator, iozz: std.Io) ![]const u8 { const dirz = try std.fs.path.join(allo, &.{ try conf.dataBase(allo), "task-log" }); std.Io.Dir.cwd().createDirPath(iozz, dirz) catch {}; return dirz; }
pub const RunzLastReco = struct { hasz: bool = false, code: i32 = 0, elap_msec: i64 = 0, when: [19]u8 = undefined, when_leng: u8 = 0 };
pub fn recoLast(allo: std.mem.Allocator, reco: RunzLastReco) ?RunzLast { if (!reco.hasz) return null; const when = allo.dupe(u8, reco.when[0..reco.when_leng]) catch ""; return .{ .code = reco.code, .elap_msec = reco.elap_msec, .when = when }; }
pub const CatcReqz = struct { iden_buff: [128]u8 = undefined, iden: []const u8 = "", sche_buff: [128]u8 = undefined, sche: []const u8 = "", iszz_once: bool = false, iszz_chai: bool = false, numb: u8 = 0 };
pub const RunzLast = struct { code: i32, elap_msec: i64, when: []const u8 };
pub const ChaiView = struct { wait: bool, indx: usize, ranz: u32, fail: u32, next_minu: i64, star_msec: i64, next_msec: i64, paus: bool = false };
pub fn nowzMsec(iozz: std.Io) i64 { return std.Io.Clock.real.now(iozz).toMilliseconds(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
