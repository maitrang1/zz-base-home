// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ut-date-civi: known dates, month rollover, bad text
// Flo: fixed epoch values > assert
// I/O: numbers and text > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const civi = @import("ut-date-civi.zig");
test "known dates match the epoch" { try std.testing.expectEqual(@as(i64, 0), civi.civiDays(1970, 1, 1)); try std.testing.expectEqual(@as(i64, 20781), civi.civiDays(2026, 11, 24)); try std.testing.expectEqual(@as(i64, 11017), civi.civiDays(2000, 3, 1)); try std.testing.expectEqual(@as(i64, 19782), civi.civiDays(2024, 2, 29)); }
test "pack date names parse with and without time" { try std.testing.expectEqual(@as(i64, 1795478400000), civi.civiPars("20261124").?); try std.testing.expectEqual(@as(i64, 1795532989000), civi.civiPars("20261124T150949Z").?); try std.testing.expectEqual(@as(i64, 1795532989000), civi.civiPars("20261124T150949Z-3c43.pack").?); }
test "bad names are null, never a crash" { const bads = [_][]const u8{ "", "2026", "abcdefgh", "20261324", "20261100", "20261124T250000Z", "2026-11-24" }; for (bads) |badz| try std.testing.expect(civi.civiPars(badz) == null); }
test "start of next month, including December and a leap February" { try std.testing.expectEqual(@as(i64, 1796083200000), civi.civiNext(1795528470301)); try std.testing.expectEqual(civi.civiDays(2027, 1, 1) * 86400000, civi.civiNext(civi.civiDays(2026, 12, 31) * 86400000 + 5)); try std.testing.expectEqual(civi.civiDays(2024, 3, 1) * 86400000, civi.civiNext(civi.civiDays(2024, 2, 29) * 86400000)); }
test "day text is YYYYMMDD" { var buff: [8]u8 = undefined; try std.testing.expectEqualStrings("20261124", civi.civiDayz(1795528470301, &buff)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
