// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Civil date math and local wall-clock time
// Flo: libc localtime > Local fields; days/civil conversions; leap + month length
// I/O: unix time or minute stamp > Local, civil date
// ===================================================================
const std = @import("std"); const libc = @cImport({ @cInclude("time.h"); });
pub const CF = .{ .trim = " \t", .cron_minz = [5]i64{ 0, 0, 1, 1, 0 }, .cron_maxz = [5]i64{ 59, 23, 31, 12, 7 }, .scan = 366 * 4 * 1440 };
pub const Local = struct { year: u16, month: u8, day: u8, hour: u8, minute: u8, second: u8, weekday: u8, minute_stamp: i64 };
pub fn localNow() Local { return locaFrom(libc.time(null)); }
pub fn locaFrom(unix: libc.time_t) Local { var copy = unix; var btim: libc.struct_tm = undefined; const okzz = if (@import("builtin").os.tag == .windows) blk: { const ptrz = libc.localtime(&copy) orelse break :blk false; btim = ptrz.*; break :blk true; } else libc.localtime_r(&copy, &btim) != null; if (!okzz) return .{ .year = 1970, .month = 1, .day = 1, .hour = 0, .minute = 0, .second = 0, .weekday = 4, .minute_stamp = 0 }; const year: u16 = @intCast(btim.tm_year + 1900); const mont: u8 = @intCast(btim.tm_mon + 1); const dayz: u8 = @intCast(btim.tm_mday); const hour: u8 = @intCast(btim.tm_hour); const minu: u8 = @intCast(btim.tm_min); return .{ .year = year, .month = mont, .day = dayz, .hour = hour, .minute = minu, .second = @intCast(btim.tm_sec), .weekday = @intCast(btim.tm_wday), .minute_stamp = daysFromCivil(year, mont, dayz) * 1440 + @as(i64, hour) * 60 + @as(i64, minu) }; }
pub fn daysFromCivil(year: u16, mont: u8, dayz: u8) i64 { var yezz: i64 = year; if (mont <= 2) yezz -= 1; const eraz = @divFloor(yezz, 400); const yoez = yezz - eraz * 400; const mpzz: i64 = @mod(@as(i64, mont) + 9, 12); const doyz = @divFloor(153 * mpzz + 2, 5) + @as(i64, dayz) - 1; const doez = yoez * 365 + @divFloor(yoez, 4) - @divFloor(yoez, 100) + doyz; return eraz * 146097 + doez - 719468; }
pub fn yearLeap(year: u16) bool { return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0; }
pub fn montDays(year: u16, mont: u8) u8 { return switch (mont) { 1, 3, 5, 7, 8, 10, 12 => 31, 4, 6, 9, 11 => 30, 2 => if (yearLeap(year)) 29 else 28, else => 30 }; }
pub fn localFromMinuteStamp(stam: i64) Local { const days = @divFloor(stam, 1440); const mins = @mod(stam, 1440); const civi = civiDays(days); return .{ .year = civi.year, .month = civi.mont, .day = civi.dayz, .hour = @intCast(@divFloor(mins, 60)), .minute = @intCast(@mod(mins, 60)), .second = 0, .weekday = @intCast(@mod(days + 4, 7)), .minute_stamp = stam }; }
const Civi = struct { year: u16, mont: u8, dayz: u8 };
pub fn civiDays(days: i64) Civi { const zzzz = days + 719468; const eraz = @divFloor(zzzz, 146097); const doez = zzzz - eraz * 146097; const yoez = @divFloor(doez - @divFloor(doez, 1460) + @divFloor(doez, 36524) - @divFloor(doez, 146096), 365); const yezz = yoez + eraz * 400; const doyz = doez - (365 * yoez + @divFloor(yoez, 4) - @divFloor(yoez, 100)); const mpzz = @divFloor(5 * doyz + 2, 153); const dofm = doyz - @divFloor(153 * mpzz + 2, 5) + 1; const mont = if (mpzz < 10) mpzz + 3 else mpzz - 9; return .{ .year = @intCast(if (mont <= 2) yezz + 1 else yezz), .mont = @intCast(mont), .dayz = @intCast(dofm) }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
