// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ru-brea-circ: trip, no early trip, recovery, latch
// Flo: push patterns > check the trip flag
// I/O: bool streams > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const brea = @import("ru-brea-circ.zig");
test "no trip before enough samples, trips at the failure share" { var brkz = brea.Brea.init(10, 6, 50); var indx: usize = 0; while (indx < 5) : (indx += 1) brkz.push(false); try std.testing.expect(!brkz.trip); brkz.push(false); try std.testing.expect(brkz.trip); }
test "healthy stream with a few failures never trips" { var brkz = brea.Brea.init(20, 10, 50); var indx: usize = 0; while (indx < 200) : (indx += 1) { brkz.push(indx % 10 != 0); try std.testing.expect(!brkz.trip); } }
test "window slides: old failures age out before the minimum is met" { var brkz = brea.Brea.init(10, 10, 50); var indx: usize = 0; while (indx < 4) : (indx += 1) brkz.push(false); while (indx < 40) : (indx += 1) brkz.push(true); try std.testing.expect(!brkz.trip); try std.testing.expectEqual(@as(u32, 0), brkz.fai2()); }
test "tripped stays latched until reset" { var brkz = brea.Brea.init(4, 4, 75); var indx: usize = 0; while (indx < 4) : (indx += 1) brkz.push(false); try std.testing.expect(brkz.trip); indx = 0; while (indx < 10) : (indx += 1) brkz.push(true); try std.testing.expect(brkz.trip); brkz.reset(); try std.testing.expect(!brkz.trip); }
test "window of 64 and silly inputs are safe" { var big2 = brea.Brea.init(255, 0, 200); var indx: usize = 0; while (indx < 300) : (indx += 1) big2.push(indx % 2 == 0); try std.testing.expect(big2.cntz <= 64); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
