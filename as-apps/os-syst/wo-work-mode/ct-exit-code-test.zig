// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the exit-code ladder values
// Flo: compare each code to the documented number
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const exit = @import("ct-exit-code.zig");
test "ladder numbers match the plan: 0 ok 1 failed 2 usage 3 drift 4 blocked" {
try std.testing.expectEqual(@as(u8, 0), @intFromEnum(exit.Code.okay));
try std.testing.expectEqual(@as(u8, 1), @intFromEnum(exit.Code.fail));
try std.testing.expectEqual(@as(u8, 2), @intFromEnum(exit.Code.usag));
try std.testing.expectEqual(@as(u8, 3), @intFromEnum(exit.Code.drif));
try std.testing.expectEqual(@as(u8, 4), @intFromEnum(exit.Code.bloc));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
