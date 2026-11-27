// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for exit codes and the fold order
// Flo: numeric values > fold both ways > worst code wins
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const exit = @import("ct-exit-code.zig");
test "codes keep the documented numbers" {
try std.testing.expectEqual(@as(u8, 0), @intFromEnum(exit.Code.okay));
try std.testing.expectEqual(@as(u8, 1), @intFromEnum(exit.Code.fail));
try std.testing.expectEqual(@as(u8, 2), @intFromEnum(exit.Code.usag));
try std.testing.expectEqual(@as(u8, 3), @intFromEnum(exit.Code.find));
try std.testing.expectEqual(@as(u8, 4), @intFromEnum(exit.Code.bloc));
}
test "fold: fail beats find beats bloc beats okay, both argument orders" {
const codz = [_]exit.Code{ .okay, .bloc, .find, .fail };
for (codz, 0..) |left, lidx| {
for (codz, 0..) |righ, ridx| {
const want = codz[@max(lidx, ridx)];
try std.testing.expectEqual(want, exit.foldz(left, righ));
}
}
}
test "fold keeps usage above find" {
try std.testing.expectEqual(exit.Code.usag, exit.foldz(.find, .usag));
try std.testing.expectEqual(exit.Code.fail, exit.foldz(.usag, .fail));
try std.testing.expectEqual(exit.Code.okay, exit.foldz(.okay, .okay));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
