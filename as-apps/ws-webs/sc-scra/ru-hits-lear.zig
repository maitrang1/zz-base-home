// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Learn the best vendor per host and mode
// Flo: record each vendor result > drop rows older than 30 days > score = smoothed success rate, then cost per good page, then config order > ordered vendor names
// I/O: Db + host + mode + outcome (caller) > vendor name order (arena)
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .agez = 30 * 86400000 };
pub fn hitsRecz(dbzz: *sqli.Dbzz, host: []const u8, vend: []const u8, mode: i64, okay: bool, cred: u32, micr: i64, nowz: i64) !void { var stmt = try dbzz.prep("INSERT INTO hits(host,vend,mode,okay,fail,micr,cred,timz) VALUES(?1,?2,?3,?4,?5,?6,?7,?8) ON CONFLICT(host,vend,mode) DO UPDATE SET okay=okay+?4,fail=fail+?5,micr=micr+?6,cred=cred+?7,timz=?8;"); defer stmt.fini(); try stmt.bindText(1, host); try stmt.bindText(2, vend); try stmt.bindIntz(3, mode); try stmt.bindIntz(4, if (okay) 1 else 0); try stmt.bindIntz(5, if (okay) 0 else 1); try stmt.bindIntz(6, micr); try stmt.bindIntz(7, cred); try stmt.bindIntz(8, nowz); _ = try stmt.step(); }
const Sczz = struct { name: []const u8, rate: f64, cost: f64, ind2: usize };
fn bett(_: void, aaa2: Sczz, bbbz: Sczz) bool { if (@abs(aaa2.rate - bbbz.rate) > 1e-9) return aaa2.rate > bbbz.rate; if (@abs(aaa2.cost - bbbz.cost) > 1e-9) return aaa2.cost < bbbz.cost; return aaa2.ind2 < bbbz.ind2; }
pub fn hitsOrde(dbzz: *sqli.Dbzz, aren: std.mem.Allocator, host: []const u8, base: []const []const u8, mode: i64, nowz: i64) ![]const []const u8 { { var del2 = try dbzz.prep("DELETE FROM hits WHERE timz<?1;"); defer del2.fini(); try del2.bindIntz(1, nowz - CF.agez); _ = try del2.step(); } const list = try aren.alloc(Sczz, base.len); for (base, 0..) |name, ind2| { var okay: f64 = 0; var fail: f64 = 0; var spnd: f64 = 0; var stmt = try dbzz.prep("SELECT okay,fail,micr,cred FROM hits WHERE host=?1 AND vend=?2 AND mode=?3;"); defer stmt.fini(); try stmt.bindText(1, host); try stmt.bindText(2, name); try stmt.bindIntz(3, mode); if (try stmt.step()) { okay = @floatFromInt(stmt.colzIntz(0)); fail = @floatFromInt(stmt.colzIntz(1)); spnd = @floatFromInt(stmt.colzIntz(2) + stmt.colzIntz(3)); } list[ind2] = .{ .name = name, .rate = (okay + 1) / (okay + fail + 2), .cost = spnd / @max(okay, 1), .ind2 = ind2 }; } std.mem.sort(Sczz, list, {}, bett); const outp = try aren.alloc([]const u8, list.len); for (list, 0..) |item, ind3| outp[ind3] = item.name; return outp; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
