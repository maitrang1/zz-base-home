// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for absolute and relative path forms
// Flo: abs forms on windows/unix > relative forms by depth > different roots > edge dirs
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const WIN: osys.Osys = .{ .wind = true, .caze = true };
const NIX: osys.Osys = .{ .wind = false, .caze = false };
fn want(list: []const vari.Vari, idx: usize, kind: vari.Kind, text: []const u8) !void {
try std.testing.expect(idx < list.len);
try std.testing.expectEqual(kind, list[idx].kind);
try std.testing.expectEqualStrings(text, list[idx].text);
}
test "windows abs forms: url, double, native, forward, in that order" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const list = try vari.absVari(arna.allocator(), WIN, "E:/my proj/old");
try std.testing.expectEqual(@as(usize, 4), list.len);
try want(list, 0, .urlz, "file:///E:/my%20proj/old");
try want(list, 1, .dbls, "E:\\\\my proj\\\\old");
try want(list, 2, .nati, "E:\\my proj\\old");
try want(list, 3, .fwds, "E:/my proj/old");
}
test "unix abs forms: url and forward only" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const list = try vari.absVari(arna.allocator(), NIX, "/home/u/old dir");
try std.testing.expectEqual(@as(usize, 2), list.len);
try want(list, 0, .urlz, "file:///home/u/old%20dir");
try want(list, 1, .fwds, "/home/u/old dir");
}
test "old and new abs forms have the same shape" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const olds = try vari.absVari(arna.allocator(), WIN, "E:/p/old");
const news = try vari.absVari(arna.allocator(), WIN, "E:/p/newer name");
try std.testing.expectEqual(olds.len, news.len);
for (olds, news) |left, righ| try std.testing.expectEqual(left.kind, righ.kind);
}
test "relative from a sibling dir climbs one level" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const list = try vari.relaVari(arna.allocator(), NIX, "/p/doc", "/p/old");
try std.testing.expectEqual(@as(usize, 1), list.len);
try want(list, 0, .rela, "../old");
}
test "relative on windows adds the backslash form" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const list = try vari.relaVari(arna.allocator(), WIN, "E:/p/doc/deep", "E:/p/old/sub");
try std.testing.expectEqual(@as(usize, 2), list.len);
try want(list, 0, .rela, "../../old/sub");
try want(list, 1, .rela, "..\\..\\old\\sub");
}
test "from the parent dir a lone name is bare, a longer path is not" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const lone = try vari.relaVari(arna.allocator(), NIX, "/p", "/p/old");
try std.testing.expectEqual(@as(usize, 2), lone.len);
try want(lone, 0, .rela, "./old");
try want(lone, 1, .bare, "old");
const deep = try vari.relaVari(arna.allocator(), NIX, "/p", "/p/a/old");
try std.testing.expectEqual(@as(usize, 2), deep.len);
try want(deep, 0, .rela, "./a/old");
try want(deep, 1, .rela, "a/old");
const wlone = try vari.relaVari(arna.allocator(), WIN, "E:/p", "E:/p/old");
try std.testing.expectEqual(@as(usize, 3), wlone.len);
try want(wlone, 1, .rela, ".\\old");
try want(wlone, 2, .bare, "old");
const wdeep = try vari.relaVari(arna.allocator(), WIN, "E:/p", "E:/p/a/old");
try std.testing.expectEqual(@as(usize, 4), wdeep.len);
try want(wdeep, 3, .rela, "a\\old");
}
test "different roots give nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectEqual(@as(usize, 0), (try vari.relaVari(arna.allocator(), WIN, "D:/p", "E:/p/old")).len);
try std.testing.expectEqual(@as(usize, 0), (try vari.relaVari(arna.allocator(), NIX, "//srv/p", "/p/old")).len);
}
test "target equal to the dir, or an ancestor of it, gives nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectEqual(@as(usize, 0), (try vari.relaVari(arna.allocator(), NIX, "/p/old", "/p/old")).len);
try std.testing.expectEqual(@as(usize, 0), (try vari.relaVari(arna.allocator(), NIX, "/p/old/sub", "/p/old")).len);
}
test "windows compares components without case" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const list = try vari.relaVari(arna.allocator(), WIN, "E:/P/Doc", "e:/p/old");
try want(list, 0, .rela, "../old");
const unix = try vari.relaVari(arna.allocator(), NIX, "/P/Doc", "/p/old");
try want(unix, 0, .rela, "../../p/old");
}
test "old and new relative forms have the same shape" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const olds = try vari.relaVari(arna.allocator(), WIN, "E:/p", "E:/p/old");
const news = try vari.relaVari(arna.allocator(), WIN, "E:/p", "E:/p/brand");
try std.testing.expectEqual(olds.len, news.len);
for (olds, news) |left, righ| try std.testing.expectEqual(left.kind, righ.kind);
}
test "utf16 forms: windows gives native + forward, unix gives forward only, bytes are LE" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const wl = try vari.absVari(allo, WIN, "E:/p/old");
const wide = try vari.u16Vari(allo, wl);
try std.testing.expectEqual(@as(usize, 2), wide.len);
try std.testing.expectEqual(vari.Kind.u16l, wide[0].kind);
try std.testing.expectEqualSlices(u8, "E\x00:\x00\\\x00p\x00\\\x00o\x00l\x00d\x00", wide[0].text);
try std.testing.expectEqualSlices(u8, "E\x00:\x00/\x00p\x00/\x00o\x00l\x00d\x00", wide[1].text);
const ul = try vari.absVari(allo, NIX, "/p/old");
const uw = try vari.u16Vari(allo, ul);
try std.testing.expectEqual(@as(usize, 1), uw.len);
try std.testing.expectEqualSlices(u8, "/\x00p\x00/\x00o\x00l\x00d\x00", uw[0].text);
}
test "utf16 forms of old and new keep the same order" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const olds = try vari.u16Vari(allo, try vari.absVari(allo, WIN, "E:/p/old"));
const news = try vari.u16Vari(allo, try vari.absVari(allo, WIN, "E:/p/new"));
try std.testing.expectEqual(olds.len, news.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
