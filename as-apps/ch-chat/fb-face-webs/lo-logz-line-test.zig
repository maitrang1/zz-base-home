// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the 2-line log event
// Flo: format fixed time > count lines > hostile text > clip
// I/O: lo-logz-line.zig pure formatter (no clock, no stderr)
// ===================================================================
const std = @import("std"); const logz = @import("lo-logz-line.zig");
fn lines(text: []const u8) usize { return std.mem.count(u8, text, "\n"); }
test "event is exactly 2 lines with module level time trace" { var buff: [640]u8 = undefined; const outp = logz.lineTwo(&buff, "conf", .erro, 1795528470301, "a1b2c3d4", "bad config", "unknown key", "remove it"); try std.testing.expectEqual(@as(usize, 2), lines(outp)); try std.testing.expectEqualStrings("conf | ERRO | 2026-11-24T13:54:30Z | a1b2c3d4\nbad config - unknown key; fix: remove it\n", outp); }
test "empty why and fix are left out" { var buff: [640]u8 = undefined; const outp = logz.lineTwo(&buff, "run", .info, 0, "00000000", "pace seed 7", "", ""); try std.testing.expectEqualStrings("run | INFO | 1970-01-01T00:00:00Z | 00000000\npace seed 7\n", outp); }
test "newlines and control bytes in text cannot add lines" { var buff: [640]u8 = undefined; const outp = logz.lineTwo(&buff, "x", .warn, 0, "t", "a\nb\r\nc", "d\ne", "f\x00g"); try std.testing.expectEqual(@as(usize, 2), lines(outp)); }
test "long text is clipped to one short line" { var buff: [640]u8 = undefined; var bigz: [5000]u8 = undefined; @memset(&bigz, 'z'); const outp = logz.lineTwo(&buff, "x", .erro, 0, "t", &bigz, &bigz, &bigz); try std.testing.expectEqual(@as(usize, 2), lines(outp)); try std.testing.expect(outp.len < 400); }
test "tiny buffer gives empty, never a crash" { var buff: [50]u8 = undefined; try std.testing.expectEqual(@as(usize, 0), logz.lineTwo(&buff, "x", .info, 0, "t", "a", "b", "c").len); }
test "trace id defaults to zeros before begin" { try std.testing.expectEqual(@as(usize, 8), logz.traceId().len); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
