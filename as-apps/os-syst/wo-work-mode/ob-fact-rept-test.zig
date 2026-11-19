// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for fact folding and rendering
// Flo: precedence of codes > exact text > exact JSON
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const fcts = @import("ob-fact-rept.zig");
fn mk(stat: fcts.Stat) fcts.Fact { return .{ .name = "n", .stat = stat, .note = "x" }; }
test "empty list and skips are ok" {
try std.testing.expectEqual(.okay, fcts.codeOf(&.{}));
try std.testing.expectEqual(.okay, fcts.codeOf(&.{ mk(.skip), mk(.okay) }));
}
test "precedence: fail beats drift beats blocked beats ok" {
try std.testing.expectEqual(.bloc, fcts.codeOf(&.{ mk(.okay), mk(.bloc) }));
try std.testing.expectEqual(.drif, fcts.codeOf(&.{ mk(.bloc), mk(.drif), mk(.okay) }));
try std.testing.expectEqual(.fail, fcts.codeOf(&.{ mk(.drif), mk(.bloc), mk(.fail) }));
try std.testing.expectEqual(.fail, fcts.codeOf(&.{ mk(.fail), mk(.drif) }));
}
test "text lines are tab separated: stat name note" {
var buff: std.Io.Writer.Allocating = .init(std.testing.allocator);
defer buff.deinit();
try fcts.rendText(&buff.writer, &.{ .{ .name = "hook", .stat = .drif, .note = "bad" }, .{ .name = "tool", .stat = .okay, .note = "" } });
try std.testing.expectEqualStrings("drif\thook\tbad\nokay\ttool\t\n", buff.written());
}
test "a note with newlines, tabs or CR stays on one line" {
var buff: std.Io.Writer.Allocating = .init(std.testing.allocator);
defer buff.deinit();
try fcts.rendText(&buff.writer, &.{.{ .name = "n", .stat = .fail, .note = "a\nb\tc\r\nd" }});
try std.testing.expectEqualStrings("fail\tn\ta b c  d\n", buff.written());
}
test "json carries the folded code and every fact" {
var buff: std.Io.Writer.Allocating = .init(std.testing.allocator);
defer buff.deinit();
try fcts.rendJson(&buff.writer, &.{.{ .name = "hook", .stat = .drif, .note = "a\"b" }});
try std.testing.expectEqualStrings("{\"code\":3,\"facts\":[{\"name\":\"hook\",\"stat\":\"drif\",\"note\":\"a\\\"b\"}]}\n", buff.written());
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
