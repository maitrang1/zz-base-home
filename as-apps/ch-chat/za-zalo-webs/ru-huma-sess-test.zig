// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ru-huma-sess: deterministic day schedule, property over many days, reading time, check jitter
// Flo: seeded schedules > scan a whole day > assert bounds and share of active time
// I/O: numbers > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const hs = @import("ru-huma-sess.zig"); const T = std.testing;
const RNG: hs.Rng = .{ .actv = .{ 20, 60 }, .brek = .{ 5, 20 } };
const D: i64 = 86400000; const M: i64 = 60000;
test "same seed and day give the same schedule, another seed differs" { var diff: u32 = 0; var t: i64 = 0; while (t < D) : (t += 7 * M) { const one = hs.segAt(100 * D + t, 0, 42, RNG); const two = hs.segAt(100 * D + t, 0, 42, RNG); try T.expectEqual(one.active, two.active); try T.expectEqual(one.left_ms, two.left_ms); const three = hs.segAt(100 * D + t, 0, 43, RNG); if (three.left_ms != one.left_ms) diff += 1; } try T.expect(diff > 20); }
test "property: all segment lengths are in range, left time positive, active share is plausible" { var seed: u64 = 1; while (seed <= 200) : (seed += 1) { var t: i64 = 0; var act: i64 = 0; var total: i64 = 0; while (t < D) { const seg = hs.segAt(50 * D + t, 420, seed, RNG); try T.expect(seg.left_ms > 0); try T.expect(seg.left_ms <= 60 * M); if (seg.active) act += @min(seg.left_ms, D - t); total += @min(seg.left_ms, D - t); t += seg.left_ms; } try T.expectEqual(D, total); const share = @as(f64, @floatFromInt(act)) / @as(f64, @floatFromInt(D)); try T.expect(share > 0.5 and share < 0.95); } }
test "an active segment never exceeds its range and a break never exceeds its range" { var seed: u64 = 1; while (seed <= 100) : (seed += 1) { var t: i64 = 0; var prev_left: i64 = 0; var prev_active = true; var first = true; while (t < D) { const seg = hs.segAt(10 * D + t, 0, seed, RNG); if (!first and seg.active != prev_active) { try T.expect(prev_left >= 1); } const max_len: i64 = if (seg.active) 60 * M else 20 * M; try T.expect(seg.left_ms <= max_len); prev_active = seg.active; prev_left = seg.left_ms; first = false; t += seg.left_ms; } } }
test "reading time grows with length, stays under the cap, think time has a floor" { var prn = std.Random.DefaultPrng.init(5); const rnd = prn.random(); var short: u64 = 0; var long: u64 = 0; var idx: u32 = 0; while (idx < 300) : (idx += 1) { short += hs.readDelay(rnd, 10); long += hs.readDelay(rnd, 1500); } try T.expect(long > short * 2); try T.expect(short / 300 >= 600); idx = 0; while (idx < 300) : (idx += 1) { try T.expect(hs.readDelay(rnd, 1000000) <= 30000); } }
test "check interval stays within the jitter band around the base" { var prn = std.Random.DefaultPrng.init(9); const rnd = prn.random(); var lo: u32 = std.math.maxInt(u32); var hi: u32 = 0; var idx: u32 = 0; while (idx < 2000) : (idx += 1) { const gap = hs.nextCheck(rnd, 10); lo = @min(lo, gap); hi = @max(hi, gap); } try T.expect(lo >= 420000 and hi <= 780000); try T.expect(hi - lo > 200000); try T.expect(hs.nextCheck(rnd, 0) >= 42000); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
