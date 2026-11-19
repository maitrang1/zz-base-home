// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for solar parse and sun times
// Flo: parse event + offset > compute sun times > assert
// I/O: solar strings + date + lat/long > spec, times
// ===================================================================
const std = @import("std"); const time = @import("tk-task-time.zig");
const tszz = std.testing; const Local = time.Local; const CronError = time.CronError; const PulseError = time.PulseError; const OnceError = time.OnceError; const SolarError = time.SolarError; const SolarEvent = time.SolarEvent; const ONCE_LATE_WINDOW_MIN = time.ONCE_LATE_WINDOW_MIN;
const daysFromCivil = time.daysFromCivil; const civiDays = time.civiDays; const localFromMinuteStamp = time.localFromMinuteStamp; const yearLeap = time.yearLeap; const montDays = time.montDays; const parseCron = time.parseCron; const cronMatch = time.cronMatch; const nextCronMinute = time.nextCronMinute; const parsePulse = time.parsePulse; const parseOnce = time.parseOnce; const onceDue = time.onceDue; const parseSolar = time.parseSolar; const sunzTime = time.sunzTime;
test "parseSolar handles events and offsets" { try tszz.expectEqual(SolarEvent.sunrise, (try parseSolar("sunrise")).event); try tszz.expectEqual(@as(i32, 0), (try parseSolar("sunset")).offset_min); try tszz.expectEqual(@as(i32, -30), (try parseSolar("sunset-30")).offset_min); try tszz.expectEqual(@as(i32, 15), (try parseSolar("sunrise+15")).offset_min); try tszz.expectError(SolarError.BadFormat, parseSolar("noon")); try tszz.expectError(SolarError.BadFormat, parseSolar("sunrise 30")); try tszz.expectError(SolarError.BadOffset, parseSolar("sunrise+abc")); try tszz.expectError(SolarError.BadOffset, parseSolar("sunrise+9999")); }
test "sunTimes is plausible for a known place and returns null at the pole" { const anch = daysFromCivil(2026, 8, 17) * 86400; const sunz = sunzTime(anch, 21.0285, 105.8542); try tszz.expect(sunz.sunrise_unix != null); try tszz.expect(sunz.sunset_unix != null); const dayl = sunz.sunset_unix.? - sunz.sunrise_unix.?; try tszz.expect(dayl > 8 * 3600 and dayl < 16 * 3600); const june = daysFromCivil(2026, 6, 21) * 86400; const pola = sunzTime(june, 89.9, 0.0); try tszz.expect(pola.sunrise_unix == null); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
