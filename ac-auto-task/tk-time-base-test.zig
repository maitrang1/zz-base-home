// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for civil date math and leap rules
// Flo: fixed dates > convert both ways > assert round trip
// I/O: civil dates > day numbers, weekdays
// ===================================================================
const std = @import("std"); const time = @import("tk-task-time.zig");
const tszz = std.testing; const Local = time.Local; const CronError = time.CronError; const PulseError = time.PulseError; const OnceError = time.OnceError; const SolarError = time.SolarError; const SolarEvent = time.SolarEvent; const ONCE_LATE_WINDOW_MIN = time.ONCE_LATE_WINDOW_MIN;
const daysFromCivil = time.daysFromCivil; const civiDays = time.civiDays; const localFromMinuteStamp = time.localFromMinuteStamp; const yearLeap = time.yearLeap; const montDays = time.montDays; const parseCron = time.parseCron; const cronMatch = time.cronMatch; const nextCronMinute = time.nextCronMinute; const parsePulse = time.parsePulse; const parseOnce = time.parseOnce; const onceDue = time.onceDue; const parseSolar = time.parseSolar; const sunzTime = time.sunzTime;
test "daysFromCivil / civilFromDays round-trip across leap boundaries" { const dats = [_][3]u16{ .{ 1970, 1, 1 }, .{ 2000, 2, 29 }, .{ 1900, 3, 1 }, .{ 2026, 8, 17 }, .{ 2024, 2, 29 }, .{ 2100, 3, 1 }, .{ 1999, 12, 31 }, .{ 2038, 1, 19 } }; for (dats) |item| { const days = daysFromCivil(item[0], @intCast(item[1]), @intCast(item[2])); const back = civiDays(days); try tszz.expectEqual(item[0], back.year); try tszz.expectEqual(@as(u8, @intCast(item[1])), back.mont); try tszz.expectEqual(@as(u8, @intCast(item[2])), back.dayz); } }
test "epoch day is a Thursday" { try tszz.expectEqual(@as(i64, 0), daysFromCivil(1970, 1, 1)); try tszz.expectEqual(@as(u8, 4), localFromMinuteStamp(0).weekday); }
test "leap year rules include the 100/400 exceptions" { try tszz.expect(yearLeap(2024)); try tszz.expect(yearLeap(2000)); try tszz.expect(!yearLeap(1900)); try tszz.expect(!yearLeap(2100)); try tszz.expect(!yearLeap(2026)); try tszz.expectEqual(@as(u8, 29), montDays(2024, 2)); try tszz.expectEqual(@as(u8, 28), montDays(2026, 2)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
