// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Upload outbox: what still has to reach the cloud
// Flo: add row (file by hash, record by URL) > list due rows > mark done or failed with backoff
// I/O: kind + key + time (pageSave, sync) > rows in outb; failures retry after 2^tries minutes, max 6 hours
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .pend = 0, .done = 1, .base = 60000, .capz = 21600000 };
pub const Item = struct { keyz: []const u8, tryz: i64 };
pub fn outbAdd(dbzz: *sqli.Db, kind: []const u8, keyz: []const u8, now: i64, again: bool) !void { var stmt = try dbzz.prep(if (again) "INSERT INTO outb(kind,keyz,stat,tryz,errz,timz) VALUES(?1,?2,0,0,'',?3) ON CONFLICT(kind,keyz) DO UPDATE SET stat=0,tryz=0,errz='',timz=?3;" else "INSERT OR IGNORE INTO outb(kind,keyz,stat,tryz,errz,timz) VALUES(?1,?2,0,0,'',?3);"); defer stmt.fini(); try stmt.bindText(1, kind); try stmt.bindText(2, keyz); try stmt.bindInt(3, now); _ = try stmt.step(); }
pub fn outbDue(dbzz: *sqli.Db, aren: std.mem.Allocator, kind: []const u8, now: i64, limz: i64) ![]Item { var stmt = try dbzz.prep("SELECT keyz,tryz FROM outb WHERE kind=?1 AND stat=0 AND timz<=?2 ORDER BY timz,keyz LIMIT ?3;"); defer stmt.fini(); try stmt.bindText(1, kind); try stmt.bindInt(2, now); try stmt.bindInt(3, limz); var list: std.ArrayList(Item) = .empty; while (try stmt.step()) try list.append(aren, .{ .keyz = try aren.dupe(u8, stmt.colText(0)), .tryz = stmt.colInt(1) }); return list.toOwnedSlice(aren); }
pub fn outbDone(dbzz: *sqli.Db, kind: []const u8, keyz: []const u8) !void { var stmt = try dbzz.prep("UPDATE outb SET stat=1,errz='' WHERE kind=?1 AND keyz=?2;"); defer stmt.fini(); try stmt.bindText(1, kind); try stmt.bindText(2, keyz); _ = try stmt.step(); }
pub fn outbFail(dbzz: *sqli.Db, kind: []const u8, keyz: []const u8, errz: []const u8, now: i64) !void { var sel = try dbzz.prep("SELECT tryz FROM outb WHERE kind=?1 AND keyz=?2;"); defer sel.fini(); try sel.bindText(1, kind); try sel.bindText(2, keyz); if (!try sel.step()) return; const tryz = sel.colInt(0) + 1; const expo: u6 = @intCast(@min(tryz, 20)); const wait = @min(CF.base *| (@as(i64, 1) << expo), CF.capz); var upd = try dbzz.prep("UPDATE outb SET tryz=?3,errz=?4,timz=?5 WHERE kind=?1 AND keyz=?2;"); defer upd.fini(); try upd.bindText(1, kind); try upd.bindText(2, keyz); try upd.bindInt(3, tryz); try upd.bindText(4, errz); try upd.bindInt(5, now + wait); _ = try upd.step(); }
pub fn outbCont(dbzz: *sqli.Db, stat: i64) !i64 { var stmt = try dbzz.prep("SELECT count(*) FROM outb WHERE stat=?1;"); defer stmt.fini(); try stmt.bindInt(1, stat); _ = try stmt.step(); return stmt.colInt(0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
