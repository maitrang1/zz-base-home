// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for path normalizing, case rules and path pieces
// Flo: normalize on windows/unix/mac rules > compare > find > dir/base/root > inside check
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const WIN: osys.Osys = .{ .wind = true, .caze = true };
const NIX: osys.Osys = .{ .wind = false, .caze = false };
const MAC: osys.Osys = .{ .wind = false, .caze = true };
fn norm(osy: osys.Osys, path: []const u8, want: []const u8) !void {
const got = try osys.normPath(std.testing.allocator, osy, path);
defer std.testing.allocator.free(got);
try std.testing.expectEqualStrings(want, got);
}
test "windows paths normalize to forward slashes with an upper drive" {
try norm(WIN, "E:\\a\\b\\", "E:/a/b");
try norm(WIN, "e:\\a\\.\\b\\..\\c", "E:/a/c");
try norm(WIN, "E:\\", "E:/");
try norm(WIN, "E:", "E:/");
try norm(WIN, "E:/a//b", "E:/a/b");
try norm(WIN, "E:\\..\\..\\a", "E:/a");
}
test "windows UNC keeps the leading double slash" {
try norm(WIN, "\\\\srv\\sh\\x", "//srv/sh/x");
try norm(WIN, "//srv/sh/./x/", "//srv/sh/x");
}
test "unix paths keep backslashes as name chars" {
try norm(NIX, "/a//b/../c/", "/a/c");
try norm(NIX, "/", "/");
try norm(NIX, "/..", "/");
try norm(NIX, "/a\\b", "/a\\b");
try norm(MAC, "/Users/x/./y", "/Users/x/y");
}
test "relative or drive-relative input is refused" {
try std.testing.expectError(osys.Erro.NotAbsolute, osys.normPath(std.testing.allocator, WIN, "a\\b"));
try std.testing.expectError(osys.Erro.NotAbsolute, osys.normPath(std.testing.allocator, WIN, "C:foo"));
try std.testing.expectError(osys.Erro.NotAbsolute, osys.normPath(std.testing.allocator, NIX, "a/b"));
try std.testing.expectError(osys.Erro.NotAbsolute, osys.normPath(std.testing.allocator, NIX, "C:/x"));
try std.testing.expectError(osys.Erro.NotAbsolute, osys.normPath(std.testing.allocator, NIX, ""));
}
test "isAbso follows the OS style" {
try std.testing.expect(osys.isAbso(WIN, "C:\\x") and osys.isAbso(WIN, "C:/x") and osys.isAbso(WIN, "C:") and osys.isAbso(WIN, "/x"));
try std.testing.expect(!osys.isAbso(WIN, "C:x") and !osys.isAbso(WIN, "x\\y"));
try std.testing.expect(osys.isAbso(NIX, "/x") and !osys.isAbso(NIX, "C:/x") and !osys.isAbso(NIX, "x"));
}
test "native form flips slashes only on windows" {
const wnat = try osys.natiForm(std.testing.allocator, WIN, "E:/a/b");
defer std.testing.allocator.free(wnat);
try std.testing.expectEqualStrings("E:\\a\\b", wnat);
const unat = try osys.natiForm(std.testing.allocator, NIX, "/a/b");
defer std.testing.allocator.free(unat);
try std.testing.expectEqualStrings("/a/b", unat);
}
test "eqlz honors the case rule and the length" {
try std.testing.expect(osys.eqlz(WIN, "AbC", "aBc") and osys.eqlz(MAC, "AbC", "aBc"));
try std.testing.expect(!osys.eqlz(NIX, "AbC", "aBc"));
try std.testing.expect(!osys.eqlz(WIN, "abc", "abcd") and osys.eqlz(NIX, "", ""));
}
test "findz finds from an offset, both case rules" {
try std.testing.expectEqual(@as(?usize, 2), osys.findz(NIX, "xxabxxab", "ab", 0));
try std.testing.expectEqual(@as(?usize, 6), osys.findz(NIX, "xxabxxab", "ab", 3));
try std.testing.expectEqual(@as(?usize, null), osys.findz(NIX, "xxAB", "ab", 0));
try std.testing.expectEqual(@as(?usize, 2), osys.findz(WIN, "xxAB", "ab", 0));
try std.testing.expectEqual(@as(?usize, 6), osys.findz(WIN, "xxabxxAb", "aB", 3));
}
test "findz edge cases: empty, too long, from past the end, match at the very end" {
try std.testing.expectEqual(@as(?usize, null), osys.findz(NIX, "abc", "", 0));
try std.testing.expectEqual(@as(?usize, null), osys.findz(NIX, "ab", "abc", 0));
try std.testing.expectEqual(@as(?usize, null), osys.findz(NIX, "abc", "c", 3));
try std.testing.expectEqual(@as(?usize, 2), osys.findz(NIX, "abc", "c", 2));
try std.testing.expectEqual(@as(?usize, 2), osys.findz(WIN, "abC", "c", 2));
try std.testing.expectEqual(@as(?usize, null), osys.findz(WIN, "", "c", 0));
}
test "hasPre and hasSuf" {
try std.testing.expect(osys.hasPre(WIN, "C:/Users/x", "c:/users") and !osys.hasPre(NIX, "C:/Users/x", "c:/users"));
try std.testing.expect(osys.hasSuf(WIN, "a/.GIT/objects", ".git/OBJECTS") and !osys.hasSuf(NIX, "a/.GIT/objects", ".git/OBJECTS"));
try std.testing.expect(!osys.hasPre(NIX, "ab", "abc") and !osys.hasSuf(NIX, "ab", "abc") and osys.hasPre(NIX, "ab", ""));
}
test "dirOf baseOf rootOf" {
try std.testing.expectEqualStrings("E:/a", osys.dirOf("E:/a/b"));
try std.testing.expectEqualStrings("E:/", osys.dirOf("E:/a"));
try std.testing.expectEqualStrings("/", osys.dirOf("/a"));
try std.testing.expectEqualStrings("/a", osys.dirOf("/a/b"));
try std.testing.expectEqualStrings("b", osys.baseOf("E:/a/b"));
try std.testing.expectEqualStrings("a", osys.baseOf("/a"));
try std.testing.expectEqualStrings("E:/", osys.rootOf("E:/a/b"));
try std.testing.expectEqualStrings("/", osys.rootOf("/a/b"));
try std.testing.expectEqualStrings("//", osys.rootOf("//srv/sh"));
}
test "insid: same path or a real child, never a name prefix" {
try std.testing.expect(osys.insid(NIX, "/a/b", "/a/b"));
try std.testing.expect(osys.insid(NIX, "/a/b/c", "/a/b"));
try std.testing.expect(!osys.insid(NIX, "/a/bc", "/a/b"));
try std.testing.expect(!osys.insid(NIX, "/a", "/a/b"));
try std.testing.expect(osys.insid(NIX, "/a", "/"));
try std.testing.expect(osys.insid(WIN, "E:/A/B/c", "e:/a/b"));
try std.testing.expect(!osys.insid(NIX, "/A/B/c", "/a/b"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
