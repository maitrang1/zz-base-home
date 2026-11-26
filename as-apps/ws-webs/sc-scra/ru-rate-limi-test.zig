// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ru-rate-limi: gap, jitter bounds, hold, hosts apart
// Flo: mark hosts > check waits at times > hold with Retry-After
// I/O: ms values > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const rate = @import("ru-rate-limi.zig");
test "fresh host waits 0; after mark it waits gap to 1.5 gap with a spread, then 0" { var ratz = rate.Rate.init(std.testing.allocator, 7); defer ratz.deinit(); try std.testing.expectEqual(@as(i64, 0), ratz.wait("a.com", 1000)); var seen = std.AutoHashMap(i64, void).init(std.testing.allocator); defer seen.deinit(); var longz: usize = 0; var indx: usize = 0; while (indx < 400) : (indx += 1) { try ratz.mark("a.com", 1000, 1000); const wait = ratz.wait("a.com", 1000); try std.testing.expect(wait >= 1000 and wait <= 1500); try seen.put(wait, {}); if (wait > 1250) longz += 1; } try std.testing.expect(seen.count() > 40); try std.testing.expect(longz > 20 and longz < 200); try std.testing.expectEqual(@as(i64, 0), ratz.wait("a.com", 5000)); }
test "hosts are independent" { var ratz = rate.Rate.init(std.testing.allocator, 1); defer ratz.deinit(); try ratz.mark("a.com", 0, 1000); try std.testing.expect(ratz.wait("a.com", 0) >= 1000); try std.testing.expectEqual(@as(i64, 0), ratz.wait("b.com", 0)); }
test "Retry-After holds the host, never shortens an existing wait, is capped" { var ratz = rate.Rate.init(std.testing.allocator, 1); defer ratz.deinit(); try ratz.hold("a.com", 0, 7000); try std.testing.expectEqual(@as(i64, 7000), ratz.wait("a.com", 0)); try ratz.hold("a.com", 0, 1000); try std.testing.expectEqual(@as(i64, 7000), ratz.wait("a.com", 0)); try ratz.hold("a.com", 0, std.math.maxInt(i64)); try std.testing.expectEqual(@as(i64, 3600000), ratz.wait("a.com", 0)); try ratz.hold("b.com", 0, -5); try std.testing.expectEqual(@as(i64, 0), ratz.wait("b.com", 0)); }
test "tiny gap has no jitter, zero gap is fine" { var ratz = rate.Rate.init(std.testing.allocator, 1); defer ratz.deinit(); try ratz.mark("a.com", 0, 3); try std.testing.expectEqual(@as(i64, 3), ratz.wait("a.com", 0)); try ratz.mark("a.com", 10, 0); try std.testing.expectEqual(@as(i64, 0), ratz.wait("a.com", 10)); }
test "the seed comes from real entropy: two seeds differ and are never zero" { const one = rate.Rate.seedOf(std.testing.io); const two = rate.Rate.seedOf(std.testing.io); try std.testing.expect(one != two); try std.testing.expect(one != 0 and two != 0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
