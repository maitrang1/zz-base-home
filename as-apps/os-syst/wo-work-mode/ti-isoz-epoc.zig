// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Parse an ISO-8601 time into epoch seconds (UTC)
// Flo: check fixed positions > fields > offset > days-from-civil math
// I/O: text like 2026-11-18T10:00:00Z > epoch seconds, or null when malformed
// ===================================================================
const std = @import("std");
const CF = .{ .daysec = 86400, .hourz = 3600, .minu = 60, .erad = 146097, .epoc = 719468 };
pub fn isoEpoc(text: []const u8) ?i64 {
if (text.len < 20 or text[4] != '-' or text[7] != '-' or (text[10] != 'T' and text[10] != 't') or text[13] != ':' or text[16] != ':') return null;
const yea = std.fmt.parseInt(i64, text[0..4], 10) catch return null;
const mon = std.fmt.parseInt(i64, text[5..7], 10) catch return null;
const day = std.fmt.parseInt(i64, text[8..10], 10) catch return null;
const hou = std.fmt.parseInt(i64, text[11..13], 10) catch return null;
const min = std.fmt.parseInt(i64, text[14..16], 10) catch return null;
const sec = std.fmt.parseInt(i64, text[17..19], 10) catch return null;
if (mon < 1 or mon > 12 or day < 1 or day > 31 or hou > 23 or min > 59 or sec > 60) return null;
var indx: usize = 19;
if (indx < text.len and text[indx] == '.') { indx += 1; while (indx < text.len and std.ascii.isDigit(text[indx])) indx += 1; }
var offs: i64 = 0;
if (indx >= text.len) return null;
if (text[indx] == 'Z' or text[indx] == 'z') { if (indx + 1 != text.len) return null; } else if (text[indx] == '+' or text[indx] == '-') {
if (text.len != indx + 6 or text[indx + 3] != ':') return null;
const oh = std.fmt.parseInt(i64, text[indx + 1 .. indx + 3], 10) catch return null;
const om = std.fmt.parseInt(i64, text[indx + 4 .. indx + 6], 10) catch return null;
offs = (oh * CF.hourz + om * CF.minu) * (if (text[indx] == '-') @as(i64, -1) else 1);
} else return null;
const yadj = if (mon <= 2) yea - 1 else yea;
const era = @divFloor(yadj, 400);
const yoe = yadj - era * 400;
const mpos = if (mon > 2) mon - 3 else mon + 9;
const doy = @divFloor(153 * mpos + 2, 5) + day - 1;
const doe = yoe * 365 + @divFloor(yoe, 4) - @divFloor(yoe, 100) + doy;
const days = era * CF.erad + doe - CF.epoc;
return days * CF.daysec + hou * CF.hourz + min * CF.minu + sec - offs;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
