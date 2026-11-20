// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-exit-code: job result to exit code
// Flo: feed counts > assert code
// I/O: counts > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const code = @import("ct-exit-code.zig");
test "clean run is 0" { try std.testing.expectEqual(@as(u8, 0), code.jobCode(3, 0, 0, 0, false)); try std.testing.expectEqual(@as(u8, 0), code.jobCode(0, 0, 0, 0, false)); }
test "halt or blocked wins over everything" { try std.testing.expectEqual(@as(u8, 4), code.jobCode(5, 0, 0, 0, true)); try std.testing.expectEqual(@as(u8, 4), code.jobCode(5, 2, 1, 1, false)); }
test "all failed is 1, partial is 3" { try std.testing.expectEqual(@as(u8, 1), code.jobCode(0, 2, 0, 0, false)); try std.testing.expectEqual(@as(u8, 3), code.jobCode(2, 1, 0, 0, false)); try std.testing.expectEqual(@as(u8, 3), code.jobCode(2, 0, 1, 0, false)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
