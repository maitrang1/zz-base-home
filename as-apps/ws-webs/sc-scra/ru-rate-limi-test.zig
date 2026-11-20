// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ru-rate-limi: gap, jitter bounds, hold, hosts apart
// Flo: mark hosts > check waits at times > hold with Retry-After
// I/O: ms values > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const rate = @import("ru-rate-limi.zig");
test "fresh host waits 0; after mark it waits gap..gap+jitter, then 0" { var rat = rate.Rate.init(std.testing.allocator, 7); defer rat.deinit(); try std.testing.expectEqual(@as(i64, 0), rat.wait("a.com", 1000)); var indx: usize = 0; while (indx < 50) : (indx += 1) { try rat.mark("a.com", 1000, 1000); const wait = rat.wait("a.com", 1000); try std.testing.expect(wait >= 1000 and wait <= 1250); } try std.testing.expectEqual(@as(i64, 0), rat.wait("a.com", 5000)); }
test "hosts are independent" { var rat = rate.Rate.init(std.testing.allocator, 1); defer rat.deinit(); try rat.mark("a.com", 0, 1000); try std.testing.expect(rat.wait("a.com", 0) >= 1000); try std.testing.expectEqual(@as(i64, 0), rat.wait("b.com", 0)); }
test "Retry-After holds the host, never shortens an existing wait, is capped" { var rat = rate.Rate.init(std.testing.allocator, 1); defer rat.deinit(); try rat.hold("a.com", 0, 7000); try std.testing.expectEqual(@as(i64, 7000), rat.wait("a.com", 0)); try rat.hold("a.com", 0, 1000); try std.testing.expectEqual(@as(i64, 7000), rat.wait("a.com", 0)); try rat.hold("a.com", 0, std.math.maxInt(i64)); try std.testing.expectEqual(@as(i64, 3600000), rat.wait("a.com", 0)); try rat.hold("b.com", 0, -5); try std.testing.expectEqual(@as(i64, 0), rat.wait("b.com", 0)); }
test "tiny gap has no jitter, zero gap is fine" { var rat = rate.Rate.init(std.testing.allocator, 1); defer rat.deinit(); try rat.mark("a.com", 0, 3); try std.testing.expectEqual(@as(i64, 3), rat.wait("a.com", 0)); try rat.mark("a.com", 10, 0); try std.testing.expectEqual(@as(i64, 0), rat.wait("a.com", 10)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
