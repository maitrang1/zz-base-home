// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-exit-code: every mapping once
// Flo: call each mapper with representative inputs > compare codes
// I/O: words and counts > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const exit = @import("ct-exit-code.zig");
test "page outcomes" { try std.testing.expectEqual(@as(u8, 0), exit.outcCode("new", 200)); try std.testing.expectEqual(@as(u8, 0), exit.outcCode("notm", 304)); try std.testing.expectEqual(@as(u8, 0), exit.outcCode("http", 404)); try std.testing.expectEqual(@as(u8, 4), exit.outcCode("http", 403)); try std.testing.expectEqual(@as(u8, 4), exit.outcCode("http", 429)); try std.testing.expectEqual(@as(u8, 4), exit.outcCode("bloc", 200)); try std.testing.expectEqual(@as(u8, 1), exit.outcCode("http", 500)); try std.testing.expectEqual(@as(u8, 1), exit.outcCode("empt", 200)); try std.testing.expectEqual(@as(u8, 1), exit.outcCode("jbad", 200)); }
test "run summaries" { try std.testing.expectEqual(@as(u8, 0), exit.sumCode(5, 0, 0, 0, false, false)); try std.testing.expectEqual(@as(u8, 0), exit.sumCode(5, 2, 0, 0, false, false)); try std.testing.expectEqual(@as(u8, 3), exit.sumCode(5, 0, 0, 0, false, true)); try std.testing.expectEqual(@as(u8, 4), exit.sumCode(0, 3, 3, 1, false, false)); try std.testing.expectEqual(@as(u8, 1), exit.sumCode(0, 3, 0, 1, false, false)); try std.testing.expectEqual(@as(u8, 1), exit.sumCode(5, 9, 0, 0, true, false)); try std.testing.expectEqual(@as(u8, 4), exit.sumCode(0, 9, 5, 0, true, false)); try std.testing.expectEqual(@as(u8, 0), exit.sumCode(0, 0, 0, 0, false, false)); }
test "canary results" { try std.testing.expectEqual(@as(u8, 3), exit.canaCode(1, 5)); try std.testing.expectEqual(@as(u8, 1), exit.canaCode(0, 1)); try std.testing.expectEqual(@as(u8, 0), exit.canaCode(0, 0)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
