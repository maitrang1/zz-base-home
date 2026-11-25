// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Sticky vendor failover state: failures, month block, healthy pick
// Flo: run ok > reset | run failed > count, N in a row skips the vendor for a day | denied (401/402/403) > skip until next month | full and nothing to purge > skip a day
// I/O: local Db table fovr + flag table + vendor name + clock (caller) > bool or pick index
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig"); const civi = @import("ut-date-civi.zig");
const CF = .{ .dayz = 86400000 };
pub fn failOkay(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64) !bool { var stmt = try dbzz.prep("SELECT unti FROM fovr WHERE name=?1;"); defer stmt.fini(); try stmt.bindText(1, name); if (!try stmt.step()) return true; return stmt.colzIntz(0) <= nowz; }
pub fn failUnti(dbzz: *sqli.Dbzz, name: []const u8) !i64 { var stmt = try dbzz.prep("SELECT unti FROM fovr WHERE name=?1;"); defer stmt.fini(); try stmt.bindText(1, name); if (!try stmt.step()) return 0; return stmt.colzIntz(0); }
pub fn failGood(dbzz: *sqli.Dbzz, name: []const u8) !void { var stmt = try dbzz.prep("INSERT INTO fovr(name,fail,unti,live) VALUES(?1,0,0,0) ON CONFLICT(name) DO UPDATE SET fail=0,unti=0;"); defer stmt.fini(); try stmt.bindText(1, name); _ = try stmt.step(); }
pub fn failPing(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64) !void { var stmt = try dbzz.prep("INSERT INTO fovr(name,fail,unti,live) VALUES(?1,0,0,?2) ON CONFLICT(name) DO UPDATE SET fail=0,live=?2;"); defer stmt.fini(); try stmt.bindText(1, name); try stmt.bindIntz(2, nowz); _ = try stmt.step(); }
pub fn failBadz(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64, blok: bool, maxr: u32) !void { var selz = try dbzz.prep("SELECT fail,unti FROM fovr WHERE name=?1;"); defer selz.fini(); try selz.bindText(1, name); var fail: i64 = 0; var unti: i64 = 0; if (try selz.step()) { fail = selz.colzIntz(0); unti = selz.colzIntz(1); } fail += 1; if (blok) { unti = @max(unti, civi.civiNext(nowz)); fail = 0; } else if (fail >= maxr) { unti = @max(unti, nowz + CF.dayz); fail = 0; } var updz = try dbzz.prep("INSERT INTO fovr(name,fail,unti,live) VALUES(?1,?2,?3,0) ON CONFLICT(name) DO UPDATE SET fail=?2,unti=?3;"); defer updz.fini(); try updz.bindText(1, name); try updz.bindIntz(2, fail); try updz.bindIntz(3, unti); _ = try updz.step(); }
pub fn failFull(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64) !void { const unti = @max(try failUnti(dbzz, name), nowz + CF.dayz); var stmt = try dbzz.prep("INSERT INTO fovr(name,fail,unti,live) VALUES(?1,0,?2,0) ON CONFLICT(name) DO UPDATE SET unti=?2;"); defer stmt.fini(); try stmt.bindText(1, name); try stmt.bindIntz(2, unti); _ = try stmt.step(); }
pub fn failFirs(dbzz: *sqli.Dbzz, orde: []const []const u8, skip: []const []const u8, nowz: i64) !?usize { for (orde, 0..) |name, indx| { var skpz = false; for (skip) |each| { if (std.mem.eql(u8, each, name)) skpz = true; } if (skpz) continue; if (try failOkay(dbzz, name, nowz)) return indx; } return null; }
pub fn flagGetz(dbzz: *sqli.Dbzz, name: []const u8) !i64 { var stmt = try dbzz.prep("SELECT valu FROM flag WHERE name=?1;"); defer stmt.fini(); try stmt.bindText(1, name); if (!try stmt.step()) return 0; return stmt.colzIntz(0); }
pub fn flagSetz(dbzz: *sqli.Dbzz, name: []const u8, valu: i64) !void { var stmt = try dbzz.prep("INSERT INTO flag(name,valu) VALUES(?1,?2) ON CONFLICT(name) DO UPDATE SET valu=?2;"); defer stmt.fini(); try stmt.bindText(1, name); try stmt.bindIntz(2, valu); _ = try stmt.step(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
