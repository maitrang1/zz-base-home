// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Recrawl schedule: unchanged pages slow down, changed speed up
// Flo: start interval > unchanged = x2 up to cap > changed = /2 down to floor > list due pages > put them back in the frontier
// I/O: page row + changed flag + Conf (pageSave) > interval ms; Db + time (walker) > due URLs, frontier rows reset
// ===================================================================
const std = @import("std"); const inde = @import("st-page-inde.zig"); const sqli = @import("st-stor-sqli.zig"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .msec = 1000 };
pub fn reviNext(prev: ?inde.Rowz, chan: bool, conf: cfgz.Conf) i64 { const star = @as(i64, conf.revi_star_seco) * CF.msec; const floo = @as(i64, conf.revi_floo_seco) * CF.msec; const capz = @as(i64, conf.revi_capz_seco) * CF.msec; const row2 = prev orelse return star; if (chan) return @max(@divTrunc(row2.intv, 2), floo); return @min(row2.intv *| 2, capz); }
pub fn reviDuez(dbzz: *sqli.Dbzz, aren: std.mem.Allocator, nowz: i64, limz: i64) ![]const []const u8 { var stmt = try dbzz.prep("SELECT urlz FROM page WHERE next<=?1 ORDER BY next LIMIT ?2;"); defer stmt.fini(); try stmt.bindIntz(1, nowz); try stmt.bindIntz(2, limz); var list: std.ArrayList([]const u8) = .empty; while (try stmt.step()) try list.append(aren, try aren.dupe(u8, stmt.colzText(0))); return list.toOwnedSlice(aren); }
pub fn reviQueu(dbzz: *sqli.Dbzz, urlz: []const u8, host: []const u8, nowz: i64) !void { var stmt = try dbzz.prep("INSERT INTO fron(urlz,host,stat,tryz,next,errz,addz) VALUES(?1,?2,0,0,?3,'',?3) ON CONFLICT(urlz) DO UPDATE SET stat=0,tryz=0,next=?3,errz='' WHERE stat=1;"); defer stmt.fini(); try stmt.bindText(1, urlz); try stmt.bindText(2, host); try stmt.bindIntz(3, nowz); _ = try stmt.step(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
