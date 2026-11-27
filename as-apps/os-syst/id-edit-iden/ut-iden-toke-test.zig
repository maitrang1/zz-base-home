// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for id rules and whole-token replace
// Flo: id edge cases > token boundaries > multi-pair single pass > roundtrip
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const tk = @import("ut-iden-toke.zig");
const A = std.testing.allocator;
fn patch(text: []const u8, pairs: []const tk.Pair) ![]u8 {
const hits = try tk.scan(A, text, pairs);
defer A.free(hits);
return tk.apply(A, text, hits, pairs);
}
test "idenBadz: empty, 120, 121, bad chars, ok forms" {
try std.testing.expectEqualStrings("empty id", tk.idenBadz("").?);
try std.testing.expect(tk.idenBadz(&@as([120]u8, @splat('a'))) == null);
try std.testing.expect(tk.idenBadz(&@as([121]u8, @splat('a'))) != null);
for ([_][]const u8{ "a b", "a/b", "a\\b", "a.b", "a:b", "a*b", "é", "a\n", "a\"b", "a|b" }) |bad| try std.testing.expect(tk.idenBadz(bad) != null);
for ([_][]const u8{ "cicd-stat", "puls-15mi", "A_b-9", "x", "1-times-a-day-am-oo" }) |good| try std.testing.expect(tk.idenBadz(good) == null);
}
test "whole token only: longer neighbors never match" {
const pairs = [_]tk.Pair{.{ .old = "cicd-stat", .new = "ci-st" }};
const outz = try patch("cicd-stat2 xcicd-stat cicd-stat-b cicd_stat cicd-stat", &pairs);
defer A.free(outz);
try std.testing.expectEqualStrings("cicd-stat2 xcicd-stat cicd-stat-b cicd_stat ci-st", outz);
}
test "boundaries: quotes, dots, slashes, brackets, line ends, start and end of text" {
const pairs = [_]tk.Pair{.{ .old = "ab-cd", .new = "ef-gh" }};
const outz = try patch("ab-cd\n\"ab-cd\" ab-cd.log C:\\x\\ab-cd\\y [ab-cd] (ab-cd), ab-cd", &pairs);
defer A.free(outz);
try std.testing.expectEqualStrings("ef-gh\n\"ef-gh\" ef-gh.log C:\\x\\ef-gh\\y [ef-gh] (ef-gh), ef-gh", outz);
}
test "multi pair in one pass: swap works, no double replace" {
const pairs = [_]tk.Pair{ .{ .old = "aaa", .new = "bbb" }, .{ .old = "bbb", .new = "aaa" } };
const outz = try patch("aaa bbb aaa", &pairs);
defer A.free(outz);
try std.testing.expectEqualStrings("bbb aaa bbb", outz);
}
test "no hit returns an equal copy, empty text is fine" {
const pairs = [_]tk.Pair{.{ .old = "x1", .new = "y1" }};
const outz = try patch("nothing here", &pairs);
defer A.free(outz);
try std.testing.expectEqualStrings("nothing here", outz);
const empt = try patch("", &pairs);
defer A.free(empt);
try std.testing.expectEqual(@as(usize, 0), empt.len);
}
test "hit offsets and line numbers are exact" {
const pairs = [_]tk.Pair{.{ .old = "id-a", .new = "id-b" }};
const text = "one\ntwo id-a\n\nid-a end";
const hits = try tk.scan(A, text, &pairs);
defer A.free(hits);
try std.testing.expectEqual(@as(usize, 2), hits.len);
try std.testing.expectEqual(@as(usize, 8), hits[0].offz);
try std.testing.expectEqual(@as(usize, 2), hits[0].line);
try std.testing.expectEqual(@as(usize, 4), hits[1].line);
try std.testing.expectEqualStrings("id-a", text[hits[1].offz..][0..hits[1].lenz]);
}
test "replacement of different length keeps the rest byte-exact" {
const pairs = [_]tk.Pair{.{ .old = "s", .new = "much-longer-id" }};
const outz = try patch("{\"ids\":[\"s\",\"t\"]}", &pairs);
defer A.free(outz);
try std.testing.expectEqualStrings("{\"ids\":[\"much-longer-id\",\"t\"]}", outz);
}
test "utf8 neighbors are boundaries, never part of a token" {
const pairs = [_]tk.Pair{.{ .old = "ab", .new = "cd" }};
const outz = try patch("é ab é, ab—ab", &pairs);
defer A.free(outz);
try std.testing.expectEqualStrings("é cd é, cd—cd", outz);
}
test "roundtrip: apply then reverse pairs gives the original" {
const fwd = [_]tk.Pair{ .{ .old = "q-one", .new = "z-1" }, .{ .old = "q-two", .new = "z-2" } };
const bak = [_]tk.Pair{ .{ .old = "z-1", .new = "q-one" }, .{ .old = "z-2", .new = "q-two" } };
const text = "[\"q-one\",\"q-two\"] q-one";
const mid = try patch(text, &fwd);
defer A.free(mid);
const back = try patch(mid, &bak);
defer A.free(back);
try std.testing.expectEqualStrings(text, back);
}
test "hasTok finds exact tokens only" {
try std.testing.expect(tk.hasTok("if \"%~1\"==\"cicd-stat\" call", "cicd-stat"));
try std.testing.expect(!tk.hasTok("cicd-stat2", "cicd-stat"));
try std.testing.expect(!tk.hasTok("", "a"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
