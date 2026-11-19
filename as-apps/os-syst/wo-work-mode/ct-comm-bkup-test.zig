// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo bkup: list parse, state job, nightly
// Flo: mock restic + sqlite3 > run stat / nigh > check argv, resolved list file, stamps, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const bkup = @import("ct-comm-bkup.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const stat = @import("st-stat-file.zig");
const exit = @import("ct-exit-code.zig");
const STMP = "20231114-221320";
const GTOP: mock.Rule = .{ .pref = &.{ "git", "rev-parse" }, .outz = "top\n" };
const GLST: mock.Rule = .{ .pref = &.{ "git", "-C" }, .outz = "do-core-plan/\x00ac-auto-task/do-docs-deve/\x00aa-todo-note/\x00CLAUDE.md\x00ac-auto-task/CLAUDE.md\x00zig-out/\x00as-apps/ai-mind/ag-agen-code/\x00node_modules/\x00" };
fn hasCall(mck: *const mock.Mock, pref: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.startsWith(u8, line, pref)) return true; }
return false;
}
fn listMake(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir, body: []const u8) ![]u8 {
const path = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}/list.txt", .{tmp.sub_path});
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = path, .data = body });
return path;
}
test "list parse: comments and blanks skipped, joined under home, bad paths rejected" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const got = (try bkup.listParse(allo, "h", "# note\n\n.ac-auto-task/config.json\r\n  dir/sub  \n")).?;
try std.testing.expectEqual(@as(usize, 2), got.len);
try std.testing.expect(std.mem.endsWith(u8, got[0], "config.json") and std.mem.startsWith(u8, got[0], "h"));
try std.testing.expect(std.mem.indexOf(u8, got[1], "sub") != null);
try std.testing.expect((try bkup.listParse(allo, "h", "../x\n")) == null);
try std.testing.expect((try bkup.listParse(allo, "h", "a/../x\n")) == null);
try std.testing.expect((try bkup.listParse(allo, "h", "/etc/x\n")) == null);
try std.testing.expectEqual(@as(usize, 0), (try bkup.listParse(allo, "h", "# only\n")).?.len);
}
test "stat dry-run runs nothing and writes no stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var cfgv: cfgz.Conf = .{};
cfgv.bkup_list_file = try listMake(allo, &tmp, "a/b.json\n");
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"restic"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, try make.homeOf(allo, &tmp), false, false);
try std.testing.expectEqual(exit.Code.okay, try bkup.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 2), mck.call.items.len);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would back up 7 path(s)") != null);
}
test "stat live: restic argv skips dbs, resolved list under home, stamp written; windows adds VSS" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var cfgv: cfgz.Conf = .{};
cfgv.bkup_list_file = try listMake(allo, &tmp, "# state\n.ac-auto-task/config.json\n");
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"restic"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
var ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
ctxz.ostg = .linux;
try std.testing.expectEqual(exit.Code.okay, try bkup.comm(&ctxz, &.{"stat"}));
try std.testing.expectEqual(@as(usize, 3), mck.call.items.len);
const line = mck.call.items[2];
try std.testing.expect(std.mem.startsWith(u8, line, "restic backup --files-from "));
try std.testing.expect(std.mem.indexOf(u8, line, "--skip-if-unchanged --exclude *.db --exclude *.db-wal --exclude *.db-shm --tag stat") != null);
try std.testing.expect(std.mem.indexOf(u8, line, "--use-fs-snapshot") == null);
const dirz = try stat.dirzOf(allo, home, ".wo-work-mode");
const resl = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, try std.fs.path.join(allo, &.{ dirz, "bkup-files.txt" }), allo, .limited(4096));
try std.testing.expect(std.mem.startsWith(u8, resl, home) and std.mem.indexOf(u8, resl, "config.json") != null and std.mem.indexOf(u8, resl, "top") != null and std.mem.indexOf(u8, resl, "do-core-plan") != null and std.mem.indexOf(u8, resl, "CLAUDE.md") != null and std.mem.indexOf(u8, resl, "zig-out") == null and std.mem.indexOf(u8, resl, "node_modules") == null);
const stam = stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "bkup")).?;
try std.testing.expect(stam.okay and stam.when == make.NOWZ);
var mck2: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"restic"} } } };
var buf2: std.Io.Writer.Allocating = .init(allo);
var ct2 = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
ct2.ostg = .windows;
try std.testing.expectEqual(exit.Code.okay, try bkup.comm(&ct2, &.{}));
try std.testing.expect(std.mem.endsWith(u8, mck2.call.items[2], "--use-fs-snapshot"));
}
test "docs pick: prefixes, files and nested dirs, never build junk" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const got = try bkup.docsPick(allo, "top", "do-x/\x00a/do-docs-deve/\x00a/CLAUDE.md\x00zig-out/\x00node_modules/\x00\x00x/\x00", &.{ "do-", "CLAUDE.md" });
try std.testing.expectEqual(@as(usize, 3), got.len);
try std.testing.expect(std.mem.endsWith(u8, got[0], "do-x") and std.mem.indexOf(u8, got[1], "do-docs-deve") != null and std.mem.endsWith(u8, got[2], "CLAUDE.md"));
try std.testing.expectEqual(@as(usize, 0), (try bkup.docsPick(allo, "top", "", &.{"do-"})).len);
}
test "docs: git absent or not a repo blocks, empty docs list skips git" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var cfgv: cfgz.Conf = .{};
cfgv.bkup_list_file = try listMake(allo, &tmp, "a.json\n");
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "git", "rev-parse" }, .code = 128 }, .{ .pref = &.{"restic"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try bkup.comm(&ctxz, &.{}));
try std.testing.expect(!hasCall(&mck, "restic"));
cfgv.bkup_docs_list = &.{};
var mck2: mock.Mock = .{ .rule = &.{.{ .pref = &.{"restic"} }} };
var buf2: std.Io.Writer.Allocating = .init(allo);
const ct2 = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try bkup.comm(&ct2, &.{}));
try std.testing.expectEqual(@as(usize, 1), mck2.call.items.len);
}
test "stat failures: restic error and missing restic write no stamp; bad list fails before any call" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var cfgv: cfgz.Conf = .{};
cfgv.bkup_list_file = try listMake(allo, &tmp, "a.json\n");
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"restic"}, .code = 1, .errz = "no repo" } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try bkup.comm(&ctxz, &.{}));
var mck2: mock.Mock = .{ .rule = &.{} };
var buf2: std.Io.Writer.Allocating = .init(allo);
const ct2 = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try bkup.comm(&ct2, &.{}));
const dirz = try stat.dirzOf(allo, home, ".wo-work-mode");
try std.testing.expect(stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "bkup")) == null);
var bad: cfgz.Conf = .{};
bad.bkup_list_file = try listMake(allo, &tmp, "../secret\n");
var mck3: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"restic"} } } };
var buf3: std.Io.Writer.Allocating = .init(allo);
const ct3 = make.make(allo, &buf3.writer, &mck3, bad, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try bkup.comm(&ct3, &.{}));
try std.testing.expectEqual(@as(usize, 0), mck3.call.items.len);
var gone: cfgz.Conf = .{};
gone.bkup_list_file = ".zig-cache/nope/none.txt";
var mck4: mock.Mock = .{ .rule = &.{} };
var buf4: std.Io.Writer.Allocating = .init(allo);
const ct4 = make.make(allo, &buf4.writer, &mck4, gone, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try bkup.comm(&ct4, &.{}));
}
test "nigh live: VACUUM INTO and integrity check per db, then one restic backup, stamp bknt" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var cfgv: cfgz.Conf = .{};
cfgv.bkup_dbzz_list = &.{ "data/a.db", "data/b.db" };
const rul = [_]mock.Rule{ .{ .pref = &.{"sqlite3"}, .outz = "ok\n" }, .{ .pref = &.{"restic"} } };
var mck2: mock.Mock = .{ .rule = &rul };
var buf2: std.Io.Writer.Allocating = .init(allo);
const ct2 = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try bkup.comm(&ct2, &.{"nigh"}));
try std.testing.expectEqual(@as(usize, 5), mck2.call.items.len);
try std.testing.expect(std.mem.indexOf(u8, mck2.call.items[0], "a.db VACUUM INTO '") != null);
try std.testing.expect(std.mem.indexOf(u8, mck2.call.items[0], STMP) != null);
try std.testing.expect(std.mem.endsWith(u8, mck2.call.items[1], "PRAGMA integrity_check;"));
try std.testing.expect(std.mem.indexOf(u8, mck2.call.items[2], "b.db VACUUM INTO '") != null);
try std.testing.expect(std.mem.startsWith(u8, mck2.call.items[4], "restic backup --tag nigh "));
const dirz = try stat.dirzOf(allo, home, ".wo-work-mode");
const stam = stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "bknt")).?;
try std.testing.expect(stam.okay);
try std.testing.expect(stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "bkup")) == null);
}
test "nigh: empty db list blocks, dry-run runs nothing, bad integrity or vacuum error skips restic" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck0: mock.Mock = .{ .rule = &.{} };
var buf0: std.Io.Writer.Allocating = .init(allo);
const ct0 = make.make(allo, &buf0.writer, &mck0, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try bkup.comm(&ct0, &.{"nigh"}));
var cfgv: cfgz.Conf = .{};
cfgv.bkup_dbzz_list = &.{"data/a.db"};
var mck1: mock.Mock = .{ .rule = &.{.{ .pref = &.{"sqlite3"} }} };
var buf1: std.Io.Writer.Allocating = .init(allo);
const ct1 = make.make(allo, &buf1.writer, &mck1, cfgv, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try bkup.comm(&ct1, &.{"nigh"}));
try std.testing.expectEqual(@as(usize, 0), mck1.call.items.len);
var mck2: mock.Mock = .{ .rule = &.{ .{ .pref = &.{"sqlite3"}, .outz = "*** corrupt\n" }, .{ .pref = &.{"restic"} } } };
var buf2: std.Io.Writer.Allocating = .init(allo);
const ct2 = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try bkup.comm(&ct2, &.{"nigh"}));
try std.testing.expect(!hasCall(&mck2, "restic"));
var mck3: mock.Mock = .{ .rule = &.{ .{ .pref = &.{"sqlite3"}, .code = 1, .errz = "locked" }, .{ .pref = &.{"restic"} } } };
var buf3: std.Io.Writer.Allocating = .init(allo);
const ct3 = make.make(allo, &buf3.writer, &mck3, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try bkup.comm(&ct3, &.{"nigh"}));
try std.testing.expect(!hasCall(&mck3, "restic"));
const dirz = try stat.dirzOf(allo, home, ".wo-work-mode");
try std.testing.expect(stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "bknt")) == null);
}
test "unknown or extra argument is a usage error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", false, false);
try std.testing.expectError(exit.Erro.Usag, bkup.comm(&ctxz, &.{"weekly"}));
try std.testing.expectError(exit.Erro.Usag, bkup.comm(&ctxz, &.{ "stat", "x" }));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
