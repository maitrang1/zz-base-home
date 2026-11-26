// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Manual single-step run: queue one chain step or task id, keep its ring, abort it while queued
// Flo: check id + chain idle > fill job (same as the chain would) > ring > queue (lock + cap as usual) > slot for attach
// I/O: step id + tab name > ManuRes, queued Jobz, ring (attach), /jobs rows
// ===================================================================
const std = @import("std"); const stor = @import("taskstore"); const regi = @import("registry");
const tktickbase = @import("tk-tick-base.zig"); const Jobz = tktickbase.Jobz; const intoDupe = tktickbase.intoDupe; const jobzClon = tktickbase.jobzClon; const jobzFill = tktickbase.jobzFill; const nowzMsec = tktickbase.nowzMsec; const ringNote = tktickbase.ringNote; const ringSeal = tktickbase.ringSeal; const taskFind = tktickbase.taskFind;
const Sche = @import("tk-task-tick.zig").Sche;
pub const ManuCode = enum { okzz, bad_id, unknown, is_chain, chain_run, busy, no_mem };
pub const ManuRes = struct {
code: ManuCode = .okzz, wait: bool = false, chai_buff: [128]u8 = undefined, chai_leng: usize = 0, lock_buff: [stor.MAXZ_LOCK]u8 = undefined, lock_leng: usize = 0,
pub fn chaiName(self: *const ManuRes) []const u8 { return self.chai_buff[0..self.chai_leng]; }
pub fn lockName(self: *const ManuRes) []const u8 { return self.lock_buff[0..self.lock_leng]; }
};
fn chaiRunn(self: *Sche, iden: []const u8) bool { for (&self.chai) |*chai| if (chai.used and chai.runn and std.mem.eql(u8, chai.name(), iden)) return true; return false; }
fn lockWait(self: *Sche, iozz: std.Io, lock: []const u8) bool { self.queu_mute.lock(iozz) catch return false; defer self.queu_mute.unlock(iozz); return self.lockHeldIszz(lock); }
fn slotPut(self: *Sche, iozz: std.Io, ring: *regi.Ring) void { self.mute.lock(iozz) catch { ring.rele(); return; }; defer self.mute.unlock(iozz); var emptyz: ?usize = null; var same: ?usize = null; var oldz: usize = 0; var oldz_msec: i64 = std.math.maxInt(i64); for (self.manu, 0..) |slot, indx| { const item = slot orelse { if (emptyz == null) emptyz = indx; continue; }; if (std.mem.eql(u8, item.cmdz, ring.cmdz)) { same = indx; break; } if (item.star_msec < oldz_msec) { oldz_msec = item.star_msec; oldz = indx; } } const pick = same orelse emptyz orelse oldz; if (self.manu[pick]) |old| old.rele(); self.manu[pick] = ring; }
pub fn manuRun(self: *Sche, iozz: std.Io, iden: []const u8, tab: []const u8) ManuRes {
var resu: ManuRes = .{};
if (stor.idenVali(iden) != null) { resu.code = .bad_id; return resu; }
var jobz: Jobz = .{};
{
self.mute.lock(iozz) catch { resu.code = .no_mem; return resu; };
defer self.mute.unlock(iozz);
const list = if (self.load) |load| load.task else &[_]stor.Task{};
var owne: ?stor.Task = null;
for (list) |task| { const idsz = task.ids orelse continue; for (idsz) |memb| { if (!std.mem.eql(u8, memb, iden)) continue; if (chaiRunn(self, task.id)) { resu.code = .chain_run; resu.chai_leng = intoDupe(&resu.chai_buff, task.id).len; return resu; } if (owne == null) owne = task; break; } }
if (taskFind(list, iden)) |memb| { if (stor.chaiChec(memb)) { resu.code = .is_chain; return resu; } jobzFill(&jobz, iden, memb); } else if (owne) |chai| { if (!self.virtFill(&jobz, iden, chai)) { resu.code = .unknown; return resu; } } else { resu.code = .unknown; return resu; }
}
jobz.manu = true; jobz.retr = 0; jobz.catc = false; jobz.dept = 0;
resu.lock_leng = intoDupe(&resu.lock_buff, jobz.lock).len;
const ring = regi.Ring.crea(self.gpaz, iden, self.root, tab, nowzMsec(iozz)) catch { resu.code = .no_mem; return resu; };
ring.reta(); jobz.teez = ring;
const pntr = jobzClon(self.gpaz, &jobz) catch { ring.rele(); ring.rele(); resu.code = .no_mem; return resu; };
resu.wait = lockWait(self, iozz, pntr.lock);
if (resu.wait) { var buff: [160]u8 = undefined; const note = std.fmt.bufPrint(&buff, "queued: waiting for lock '{s}' to be free\n", .{pntr.lock}) catch ""; if (note.len > 0) ringNote(iozz, ring, note); }
if (!self.queuEnqu(iozz, pntr)) { self.jobzFree(pntr); ring.rele(); resu.code = .busy; return resu; }
slotPut(self, iozz, ring);
return resu;
}
pub fn manuRing(self: *Sche, iozz: std.Io, iden: []const u8) ?*regi.Ring { self.mute.lock(iozz) catch return null; defer self.mute.unlock(iozz); for (self.manu) |slot| { const ring = slot orelse continue; if (!std.mem.eql(u8, ring.cmdz, iden)) continue; ring.reta(); return ring; } return null; }
pub fn manuAbor(self: *Sche, iozz: std.Io, iden: []const u8) bool { var pull: ?*Jobz = null; { self.queu_mute.lock(iozz) catch return false; defer self.queu_mute.unlock(iozz); var indx: usize = 0; while (indx < self.queu.items.len) : (indx += 1) { const jobz = self.queu.items[indx]; if (jobz.manu and std.mem.eql(u8, jobz.iden, iden)) { pull = self.queu.orderedRemove(indx); break; } } } const jobz = pull orelse return false; if (jobz.teez) |teez| ringSeal(iozz, teez, -1, 0); self.jobzFree(jobz); return true; }
pub fn manuJobzWrit(self: *Sche, iozz: std.Io, wrtr: *std.Io.Writer, comm: bool) !void { try self.mute.lock(iozz); defer self.mute.unlock(iozz); var firs = !comm; for (self.manu) |slot| { const ring = slot orelse continue; if (!firs) try wrtr.writeAll(","); firs = false; try wrtr.writeAll("{\"id\":"); try std.json.Stringify.encodeJsonString(ring.cmdz, .{}, wrtr); try wrtr.writeAll(",\"cmd\":"); try std.json.Stringify.encodeJsonString(ring.cmdz, .{}, wrtr); try wrtr.writeAll(",\"cwd\":\"\",\"tab\":"); try std.json.Stringify.encodeJsonString(ring.tabz, .{}, wrtr); try wrtr.print(",\"started\":{d},\"run\":{d},\"keep\":true,\"done\":{},\"bytes\":{d},\"chain\":true,\"manu\":true}}", .{ ring.star_msec, ring.star_msec, ring.doneChec(iozz), ring.size(iozz) }); } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
