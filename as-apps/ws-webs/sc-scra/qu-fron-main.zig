// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: URL frontier: seen-set, backoff retries, dead-letter queue
// Flo: add canonical URL once > pick due rows > claim > done or fail with backoff > dead after max tries > resume claims after a crash
// I/O: canonical URLs + time (caller) > rows in the fron table (SQLite)
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .pend = 0, .done = 1, .dead = 2, .runn = 3, .capz = 3600000 };
pub const Item = struct { urlz: []const u8, host: []const u8, tryz: i64, errz: []const u8 };
pub fn fronAdd(dbzz: *sqli.Db, urlz: []const u8, host: []const u8, now: i64) !bool { var stmt = try dbzz.prep("INSERT OR IGNORE INTO fron(urlz,host,stat,tryz,next,errz,addz) VALUES(?1,?2,0,0,?3,'',?3);"); defer stmt.fini(); try stmt.bindText(1, urlz); try stmt.bindText(2, host); try stmt.bindInt(3, now); _ = try stmt.step(); return dbzz.changes() > 0; }
pub fn fronDue(dbzz: *sqli.Db, aren: std.mem.Allocator, now: i64, limz: i64) ![]Item { var stmt = try dbzz.prep("SELECT urlz,host,tryz,errz FROM fron WHERE stat=0 AND next<=?1 ORDER BY next,addz LIMIT ?2;"); defer stmt.fini(); try stmt.bindInt(1, now); try stmt.bindInt(2, limz); var list: std.ArrayList(Item) = .empty; while (try stmt.step()) try list.append(aren, .{ .urlz = try aren.dupe(u8, stmt.colText(0)), .host = try aren.dupe(u8, stmt.colText(1)), .tryz = stmt.colInt(2), .errz = try aren.dupe(u8, stmt.colText(3)) }); return list.toOwnedSlice(aren); }
fn setStat(dbzz: *sqli.Db, urlz: []const u8, stat: i64) !void { var stmt = try dbzz.prep("UPDATE fron SET stat=?2 WHERE urlz=?1;"); defer stmt.fini(); try stmt.bindText(1, urlz); try stmt.bindInt(2, stat); _ = try stmt.step(); if (dbzz.changes() == 0) return error.NotFound; }
pub fn fronLock(dbzz: *sqli.Db, urlz: []const u8) !void { try setStat(dbzz, urlz, CF.runn); }
pub fn fronDone(dbzz: *sqli.Db, urlz: []const u8) !void { try setStat(dbzz, urlz, CF.done); }
pub fn fronFail(dbzz: *sqli.Db, urlz: []const u8, errz: []const u8, now: i64, maxz: i64, base: i64) !bool { var stmt = try dbzz.prep("SELECT tryz FROM fron WHERE urlz=?1;"); defer stmt.fini(); try stmt.bindText(1, urlz); if (!try stmt.step()) return error.NotFound; const tryz = stmt.colInt(0) + 1; const dead = tryz >= maxz; const expo: u6 = @intCast(@min(tryz, 20)); const wait = @min(base *| (@as(i64, 1) << expo), CF.capz); var upd = try dbzz.prep("UPDATE fron SET stat=?2,tryz=?3,next=?4,errz=?5 WHERE urlz=?1;"); defer upd.fini(); try upd.bindText(1, urlz); try upd.bindInt(2, if (dead) CF.dead else CF.pend); try upd.bindInt(3, tryz); try upd.bindInt(4, now + wait); try upd.bindText(5, errz); _ = try upd.step(); return dead; }
pub fn fronResume(dbzz: *sqli.Db) !i64 { try dbzz.exec("UPDATE fron SET stat=0 WHERE stat=3;"); return dbzz.changes(); }
pub fn fronRetr(dbzz: *sqli.Db, urlz: []const u8, now: i64) !void { var stmt = try dbzz.prep("UPDATE fron SET stat=0,tryz=0,next=?2,errz='' WHERE urlz=?1 AND stat=2;"); defer stmt.fini(); try stmt.bindText(1, urlz); try stmt.bindInt(2, now); _ = try stmt.step(); if (dbzz.changes() == 0) return error.NotFound; }
pub fn fronSoon(dbzz: *sqli.Db) !?i64 { var stmt = try dbzz.prep("SELECT min(next) FROM fron WHERE stat=0;"); defer stmt.fini(); if (!try stmt.step()) return null; const text = stmt.colText(0); if (text.len == 0) return null; return stmt.colInt(0); }
pub fn fronCont(dbzz: *sqli.Db, stat: i64) !i64 { var stmt = try dbzz.prep("SELECT count(*) FROM fron WHERE stat=?1;"); defer stmt.fini(); try stmt.bindInt(1, stat); _ = try stmt.step(); return stmt.colInt(0); }
pub fn fronDead(dbzz: *sqli.Db, aren: std.mem.Allocator) ![]Item { var stmt = try dbzz.prep("SELECT urlz,host,tryz,errz FROM fron WHERE stat=2 ORDER BY addz;"); defer stmt.fini(); var list: std.ArrayList(Item) = .empty; while (try stmt.step()) try list.append(aren, .{ .urlz = try aren.dupe(u8, stmt.colText(0)), .host = try aren.dupe(u8, stmt.colText(1)), .tryz = stmt.colInt(2), .errz = try aren.dupe(u8, stmt.colText(3)) }); return list.toOwnedSlice(aren); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
