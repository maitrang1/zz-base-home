// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Compare dotted versions, read a tool's version line
// Flo: take first token > split on dots > compare number by number
// I/O: two version texts > order, or null when a part is not a number
// ===================================================================
const std = @import("std");
pub fn firstTok(text: []const u8) []const u8 {
const trim = std.mem.trim(u8, text, " \r\n\t");
const endz = std.mem.indexOfAny(u8, trim, " \r\n\t") orelse trim.len;
return trim[0..endz];
}
pub fn versComp(left: []const u8, rite: []const u8) ?std.math.Order {
var lit = std.mem.splitScalar(u8, left, '.');
var rit = std.mem.splitScalar(u8, rite, '.');
while (true) {
const lpa = lit.next();
const rpa = rit.next();
if (lpa == null and rpa == null) return .eq;
const lnum = if (lpa) |part| (std.fmt.parseInt(u64, part, 10) catch return null) else 0;
const rnum = if (rpa) |part| (std.fmt.parseInt(u64, part, 10) catch return null) else 0;
if (lnum != rnum) return std.math.order(lnum, rnum);
}
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
