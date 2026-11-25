// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: UTC calendar math: dates to days, month starts
// Flo: civil date > days since 1970 > milliseconds; parse YYYYMMDD or YYYYMMDDTHHMMSSZ
// I/O: epoch milliseconds or date text > milliseconds (no clock, no allocation)
// ===================================================================
const std = @import("std");
const CF = .{ .dayz = 86400000 };
pub fn civiDays(year: i64, mont: i64, dayz: i64) i64 { const yeaz = if (mont <= 2) year - 1 else year; const eraz = @divFloor(yeaz, 400); const yoez = yeaz - eraz * 400; const mpzz = @mod(mont + 9, 12); const doyz = @divFloor(153 * mpzz + 2, 5) + dayz - 1; const doez = yoez * 365 + @divFloor(yoez, 4) - @divFloor(yoez, 100) + doyz; return eraz * 146097 + doez - 719468; }
pub fn civiNext(mill: i64) i64 { const secs: u64 = @intCast(@max(@divFloor(mill, 1000), 0)); const epsz: std.time.epoch.EpochSeconds = .{ .secs = secs }; const yday = epsz.getEpochDay().calculateYearDay(); const mday = yday.calculateMonthDay(); const mont: i64 = mday.month.numeric(); const year: i64 = yday.year; if (mont == 12) return civiDays(year + 1, 1, 1) * CF.dayz; return civiDays(year, mont + 1, 1) * CF.dayz; }
fn digiNumz(text: []const u8) ?i64 { var outp: i64 = 0; for (text) |byte| { if (!std.ascii.isDigit(byte)) return null; outp = outp * 10 + (byte - '0'); } return outp; }
pub fn civiPars(text: []const u8) ?i64 { if (text.len < 8) return null; const year = digiNumz(text[0..4]) orelse return null; const mont = digiNumz(text[4..6]) orelse return null; const dayz = digiNumz(text[6..8]) orelse return null; if (mont < 1 or mont > 12 or dayz < 1 or dayz > 31) return null; var outp = civiDays(year, mont, dayz) * CF.dayz; if (text.len >= 15 and text[8] == 'T') { const hour = digiNumz(text[9..11]) orelse return null; const minu = digiNumz(text[11..13]) orelse return null; const seco = digiNumz(text[13..15]) orelse return null; if (hour > 23 or minu > 59 or seco > 60) return null; outp += (hour * 3600 + minu * 60 + seco) * 1000; } return outp; }
pub fn civiDayz(mill: i64, buff: *[8]u8) []const u8 { const secs: u64 = @intCast(@max(@divFloor(mill, 1000), 0)); const epsz: std.time.epoch.EpochSeconds = .{ .secs = secs }; const yday = epsz.getEpochDay().calculateYearDay(); const mday = yday.calculateMonthDay(); return std.fmt.bufPrint(buff, "{d:0>4}{d:0>2}{d:0>2}", .{ yday.year, mday.month.numeric(), mday.day_index + 1 }) catch buff[0..0]; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
