// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for finding path refs inside one text
// Flo: each form found > boundaries > overlaps > lines > case rules > bad shape
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const stex = @import("se-scan-text.zig");
const WIN: osys.Osys = .{ .wind = true, .caze = true };
const NIX: osys.Osys = .{ .wind = false, .caze = false };
fn scan(arna: std.mem.Allocator, osy: osys.Osys, text: []const u8, old: []const u8, new: []const u8) ![]stex.Hit {
const olds = try vari.absVari(arna, osy, old);
const news = try vari.absVari(arna, osy, new);
return stex.scanText(arna, osy, text, olds, news);
}
test "finds the plain unix path and gives the new text" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "run /home/u/old/x.sh now", "/home/u/old", "/home/u/new");
try std.testing.expectEqual(@as(usize, 1), hits.len);
try std.testing.expectEqual(@as(usize, 4), hits[0].offz);
try std.testing.expectEqual(@as(usize, 11), hits[0].lenz);
try std.testing.expectEqual(vari.Kind.fwds, hits[0].kind);
try std.testing.expectEqualStrings("/home/u/new", hits[0].newz);
try std.testing.expectEqual(@as(u32, 1), hits[0].line);
}
test "finds all four windows forms" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const text = "a E:\\p\\old\nb E:/p/old\nc E:\\\\p\\\\old\nd file:///E:/p/old\n";
const hits = try scan(arna.allocator(), WIN, text, "E:/p/old", "E:/p/new");
try std.testing.expectEqual(@as(usize, 4), hits.len);
try std.testing.expectEqual(vari.Kind.nati, hits[0].kind);
try std.testing.expectEqual(vari.Kind.fwds, hits[1].kind);
try std.testing.expectEqual(vari.Kind.dbls, hits[2].kind);
try std.testing.expectEqual(vari.Kind.urlz, hits[3].kind);
try std.testing.expectEqualStrings("E:\\p\\new", hits[0].newz);
try std.testing.expectEqualStrings("E:\\\\p\\\\new", hits[2].newz);
try std.testing.expectEqualStrings("file:///E:/p/new", hits[3].newz);
}
test "line numbers count from 1 and follow the newlines" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "/a/old\n\n/a/old\nx /a/old", "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 3), hits.len);
try std.testing.expectEqual(@as(u32, 1), hits[0].line);
try std.testing.expectEqual(@as(u32, 3), hits[1].line);
try std.testing.expectEqual(@as(u32, 4), hits[2].line);
}
test "the url form wins over the forward form inside it (no double hit)" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "u file:///a/old end", "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 1), hits.len);
try std.testing.expectEqual(vari.Kind.urlz, hits[0].kind);
try std.testing.expectEqual(@as(usize, 2), hits[0].offz);
}
test "name-like neighbors are not hits: old2, old.txt, xold, subdir of other root" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const text = "/a/old2 /a/old.txt /a/old_x /a/old-x x/a/old https://h/a/old";
const hits = try scan(arna.allocator(), NIX, text, "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 0), hits.len);
}
test "a child path is a hit and only the prefix is replaced" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "/a/old/sub/f.txt", "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 1), hits.len);
try std.testing.expectEqual(@as(usize, 6), hits[0].lenz);
}
test "a sentence dot after the path is still a hit" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "See /a/old. Then /a/old, ok.", "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 2), hits.len);
}
test "hits at the very start and the very end of the text" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "/a/old mid /a/old", "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 2), hits.len);
try std.testing.expectEqual(@as(usize, 0), hits[0].offz);
try std.testing.expectEqual(@as(usize, 11), hits[1].offz);
}
test "case rule: windows matches any case, unix does not" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const text = "e:\\P\\OLD";
try std.testing.expectEqual(@as(usize, 1), (try scan(arna.allocator(), WIN, text, "E:/p/old", "E:/p/new")).len);
try std.testing.expectEqual(@as(usize, 0), (try scan(arna.allocator(), NIX, "/P/OLD", "/p/old", "/p/new")).len);
}
test "relative forms from a file dir are found; the bare name is flagged as bare" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const olds = try vari.relaVari(allo, NIX, "/p", "/p/old");
const news = try vari.relaVari(allo, NIX, "/p", "/p/new");
const hits = try stex.scanText(allo, NIX, "a ./old b old c ./old/x", olds, news);
try std.testing.expectEqual(@as(usize, 3), hits.len);
try std.testing.expectEqual(vari.Kind.rela, hits[0].kind);
try std.testing.expectEqual(vari.Kind.bare, hits[1].kind);
try std.testing.expectEqual(vari.Kind.rela, hits[2].kind);
try std.testing.expectEqualStrings("./new", hits[0].newz);
try std.testing.expectEqualStrings("new", hits[1].newz);
}
test "a bare name inside a longer path is not a hit" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const olds = try vari.relaVari(allo, NIX, "/p", "/p/old");
const news = try vari.relaVari(allo, NIX, "/p", "/p/new");
const hits = try stex.scanText(allo, NIX, "x/old /other/old ../old", olds, news);
try std.testing.expectEqual(@as(usize, 0), hits.len);
}
test "empty text and shape mismatch" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
try std.testing.expectEqual(@as(usize, 0), (try scan(allo, NIX, "", "/a/old", "/a/new")).len);
const olds = try vari.absVari(allo, NIX, "/a/old");
try std.testing.expectError(stex.Erro.ShapeMismatch, stex.scanText(allo, NIX, "x", olds, olds[0..1]));
}
test "overlapping forms keep only the longest, once" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const olds = [_]vari.Vari{ .{ .kind = .fwds, .text = "/a/old" }, .{ .kind = .rela, .text = "/a/old/x" } };
const news = [_]vari.Vari{ .{ .kind = .fwds, .text = "/a/new" }, .{ .kind = .rela, .text = "/a/new/x" } };
const hits = try stex.scanText(arna.allocator(), NIX, "go /a/old/x end", &olds, &news);
try std.testing.expectEqual(@as(usize, 1), hits.len);
try std.testing.expectEqual(@as(usize, 8), hits[0].lenz);
try std.testing.expectEqual(vari.Kind.rela, hits[0].kind);
}
test "two refs touching in one line are both found" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const hits = try scan(arna.allocator(), NIX, "/a/old:/a/old", "/a/old", "/a/new");
try std.testing.expectEqual(@as(usize, 2), hits.len);
try std.testing.expectEqual(@as(usize, 7), hits[1].offz);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
