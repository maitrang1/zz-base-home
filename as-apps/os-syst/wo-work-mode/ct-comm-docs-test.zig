// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo docs: url derive, init, sync, leak stop, rebase conflict
// Flo: mock git + gitleaks > run init / sync > check argv, env, stamp, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const docs = @import("ct-comm-docs.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
const GTOP: mock.Rule = .{ .pref = &.{ "git", "rev-parse" }, .outz = "top\n" };
const GLST: mock.Rule = .{ .pref = &.{ "git", "-C" }, .outz = "do-core-plan/\x00ac-auto-task/do-docs-deve/\x00aa-todo-note/\x00CLAUDE.md\x00ac-auto-task/CLAUDE.md\x00zig-out/\x00as-apps/ai-mind/ag-agen-code/\x00node_modules/\x00" };
fn hasCall(mck: *const mock.Mock, part: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
}
fn gitdMake(allo: std.mem.Allocator, home: []const u8) !void {
const dirz = try std.fs.path.join(allo, &.{ home, ".zz-base-home-docs.git" });
try std.Io.Dir.cwd().createDirPath(std.testing.io, dirz);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = try std.fs.path.join(allo, &.{ dirz, "HEAD" }), .data = "ref: refs/heads/main\n" });
}
test "urlMake derives the docs repo url, keeps ssh and https shapes, refuses unknown names" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
try std.testing.expectEqualStrings("https://github.com/u/zz-base-home-docs.git", (try docs.urlMake(allo, "https://github.com/u/zz-base-home.git")).?);
try std.testing.expectEqualStrings("git@gitlab.com:u/zz-base-home-docs.git", (try docs.urlMake(allo, "git@gitlab.com:u/zz-base-home.git")).?);
try std.testing.expectEqualStrings("git@gitlab.com:u/zz-base-home-docs.git", (try docs.urlMake(allo, "git@gitlab.com:u/zz-base-home-docs.git")).?);
try std.testing.expect((try docs.urlMake(allo, "git@gitlab.com:u/other.git")) == null);
}
test "usage: one of init or sync, nothing else" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", false, false);
try std.testing.expectError(exit.Erro.Usag, docs.comm(&ctxz, &.{}));
try std.testing.expectError(exit.Erro.Usag, docs.comm(&ctxz, &.{"nope"}));
try std.testing.expectError(exit.Erro.Usag, docs.comm(&ctxz, &.{ "sync", "x" }));
}
test "sync without the docs git dir is blocked and runs nothing but rev-parse" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{ .rule = &.{ GTOP, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, try make.homeOf(allo, &tmp), true, false);
try std.testing.expectEqual(exit.Code.bloc, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expectEqual(@as(usize, 1), mck.call.items.len);
}
test "sync dry-run counts the doc paths and changes nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would scan and commit 6 doc path(s)") != null);
try std.testing.expect(!hasCall(&mck, "git add") and !hasCall(&mck, "gitleaks"));
try std.testing.expect(ctxz.stamGet("docs") == null);
}
test "sync live: scan, add, commit unsigned, fetch, rebase on each remote, push both, stamp, git dir via env" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{ "git", "diff" }, .code = 1 }, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.docs_remo_list = &.{ "origin", "mirr" };
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "gitleaks dir --redact --no-banner --exit-code 9 top") and hasCall(&mck, "do-core-plan"));
try std.testing.expect(hasCall(&mck, "git add -f -A -- top"));
try std.testing.expect(hasCall(&mck, "git -c commit.gpgsign=false commit -q -m docs devb"));
try std.testing.expect(hasCall(&mck, "git rebase -q refs/remotes/origin/main") and hasCall(&mck, "git rebase -q refs/remotes/mirr/main"));
try std.testing.expect(hasCall(&mck, "git push -q origin HEAD:refs/heads/main") and hasCall(&mck, "git push -q mirr HEAD:refs/heads/main"));
var envd = false;
for (mck.envz.items) |line| { if (std.mem.startsWith(u8, line, "GIT_DIR=") and std.mem.indexOf(u8, line, ".zz-base-home-docs.git") != null) envd = true; }
try std.testing.expect(envd);
try std.testing.expect(ctxz.stamGet("docs").?.okay);
}
test "sync with nothing staged skips the commit but still pushes" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(!hasCall(&mck, "commit") and hasCall(&mck, "git push -q origin"));
}
test "a leak stops the sync before anything is staged" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"}, .code = 9 } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(!hasCall(&mck, "git add") and !hasCall(&mck, "git push"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "LEAK in do-core-plan") != null);
try std.testing.expect(ctxz.stamGet("docs") == null);
}
test "gitleaks absent blocks the sync" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(!hasCall(&mck, "git add"));
}
test "a rebase conflict aborts the rebase, pushes nothing, writes no stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ GTOP, GLST, .{ .pref = &.{ "git", "rebase", "-q" }, .code = 1, .errz = "conflict" }, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git rebase --abort") and !hasCall(&mck, "git push"));
try std.testing.expect(ctxz.stamGet("docs") == null);
}
test "init dry-run changes nothing; live creates the git dir, exclude-all, remotes from the main repo; empty remote skips restore" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{ GTOP, .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = &.{ "git", "--git-dir" }, .code = 0 }, .{ .pref = &.{ "git", "config", "--get" }, .outz = "val\n" }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const dry = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&dry, &.{"init"}));
try std.testing.expect(!hasCall(&mck, "git init"));
var mck2: mock.Mock = .{ .rule = &.{ GTOP, .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = &.{ "git", "--git-dir", "x" } }, .{ .pref = &.{ "git", "config", "--get" }, .outz = "val\n" }, .{ .pref = &.{"git"} } } };
var buf2: std.Io.Writer.Allocating = .init(allo);
const live = make.make(allo, &buf2.writer, &mck2, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&live, &.{"init"}));
try std.testing.expect(hasCall(&mck2, "git init --bare -q"));
try std.testing.expect(hasCall(&mck2, "remote add origin git@gitlab.com:u/zz-base-home-docs.git"));
try std.testing.expect(hasCall(&mck2, "remote add mirr git@gitlab.com:u/zz-base-home-docs.git"));
const excl = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, try std.fs.path.join(allo, &.{ home, ".zz-base-home-docs.git", "info", "exclude" }), allo, .limited(64));
try std.testing.expectEqualStrings("*\n", excl);
}
test "init: ls-remote exit 2 means no docs yet (skip), any other failure is reported, never skipped silently" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const gitd = try std.fs.path.join(allo, &.{ home, ".zz-base-home-docs.git" });
const lsr: []const []const u8 = &.{ "git", "--git-dir", gitd, "ls-remote" };
var mck: mock.Mock = .{ .rule = &.{ GTOP, .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = lsr, .code = 2 }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const none = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&none, &.{"init"}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "remote has no docs yet") != null and !hasCall(&mck, "checkout"));
var mck2: mock.Mock = .{ .rule = &.{ GTOP, .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = lsr, .code = 128, .errz = "could not read from remote" }, .{ .pref = &.{"git"} } } };
var buf2: std.Io.Writer.Allocating = .init(allo);
const down = make.make(allo, &buf2.writer, &mck2, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&down, &.{"init"}));
try std.testing.expect(std.mem.indexOf(u8, buf2.written(), "cannot reach origin") != null and !hasCall(&mck2, "checkout"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
