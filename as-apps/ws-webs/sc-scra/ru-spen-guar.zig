// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Spend guard: free credits first, paid only under cap + go
// Flo: kill switch off? > month credits used > free left covers cost? > else paid part x price must fit capz_usdz_mont and needs go > record real spend
// I/O: Db + Conf + vendor + credit cost + time (ladder) > Deci (allow, paid, micro-USD, reason); ledger rows in vled
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig"); const base = @import("nt-vend-base.zig"); const kill = @import("ru-kill-swit.zig"); const cfgz = @import("cf-conf-load.zig");
pub const Deci = struct { okay: bool, paid: bool = false, micr: u64 = 0, why: []const u8 = "" };
pub fn montOf(mill: i64) i64 { const secs: u64 = @intCast(@max(@divFloor(mill, 1000), 0)); const eps: std.time.epoch.EpochSeconds = .{ .secs = secs }; const yday = eps.getEpochDay().calculateYearDay(); return @as(i64, yday.year) * 100 + yday.calculateMonthDay().month.numeric(); }
pub fn freeOf(conf: cfgz.Conf, vend: base.Vend) u32 { return switch (vend) { .deco => conf.vend_free_cred.deco, .zenr => conf.vend_free_cred.zenr, .brig => conf.vend_free_cred.brig, .mock => 0 }; }
pub fn priceOf(conf: cfgz.Conf, vend: base.Vend) u32 { return switch (vend) { .deco => conf.vend_cred_micr.deco, .zenr => conf.vend_cred_micr.zenr, .brig => conf.vend_cred_micr.brig, .mock => 0 }; }
pub fn spenUsed(dbzz: *sqli.Db, vend: base.Vend, now: i64) !i64 { var stmt = try dbzz.prep("SELECT cred FROM vled WHERE vend=?1 AND mont=?2;"); defer stmt.fini(); try stmt.bindText(1, base.vendName(vend)); try stmt.bindInt(2, montOf(now)); if (!try stmt.step()) return 0; return stmt.colInt(0); }
pub fn spenTota(dbzz: *sqli.Db, now: i64) !i64 { var stmt = try dbzz.prep("SELECT coalesce(sum(micr),0) FROM vled WHERE mont=?1;"); defer stmt.fini(); try stmt.bindInt(1, montOf(now)); _ = try stmt.step(); return stmt.colInt(0); }
pub fn spenChek(dbzz: *sqli.Db, conf: cfgz.Conf, vend: base.Vend, cost: u32, now: i64, go: bool) !Deci { if (try kill.killGet(dbzz)) return .{ .okay = false, .why = "kill switch on" }; const used = try spenUsed(dbzz, vend, now); const free: i64 = freeOf(conf, vend); const paid = @max(used + cost - free, 0) - @max(used - free, 0); if (paid == 0) return .{ .okay = true }; const micr: u64 = @intCast(paid * @as(i64, priceOf(conf, vend))); if (!go) return .{ .okay = false, .why = "free credits used up, paid needs go" }; const cap = cfgz.capzMicr(conf); const tota: u64 = @intCast(try spenTota(dbzz, now)); if (cap == 0 or tota + micr > cap) return .{ .okay = false, .why = "over capz_usdz_mont" }; return .{ .okay = true, .paid = true, .micr = micr }; }
pub fn spenRec(dbzz: *sqli.Db, vend: base.Vend, cred: u32, micr: u64, now: i64) !void { var stmt = try dbzz.prep("INSERT INTO vled(vend,mont,cred,micr) VALUES(?1,?2,?3,?4) ON CONFLICT(vend,mont) DO UPDATE SET cred=cred+?3, micr=micr+?4;"); defer stmt.fini(); try stmt.bindText(1, base.vendName(vend)); try stmt.bindInt(2, montOf(now)); try stmt.bindInt(3, cred); try stmt.bindInt(4, @intCast(micr)); _ = try stmt.step(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
