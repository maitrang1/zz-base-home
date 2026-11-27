// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for map parsing and checks
// Flo: three separators > comments > each bad shape gives its issue
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const mp = @import("pl-plan-maps.zig");
const tk = @import("ut-iden-toke.zig");
const A = std.testing.allocator;
test "file text: =, ->, spaces, comments, blanks, CRLF" {
var list: std.ArrayList(tk.Pair) = .empty;
defer list.deinit(A);
try mp.fromText(A, "# note\n\na-b=c-d\r\ne-f -> g-h\n  i-j   k-l  \n", &list);
try std.testing.expectEqual(@as(usize, 3), list.items.len);
try std.testing.expectEqualStrings("a-b", list.items[0].old);
try std.testing.expectEqualStrings("c-d", list.items[0].new);
try std.testing.expectEqualStrings("g-h", list.items[1].new);
try std.testing.expectEqualStrings("k-l", list.items[2].new);
}
test "a line with 1 or 3 words is BadLine" {
var list: std.ArrayList(tk.Pair) = .empty;
defer list.deinit(A);
try std.testing.expectError(mp.Erro.BadLine, mp.fromText(A, "lonely\n", &list));
try std.testing.expectError(mp.Erro.BadLine, mp.fromText(A, "a b c\n", &list));
}
test "args parse the same way" {
var list: std.ArrayList(tk.Pair) = .empty;
defer list.deinit(A);
try mp.fromArgs(A, &.{ "x1=y1", "x2=y2" }, &list);
try std.testing.expectEqual(@as(usize, 2), list.items.len);
try std.testing.expectError(mp.Erro.BadLine, mp.fromArgs(A, &.{"nopair"}, &list));
}
test "check: every bad shape names its issue" {
try std.testing.expectEqualStrings("no pairs", mp.check(&.{}).?.why);
try std.testing.expectEqualStrings("old equals new", mp.check(&.{.{ .old = "a", .new = "a" }}).?.why);
try std.testing.expectEqualStrings("old id listed twice", mp.check(&.{ .{ .old = "a", .new = "b" }, .{ .old = "a", .new = "c" } }).?.why);
try std.testing.expectEqualStrings("two ids renamed to the same new id", mp.check(&.{ .{ .old = "a", .new = "c" }, .{ .old = "b", .new = "c" } }).?.why);
try std.testing.expect(std.mem.startsWith(u8, mp.check(&.{ .{ .old = "a", .new = "b" }, .{ .old = "b", .new = "c" } }).?.why, "new id is also an old id"));
try std.testing.expect(std.mem.startsWith(u8, mp.check(&.{ .{ .old = "a", .new = "b" }, .{ .old = "b", .new = "a" } }).?.why, "new id is also an old id"));
try std.testing.expectEqualStrings("a/b", mp.check(&.{.{ .old = "a/b", .new = "c" }}).?.iden);
try std.testing.expectEqualStrings("id may hold only letters, digits, - and _", mp.check(&.{.{ .old = "ok", .new = "bad id" }}).?.why);
}
test "a clean map passes" {
try std.testing.expect(mp.check(&.{ .{ .old = "cicd-stat", .new = "ci-stat" }, .{ .old = "home-doct", .new = "ho-doct" } }) == null);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
