// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Upload outbox: what still has to reach the cloud
// Flo: add row (file by hash, record by URL) > list due rows > mark done or failed with backoff
// I/O: kind + key + time (pageSave, sync) > rows in outb; failures retry after 2^tries minutes, max 6 hours
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .pend = 0, .done = 1, .base = 60000, .capz = 21600000 };
pub const Item = struct { keyz: []const u8, tryz: i64 };
pub fn outbAddz(dbzz: *sqli.Dbzz, kind: []const u8, keyz: []const u8, nowz: i64, agai: bool) !void { var stmt = try dbzz.prep(if (agai) "INSERT INTO outb(kind,keyz,stat,tryz,errz,timz) VALUES(?1,?2,0,0,'',?3) ON CONFLICT(kind,keyz) DO UPDATE SET stat=0,tryz=0,errz='',timz=?3;" else "INSERT OR IGNORE INTO outb(kind,keyz,stat,tryz,errz,timz) VALUES(?1,?2,0,0,'',?3);"); defer stmt.fini(); try stmt.bindText(1, kind); try stmt.bindText(2, keyz); try stmt.bindIntz(3, nowz); _ = try stmt.step(); }
pub fn outbDuez(dbzz: *sqli.Dbzz, aren: std.mem.Allocator, kind: []const u8, nowz: i64, limz: i64) ![]Item { var stmt = try dbzz.prep("SELECT keyz,tryz FROM outb WHERE kind=?1 AND stat=0 AND timz<=?2 ORDER BY timz,keyz LIMIT ?3;"); defer stmt.fini(); try stmt.bindText(1, kind); try stmt.bindIntz(2, nowz); try stmt.bindIntz(3, limz); var list: std.ArrayList(Item) = .empty; while (try stmt.step()) try list.append(aren, .{ .keyz = try aren.dupe(u8, stmt.colzText(0)), .tryz = stmt.colzIntz(1) }); return list.toOwnedSlice(aren); }
pub fn outbDone(dbzz: *sqli.Dbzz, kind: []const u8, keyz: []const u8) !void { var stmt = try dbzz.prep("UPDATE outb SET stat=1,errz='' WHERE kind=?1 AND keyz=?2;"); defer stmt.fini(); try stmt.bindText(1, kind); try stmt.bindText(2, keyz); _ = try stmt.step(); }
pub fn outbFail(dbzz: *sqli.Dbzz, kind: []const u8, keyz: []const u8, errz: []const u8, nowz: i64) !void { var selz = try dbzz.prep("SELECT tryz FROM outb WHERE kind=?1 AND keyz=?2;"); defer selz.fini(); try selz.bindText(1, kind); try selz.bindText(2, keyz); if (!try selz.step()) return; const tryz = selz.colzIntz(0) + 1; const expo: u6 = @intCast(@min(tryz, 20)); const wait = @min(CF.base *| (@as(i64, 1) << expo), CF.capz); var updz = try dbzz.prep("UPDATE outb SET tryz=?3,errz=?4,timz=?5 WHERE kind=?1 AND keyz=?2;"); defer updz.fini(); try updz.bindText(1, kind); try updz.bindText(2, keyz); try updz.bindIntz(3, tryz); try updz.bindText(4, errz); try updz.bindIntz(5, nowz + wait); _ = try updz.step(); }
pub fn outbSoon(dbzz: *sqli.Dbzz, nowz: i64) !void { var stmt = try dbzz.prep("UPDATE outb SET timz=?1 WHERE stat=0 AND timz>?1;"); defer stmt.fini(); try stmt.bindIntz(1, nowz); _ = try stmt.step(); }
pub fn outbCont(dbzz: *sqli.Dbzz, stat: i64) !i64 { var stmt = try dbzz.prep("SELECT count(*) FROM outb WHERE stat=?1;"); defer stmt.fini(); try stmt.bindIntz(1, stat); _ = try stmt.step(); return stmt.colzIntz(0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
