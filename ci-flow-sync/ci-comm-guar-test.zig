// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the commit guard checks
// Flo: reserved names > path length > CR scan > case clashes
// I/O: none (pure fns) > pass or fail
// Run: zig test E:\zz-base-home\ci-flow-sync\ci-comm-guar-test.zig
// ===================================================================
const std = @import("std");
const guar = @import("ci-comm-guar.zig");
test "reserved names hit, normal names pass" {
try std.testing.expectEqual(@as(?guar.Kind, .resv), guar.pathChec("src/NUL.txt", 10));
try std.testing.expectEqual(@as(?guar.Kind, .resv), guar.pathChec("con/x.zig", 10));
try std.testing.expectEqual(@as(?guar.Kind, .resv), guar.pathChec("a/Com1", 10));
try std.testing.expectEqual(@as(?guar.Kind, null), guar.pathChec("a/console.txt", 10));
try std.testing.expectEqual(@as(?guar.Kind, null), guar.pathChec("a/b.zig", 10));
}
test "path length counts the root" {
const path = "a" ** 240;
try std.testing.expectEqual(@as(?guar.Kind, null), guar.pathChec(path, 10));
try std.testing.expectEqual(@as(?guar.Kind, .long), guar.pathChec(path, 30));
}
test "CR scan skips binary and CRLF-ok files" {
try std.testing.expect(guar.textHasCr("a\r\nb"));
try std.testing.expect(!guar.textHasCr("a\nb"));
try std.testing.expect(!guar.textHasCr("a\x00\r\nb"));
try std.testing.expect(guar.crlfOkay("x/run.ps1"));
try std.testing.expect(!guar.crlfOkay("x/run.sh"));
}
test "case clashes: file and folder" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
var seen = std.StringHashMap([]const u8).init(arna.allocator());
try std.testing.expect(!try guar.collChec(arna.allocator(), &seen, "Docs/a.txt"));
try std.testing.expect(!try guar.collChec(arna.allocator(), &seen, "Docs/b.txt"));
try std.testing.expect(try guar.collChec(arna.allocator(), &seen, "docs/c.txt"));
try std.testing.expect(try guar.collChec(arna.allocator(), &seen, "Docs/A.txt"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
