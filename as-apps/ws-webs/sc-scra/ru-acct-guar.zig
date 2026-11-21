// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Per-account daily page cap, spacing and login-wall stop
// Flo: read account row > wall flag stops all > new UTC day resets count > cap check > spacing wait = last + gap > write row
// I/O: Db + account name + now + caps (caller) > wait ms; errors LoginWall DayCap
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .dayz = 86400000 };
pub const Take = struct { wait: u64 };
pub fn acctTake(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64, capz: u32, gapz: u64) !Take { var day2: i64 = -1; var con2: i64 = 0; var last: i64 = 0; var wall: i64 = 0; { var stmt = try dbzz.prep("SELECT day,cnt,last,wall FROM acct WHERE name=?1;"); defer stmt.fini(); try stmt.bindText(1, name); if (try stmt.step()) { day2 = stmt.colzIntz(0); con2 = stmt.colzIntz(1); last = stmt.colzIntz(2); wall = stmt.colzIntz(3); } } if (wall != 0) return error.LoginWall; const toda = @divFloor(nowz, CF.dayz); if (day2 != toda) con2 = 0; if (con2 >= capz) return error.DayCap; var wait: u64 = 0; if (last > 0 and nowz < last + @as(i64, @intCast(gapz))) wait = @intCast(last + @as(i64, @intCast(gapz)) - nowz); var stmt = try dbzz.prep("INSERT INTO acct(name,day,cnt,last,wall) VALUES(?1,?2,?3,?4,0) ON CONFLICT(name) DO UPDATE SET day=?2,cnt=?3,last=?4;"); defer stmt.fini(); try stmt.bindText(1, name); try stmt.bindIntz(2, toda); try stmt.bindIntz(3, con2 + 1); try stmt.bindIntz(4, nowz + @as(i64, @intCast(wait))); _ = try stmt.step(); return .{ .wait = wait }; }
pub fn acctWall(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64) !void { var stmt = try dbzz.prep("INSERT INTO acct(name,day,cnt,last,wall) VALUES(?1,?2,0,?3,1) ON CONFLICT(name) DO UPDATE SET wall=1;"); defer stmt.fini(); try stmt.bindText(1, name); try stmt.bindIntz(2, @divFloor(nowz, CF.dayz)); try stmt.bindIntz(3, nowz); _ = try stmt.step(); }
pub fn acctClea(dbzz: *sqli.Dbzz, name: []const u8) !void { var stmt = try dbzz.prep("UPDATE acct SET wall=0 WHERE name=?1;"); defer stmt.fini(); try stmt.bindText(1, name); _ = try stmt.step(); }
pub fn acctUsed(dbzz: *sqli.Dbzz, name: []const u8, nowz: i64) !i64 { var stmt = try dbzz.prep("SELECT cnt FROM acct WHERE name=?1 AND day=?2;"); defer stmt.fini(); try stmt.bindText(1, name); try stmt.bindIntz(2, @divFloor(nowz, CF.dayz)); if (!try stmt.step()) return 0; return stmt.colzIntz(0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
