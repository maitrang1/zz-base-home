// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the fault-injection counter
// Flo: unset never fails > set fails exactly at that step > counts steps
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const tick = @import("ut-faul-tick.zig");
test "unset never fails and counts" {
var tck: tick.Tick = .{};
for (0..50) |_| try tck.step();
try std.testing.expectEqual(@as(usize, 50), tck.seen);
}
test "left=0 fails on the first step" {
var tck: tick.Tick = .{ .left = 0 };
try std.testing.expectError(error.Injected, tck.step());
}
test "left=2 passes two steps and fails the third, every time after" {
var tck: tick.Tick = .{ .left = 2 };
try tck.step();
try tck.step();
try std.testing.expectError(error.Injected, tck.step());
try std.testing.expectError(error.Injected, tck.step());
try std.testing.expectEqual(@as(usize, 4), tck.seen);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
