// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the repo walker
// Flo: hits per file > skipped dirs, names, exts > clash > binary, big, UTF-16 > docs switch
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const wk = @import("se-scan-walk.zig");
const cfgz = @import("cf-conf-load.zig");
const tk = @import("ut-iden-toke.zig");
const fk = @import("te-fake-repo.zig");
const PAIR = [_]tk.Pair{.{ .old = "cicd-stat", .new = "ci-stat" }};
fn hitOf(outc: *const wk.Outc, tail: []const u8) ?wk.Fhit { for (outc.files.items) |item| if (std.mem.endsWith(u8, item.path, tail)) return item; return null; }
test "fake repo: live + docs hits, skipped dirs and names stay out" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
var outc: wk.Outc = .{};
try wk.walk(allo, std.testing.allocator, std.testing.io, .{}, fake.repo, &PAIR, &outc);
try std.testing.expectEqual(@as(usize, 5), outc.files.items.len);
try std.testing.expectEqual(@as(usize, 1), hitOf(&outc, "aa-auto-task-wi01.json").?.hits);
try std.testing.expectEqual(wk.Kind.live, hitOf(&outc, "ba-cmds-wind.bat").?.kind);
try std.testing.expectEqual(wk.Kind.docs, hitOf(&outc, "no-note-docs.txt").?.kind);
try std.testing.expectEqual(@as(usize, 2), hitOf(&outc, "no-note-docs.txt").?.hits);
try std.testing.expect(hitOf(&outc, "UPDATE.md") == null);
try std.testing.expect(hitOf(&outc, "old.txt") == null);
try std.testing.expectEqual(@as(usize, 0), outc.clash.items.len);
}
test "docs off: only live kinds are scanned" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
var conf: cfgz.Conf = .{};
conf.scan_docs_on = false;
var outc: wk.Outc = .{};
try wk.walk(allo, std.testing.allocator, std.testing.io, conf, fake.repo, &PAIR, &outc);
try std.testing.expectEqual(@as(usize, 4), outc.files.items.len);
try std.testing.expect(hitOf(&outc, "no-note-docs.txt") == null);
}
test "clash: a file or folder named like the old id" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
try fk.put(allo, std.testing.io, fake.repo, "x/cicd-stat.txt", "hello");
try fk.put(allo, std.testing.io, fake.repo, "cicd-stat/in.txt", "hello");
var outc: wk.Outc = .{};
try wk.walk(allo, std.testing.allocator, std.testing.io, .{}, fake.repo, &PAIR, &outc);
try std.testing.expectEqual(@as(usize, 2), outc.clash.items.len);
}
test "binary, oversize and wrong-ext files are skipped; UTF-16 is read" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
try fk.put(allo, std.testing.io, fake.repo, "b/bin.json", "cicd-stat\x00\x00");
try fk.put(allo, std.testing.io, fake.repo, "b/pic.png", "cicd-stat");
try fk.put(allo, std.testing.io, fake.repo, "b/big.txt", "cicd-stat xxxxxxxx");
const wide = [_]u8{ 0xFF, 0xFE, 'c', 0, 'i', 0, 'c', 0, 'd', 0, '-', 0, 's', 0, 't', 0, 'a', 0, 't', 0 };
try fk.put(allo, std.testing.io, fake.repo, "b/wide.bat", &wide);
var conf: cfgz.Conf = .{};
conf.scan_maxz_mbyt = 0;
var outc: wk.Outc = .{};
try wk.walk(allo, std.testing.allocator, std.testing.io, conf, fake.repo, &PAIR, &outc);
try std.testing.expectEqual(@as(usize, 0), outc.files.items.len);
try std.testing.expect(outc.wst.bigz > 0);
var out2: wk.Outc = .{};
try wk.walk(allo, std.testing.allocator, std.testing.io, .{}, fake.repo, &PAIR, &out2);
try std.testing.expect(hitOf(&out2, "bin.json") == null);
try std.testing.expect(hitOf(&out2, "pic.png") == null);
try std.testing.expect(hitOf(&out2, "wide.bat") != null);
try std.testing.expect(out2.wst.bina >= 1);
}
test "kindOf: case-insensitive ext, no ext, docs switch" {
const conf: cfgz.Conf = .{};
try std.testing.expectEqual(wk.Kind.live, wk.kindOf(conf, "A.JSON").?);
try std.testing.expect(wk.kindOf(conf, "Makefile") == null);
try std.testing.expectEqual(wk.Kind.docs, wk.kindOf(conf, "a.TXT").?);
var off: cfgz.Conf = .{};
off.scan_docs_on = false;
try std.testing.expect(wk.kindOf(off, "a.txt") == null);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
