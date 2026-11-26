// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests login watch: saved state parse
// Flo: parse the state line > bad lines read as unknown
// I/O: text > Mark > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const aliv = @import("ct-comm-aliv.zig");
test "state line: ok and needlogin parse, the alert time is kept, junk reads as unknown" { const good = aliv.markParse("1795699768973 needlogin 1795699000000\n"); try std.testing.expectEqualStrings("needlogin", good.state); try std.testing.expectEqual(@as(i64, 1795699000000), good.noted); const plain = aliv.markParse("1795699768973 ok 0\n"); try std.testing.expectEqualStrings("ok", plain.state); try std.testing.expectEqual(@as(i64, 0), plain.noted); try std.testing.expectEqualStrings("", aliv.markParse("").state); try std.testing.expectEqualStrings("", aliv.markParse("123").state); try std.testing.expectEqual(@as(i64, 0), aliv.markParse("1 ok x").noted); try std.testing.expectEqual(@as(i64, 1795699768973), good.at); }
test "look is due after the gap, never while dead, at once when never checked" { const hour: i64 = 3600 * 1000; try std.testing.expect(aliv.dueLook(.{}, 5 * hour, 8)); try std.testing.expect(!aliv.dueLook(.{ .state = "ok", .at = 2 * hour }, 9 * hour, 8)); try std.testing.expect(aliv.dueLook(.{ .state = "ok", .at = 1 * hour }, 9 * hour, 8)); try std.testing.expect(!aliv.dueLook(.{ .state = "needlogin", .at = 1 * hour }, 99 * hour, 8)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
