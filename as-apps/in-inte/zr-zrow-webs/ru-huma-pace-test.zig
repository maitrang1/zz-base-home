// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for human pace math
// Flo: delays stay in range and vary > warm-up ramp > caps > quiet hours across midnight
// I/O: seeded numbers > asserts
// Run: zig build test -Dfile=ru-huma-pace-test.zig
// ===================================================================
const std = @import("std"); const pace = @import("ru-huma-pace.zig"); const cfgz = @import("cf-conf-load.zig");
test "log-normal delay stays in range, varies, median near the middle" { var rng = pace.Rng.init(7); var lo: u64 = 1 << 60; var hi: u64 = 0; var sum: u64 = 0; for (0..2000) |_| { const dly = pace.logn(&rng, 90, 260); try std.testing.expect(dly >= 90 and dly <= 260); lo = @min(lo, dly); hi = @max(hi, dly); sum += dly; } try std.testing.expect(hi - lo > 60); const avg = sum / 2000; try std.testing.expect(avg > 120 and avg < 200); }
test "same seed same sequence, different seed differs" { var ra = pace.Rng.init(1); var rb = pace.Rng.init(1); var rc = pace.Rng.init(2); try std.testing.expectEqual(ra.next(), rb.next()); try std.testing.expect(ra.next() != rc.next()); }
test "degenerate ranges do not crash" { var rng = pace.Rng.init(3); try std.testing.expectEqual(@as(u64, 5), pace.logn(&rng, 5, 5)); try std.testing.expectEqual(@as(u64, 0), pace.logn(&rng, 0, 0)); try std.testing.expectEqual(@as(u64, 9), rng.span(9, 9)); }
test "warm-up ramps 20% to 100% and never above" { const dayz: i64 = 86400000; try std.testing.expectEqual(@as(u32, 20), pace.warmPerc(0, 0, 14)); try std.testing.expectEqual(@as(u32, 60), pace.warmPerc(0, 7 * dayz, 14)); try std.testing.expectEqual(@as(u32, 100), pace.warmPerc(0, 14 * dayz, 14)); try std.testing.expectEqual(@as(u32, 100), pace.warmPerc(0, 99 * dayz, 14)); try std.testing.expectEqual(@as(u32, 100), pace.warmPerc(0, 0, 0)); }
test "effective cap: at least 1 when base > 0, 0 stays 0" { try std.testing.expectEqual(@as(u32, 1), pace.capEff(3, 20)); try std.testing.expectEqual(@as(u32, 6), pace.capEff(30, 20)); try std.testing.expectEqual(@as(u32, 0), pace.capEff(0, 100)); try std.testing.expectEqual(@as(u32, 30), pace.capEff(30, 100)); }
test "quiet hours wrap midnight and honor the time zone" { const hour: i64 = 3600000; try std.testing.expect(pace.quietNow(23 * hour, 0, .{ 23, 6 })); try std.testing.expect(pace.quietNow(2 * hour, 0, .{ 23, 6 })); try std.testing.expect(!pace.quietNow(6 * hour, 0, .{ 23, 6 })); try std.testing.expect(!pace.quietNow(12 * hour, 0, .{ 23, 6 })); try std.testing.expect(pace.quietNow(16 * hour, 420, .{ 23, 6 })); try std.testing.expect(!pace.quietNow(1 * hour, 0, .{ 9, 9 })); try std.testing.expect(pace.quietNow(10 * hour, 0, .{ 9, 17 })); try std.testing.expectEqual(@as(u8, 7), pace.hourLocal(0, 420)); try std.testing.expectEqual(@as(u8, 23), pace.hourLocal(0, -60)); }
test "caps map to config keys" { const conf: cfgz.Conf = .{}; try std.testing.expectEqual(@as(u32, 10), pace.capOf(conf, .acct)); try std.testing.expectEqual(@as(u32, 5), pace.capOf(conf, .mone)); try std.testing.expectEqual(@as(u32, 300), pace.capOf(conf, .data)); }
test "scaled sleeps: 0 percent never sleeps" { try std.testing.expectEqual(@as(u64, 0), pace.scaled(5000, 0)); try std.testing.expectEqual(@as(u64, 2500), pace.scaled(5000, 50)); pace.nap(std.testing.io, 100000, 0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
