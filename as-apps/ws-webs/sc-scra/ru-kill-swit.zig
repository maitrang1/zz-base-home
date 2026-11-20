// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Kill switch: one stored flag that halts all spending
// Flo: set flag row 1/0 > read flag row (missing = off)
// I/O: Db + bool (caller) > bool; flag lives in the flag table
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
const CF = .{ .name = "kill" };
pub fn killGet(dbzz: *sqli.Db) !bool { var stmt = try dbzz.prep("SELECT valu FROM flag WHERE name=?1;"); defer stmt.fini(); try stmt.bindText(1, CF.name); if (!try stmt.step()) return false; return stmt.colInt(0) != 0; }
pub fn killSet(dbzz: *sqli.Db, onzz: bool) !void { var stmt = try dbzz.prep("INSERT INTO flag(name,valu) VALUES(?1,?2) ON CONFLICT(name) DO UPDATE SET valu=?2;"); defer stmt.fini(); try stmt.bindText(1, CF.name); try stmt.bindInt(2, if (onzz) 1 else 0); _ = try stmt.step(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
