// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Learn which vendor wins per host and mode, order by value
// Flo: record each vendor result > drop rows older than 30 days > score = smoothed success rate, then cost per good page, then config order > ordered vendor names
// I/O: Db + host + mode + outcome (caller) > vendor name order (arena)
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .agez = 30 * 86400000 };
pub fn hitsRec(dbzz: *sqli.Db, host: []const u8, vend: []const u8, mode: i64, okay: bool, cred: u32, micr: i64, now: i64) !void { var stmt = try dbzz.prep("INSERT INTO hits(host,vend,mode,okay,fail,micr,cred,timz) VALUES(?1,?2,?3,?4,?5,?6,?7,?8) ON CONFLICT(host,vend,mode) DO UPDATE SET okay=okay+?4,fail=fail+?5,micr=micr+?6,cred=cred+?7,timz=?8;"); defer stmt.fini(); try stmt.bindText(1, host); try stmt.bindText(2, vend); try stmt.bindInt(3, mode); try stmt.bindInt(4, if (okay) 1 else 0); try stmt.bindInt(5, if (okay) 0 else 1); try stmt.bindInt(6, micr); try stmt.bindInt(7, cred); try stmt.bindInt(8, now); _ = try stmt.step(); }
const Sc = struct { name: []const u8, rate: f64, cost: f64, idx: usize };
fn better(_: void, aaa: Sc, bbb: Sc) bool { if (@abs(aaa.rate - bbb.rate) > 1e-9) return aaa.rate > bbb.rate; if (@abs(aaa.cost - bbb.cost) > 1e-9) return aaa.cost < bbb.cost; return aaa.idx < bbb.idx; }
pub fn hitsOrde(dbzz: *sqli.Db, aren: std.mem.Allocator, host: []const u8, base: []const []const u8, mode: i64, now: i64) ![]const []const u8 { { var del = try dbzz.prep("DELETE FROM hits WHERE timz<?1;"); defer del.fini(); try del.bindInt(1, now - CF.agez); _ = try del.step(); } const list = try aren.alloc(Sc, base.len); for (base, 0..) |name, idx| { var okay: f64 = 0; var fail: f64 = 0; var spnd: f64 = 0; var stmt = try dbzz.prep("SELECT okay,fail,micr,cred FROM hits WHERE host=?1 AND vend=?2 AND mode=?3;"); defer stmt.fini(); try stmt.bindText(1, host); try stmt.bindText(2, name); try stmt.bindInt(3, mode); if (try stmt.step()) { okay = @floatFromInt(stmt.colInt(0)); fail = @floatFromInt(stmt.colInt(1)); spnd = @floatFromInt(stmt.colInt(2) + stmt.colInt(3)); } list[idx] = .{ .name = name, .rate = (okay + 1) / (okay + fail + 2), .cost = spnd / @max(okay, 1), .idx = idx }; } std.mem.sort(Sc, list, {}, better); const outp = try aren.alloc([]const u8, list.len); for (list, 0..) |item, ix| outp[ix] = item.name; return outp; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
