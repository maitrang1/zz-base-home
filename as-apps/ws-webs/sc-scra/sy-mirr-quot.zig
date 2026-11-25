// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Counts monthly vendor calls to stay inside free quotas
// Flo: flag name = opsa + vendor + month > add calls as they happen > okay only while count plus need fits the cap > a new month starts at zero and old counters go
// I/O: Db + vendor name + clock > count or yes/no; counters live in the flag table, nothing leaves the machine
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig"); const fail = @import("ru-fail-over.zig"); const civi = @import("ut-date-civi.zig");
pub fn opsaKeyz(buff: []u8, vend: []const u8, nowz: i64) []const u8 { var dbuf: [8]u8 = undefined; const dayz = civi.civiDayz(nowz, &dbuf); return std.fmt.bufPrint(buff, "opsa_{s}_{s}", .{ vend, dayz[0..@min(6, dayz.len)] }) catch buff[0..0]; }
pub fn opsaGetz(dbzz: *sqli.Dbzz, vend: []const u8, nowz: i64) !i64 { var buff: [64]u8 = undefined; return fail.flagGetz(dbzz, opsaKeyz(&buff, vend, nowz)); }
pub fn opsaAddz(dbzz: *sqli.Dbzz, vend: []const u8, nowz: i64, plus: i64) !void { var buff: [64]u8 = undefined; const keyz = opsaKeyz(&buff, vend, nowz); const olds = try fail.flagGetz(dbzz, keyz); try fail.flagSetz(dbzz, keyz, olds + plus); if (olds != 0) return; var patz: [64]u8 = undefined; const like = std.fmt.bufPrint(&patz, "opsa_{s}_%", .{vend}) catch return; var stmt = try dbzz.prep("DELETE FROM flag WHERE name LIKE ?1 AND name<>?2;"); defer stmt.fini(); try stmt.bindText(1, like); try stmt.bindText(2, keyz); _ = try stmt.step(); }
pub fn opsaOkay(dbzz: *sqli.Dbzz, vend: []const u8, nowz: i64, maxz: u32, need: u32) !bool { return (try opsaGetz(dbzz, vend, nowz)) + need <= maxz; }
pub fn opsaHigh(dbzz: *sqli.Dbzz, vend: []const u8, nowz: i64, maxz: u32) !bool { return (try opsaGetz(dbzz, vend, nowz)) * 100 >= @as(i64, maxz) * 80; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
