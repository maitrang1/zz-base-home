// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo docs: url derive, init, sync, leak stop, one-winner conflict policy
// Flo: mock git + gitleaks > run init / sync > check argv, env, saved losers, stamp, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const docs = @import("ct-comm-docs.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
const STMP = "20231114-221320";
const GLST: mock.Rule = .{ .pref = &.{ "git", "-C" }, .outz = "do-core-plan/\x00ac-auto-task/do-docs-deve/\x00aa-todo-note/\x00CLAUDE.md\x00ac-auto-task/CLAUDE.md\x00zig-out/\x00as-apps/ai-mind/ag-agen-code/\x00node_modules/\x00" };
fn gtop(top: []const u8) mock.Rule { return .{ .pref = &.{ "git", "rev-parse" }, .outz = top }; }
fn hasCall(mck: *const mock.Mock, part: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
}
fn countCall(mck: *const mock.Mock, part: []const u8) usize {
var numb: usize = 0;
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) numb += 1; }
return numb;
}
fn fileMake(path: []const u8, body: []const u8) !void {
if (std.fs.path.dirname(path)) |dirz| try std.Io.Dir.cwd().createDirPath(std.testing.io, dirz);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = path, .data = body });
}
fn gitdMake(allo: std.mem.Allocator, home: []const u8) !void {
try fileMake(try std.fs.path.join(allo, &.{ home, ".zz-base-home-docs.git", "HEAD" }), "ref: refs/heads/main\n");
}
fn envHas(mck: *const mock.Mock, part: []const u8) bool {
for (mck.envz.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
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
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), .{ .pref = &.{"git"} } } };
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
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), GLST, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would sync 6 doc path(s)") != null);
try std.testing.expect(!hasCall(&mck, "git add") and !hasCall(&mck, "gitleaks"));
try std.testing.expect(ctxz.stamGet("docs") == null);
}
test "nothing changed: no scan, no commit, still merges and pushes both remotes, stamps" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), GLST, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "nothing changed") != null);
try std.testing.expect(!hasCall(&mck, "gitleaks") and !hasCall(&mck, " commit -q -m"));
try std.testing.expect(hasCall(&mck, "merge --no-edit -q refs/remotes/origin/main") and hasCall(&mck, "merge --no-edit -q refs/remotes/mirr/main"));
try std.testing.expect(hasCall(&mck, "git push -q origin HEAD:refs/heads/main") and hasCall(&mck, "git push -q mirr HEAD:refs/heads/main"));
try std.testing.expect(ctxz.stamGet("docs").?.okay);
}
test "changed files: only they are scanned, the commit gets an edit-time author date (future clamped), git dir via env" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
try fileMake(try std.fs.path.join(allo, &.{ top, "do-core-plan", "a.txt" }), "x");
var mck: mock.Mock = .{ .rule = &.{ gtop(top), GLST, .{ .pref = &.{ "git", "diff", "--cached" }, .outz = "do-core-plan/a.txt\x00" }, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expectEqual(@as(usize, 1), countCall(&mck, "gitleaks dir --redact --no-banner --exit-code 9"));
try std.testing.expect(hasCall(&mck, "a.txt") and hasCall(&mck, "git -c commit.gpgsign=false commit -q -m docs devb"));
try std.testing.expect(envHas(&mck, "GIT_AUTHOR_DATE=1700000000 +0000") and envHas(&mck, "GIT_DIR=") and envHas(&mck, ".zz-base-home-docs.git"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "1 changed file(s) clean") != null);
}
test "a leak unstages everything and stops before any commit or push" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
try fileMake(try std.fs.path.join(allo, &.{ top, "do-core-plan", "a.txt" }), "x");
var mck: mock.Mock = .{ .rule = &.{ gtop(top), GLST, .{ .pref = &.{ "git", "diff", "--cached" }, .outz = "do-core-plan/a.txt\x00" }, .{ .pref = &.{"git"} }, .{ .pref = &.{"gitleaks"}, .code = 9 } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git reset -q") and !hasCall(&mck, " commit ") and !hasCall(&mck, "git push"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "LEAK in a.txt") != null and ctxz.stamGet("docs") == null);
}
test "gitleaks absent blocks, unstages, commits nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
try fileMake(try std.fs.path.join(allo, &.{ top, "do-core-plan", "a.txt" }), "x");
var mck: mock.Mock = .{ .rule = &.{ gtop(top), GLST, .{ .pref = &.{ "git", "diff", "--cached" }, .outz = "do-core-plan/a.txt\x00" }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git reset -q") and !hasCall(&mck, " commit "));
}
fn saveMake(allo: std.mem.Allocator, top: []const u8, file: []const u8) !void {
try fileMake(try std.fs.path.join(allo, &.{ top, "zz-dele-auto", "_docs-" ++ STMP, file }), "loser");
}
test "a clash: the newer edit wins, the loser is saved aside first, then one merge commit and the push" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
try saveMake(allo, top, "a.txt");
try saveMake(allo, top, "b.txt");
var mck: mock.Mock = .{ .rule = &.{
gtop(top), GLST,
.{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "merge" }, .code = 1, .errz = "CONFLICT" },
.{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=U" }, .outz = "a.txt\x00b.txt\x00" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "HEAD", "--", "a.txt" }, .outz = "1700000100\n" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "refs/remotes/origin/main", "--", "a.txt" }, .outz = "1700000200\n" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "HEAD", "--", "b.txt" }, .outz = "1700000300\n" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "refs/remotes/origin/main", "--", "b.txt" }, .outz = "1700000100\n" },
.{ .pref = &.{ "git", "diff", "--cached" } },
.{ .pref = &.{"git"} },
.{ .pref = &.{"gitleaks"} },
} };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.docs_remo_list = &.{"origin"};
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git restore --source HEAD --worktree -- ") and hasCall(&mck, "a.txt"));
try std.testing.expect(hasCall(&mck, "git restore --source refs/remotes/origin/main --worktree -- "));
try std.testing.expect(hasCall(&mck, "git checkout --theirs -- ") and hasCall(&mck, "git checkout --ours -- "));
try std.testing.expectEqual(@as(usize, 2), countCall(&mck, "git add -f -- "));
try std.testing.expectEqual(@as(usize, 1), countCall(&mck, "git -c commit.gpgsign=false commit --no-edit -q"));
try std.testing.expect(envHas(&mck, "GIT_WORK_TREE=") and envHas(&mck, "_docs-" ++ STMP));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "resolved 2 file(s)") != null and hasCall(&mck, "git push -q origin HEAD:refs/heads/main"));
try std.testing.expect(!hasCall(&mck, "merge --abort") and ctxz.stamGet("docs").?.okay);
}
test "a tie goes to the remote, and a far-future remote date counts as now" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
try saveMake(allo, top, "a.txt");
var mck: mock.Mock = .{ .rule = &.{
gtop(top), GLST,
.{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "merge" }, .code = 1 },
.{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=U" }, .outz = "a.txt\x00" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "HEAD", "--", "a.txt" }, .outz = "1700000000\n" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "refs/remotes/origin/main", "--", "a.txt" }, .outz = "1700000000\n" },
.{ .pref = &.{ "git", "diff", "--cached" } },
.{ .pref = &.{"git"} },
} };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.docs_remo_list = &.{"origin"};
const tie = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&tie, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git checkout --theirs -- "));
var mck2: mock.Mock = .{ .rule = &.{
gtop(top), GLST,
.{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "merge" }, .code = 1 },
.{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=U" }, .outz = "a.txt\x00" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "HEAD", "--", "a.txt" }, .outz = "1700000100\n" },
.{ .pref = &.{ "git", "log", "-1", "--format=%at", "refs/remotes/origin/main", "--", "a.txt" }, .outz = "9999999999\n" },
.{ .pref = &.{ "git", "diff", "--cached" } },
.{ .pref = &.{"git"} },
} };
var buf2: std.Io.Writer.Allocating = .init(allo);
const fut = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&fut, &.{"sync"}));
try std.testing.expect(hasCall(&mck2, "git checkout --ours -- ") and !hasCall(&mck2, "git checkout --theirs -- "));
}
test "edit versus delete keeps the file, whichever side deleted it, and saves nothing for the deleted side" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
var mck: mock.Mock = .{ .rule = &.{
gtop(top), GLST,
.{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "merge" }, .code = 1 },
.{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=U" }, .outz = "a.txt\x00" },
.{ .pref = &.{ "git", "cat-file", "-e", "HEAD:a.txt" }, .code = 128 },
.{ .pref = &.{ "git", "log", "-1", "--format=%at" }, .outz = "1700000100\n" },
.{ .pref = &.{ "git", "diff", "--cached" } },
.{ .pref = &.{"git"} },
} };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.docs_remo_list = &.{"origin"};
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git checkout --theirs -- ") and !hasCall(&mck, "git restore"));
}
test "a failed loser save aborts the merge, pushes nothing, writes no stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
const top = try std.fs.path.join(allo, &.{ home, "repo" });
var mck: mock.Mock = .{ .rule = &.{
gtop(top), GLST,
.{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "merge" }, .code = 1, .errz = "CONFLICT" },
.{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=U" }, .outz = "a.txt\x00" },
.{ .pref = &.{ "git", "restore" }, .code = 1 },
.{ .pref = &.{ "git", "diff", "--cached" } },
.{ .pref = &.{"git"} },
} };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.docs_remo_list = &.{"origin"};
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(hasCall(&mck, "git merge --abort") and !hasCall(&mck, "git push") and !hasCall(&mck, "git checkout --"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "aborted, nothing lost") != null and ctxz.stamGet("docs") == null);
}
test "a push that keeps being rejected retries 3 times, then fails with the reason" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), GLST, .{ .pref = &.{ "git", "push" }, .code = 1, .errz = "non-fast-forward" }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.docs_remo_list = &.{"origin"};
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expectEqual(@as(usize, 3), countCall(&mck, "git fetch -q origin"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "rejected 3 times: non-fast-forward") != null and ctxz.stamGet("docs") == null);
}
test "an unreachable remote on fetch stops the sync with the reason" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try gitdMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), GLST, .{ .pref = &.{ "git", "fetch" }, .code = 128, .errz = "could not resolve host" }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&ctxz, &.{"sync"}));
try std.testing.expect(!hasCall(&mck, "git push") and std.mem.indexOf(u8, buff.written(), "could not resolve host") != null);
}
test "init dry-run changes nothing; live creates the git dir, exclude-all, remotes from the main repo; empty remote skips restore" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = &.{ "git", "--git-dir" }, .code = 0 }, .{ .pref = &.{ "git", "config", "--get" }, .outz = "val\n" }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const dry = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&dry, &.{"init"}));
try std.testing.expect(!hasCall(&mck, "git init"));
var mck2: mock.Mock = .{ .rule = &.{ gtop("top"), .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = &.{ "git", "--git-dir", "x" } }, .{ .pref = &.{ "git", "config", "--get" }, .outz = "val\n" }, .{ .pref = &.{"git"} } } };
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
var mck: mock.Mock = .{ .rule = &.{ gtop("top"), .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = lsr, .code = 2 }, .{ .pref = &.{"git"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const none = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try docs.comm(&none, &.{"init"}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "remote has no docs yet") != null and !hasCall(&mck, "checkout"));
var mck2: mock.Mock = .{ .rule = &.{ gtop("top"), .{ .pref = &.{ "git", "remote", "get-url" }, .outz = "git@gitlab.com:u/zz-base-home.git\n" }, .{ .pref = lsr, .code = 128, .errz = "could not read from remote" }, .{ .pref = &.{"git"} } } };
var buf2: std.Io.Writer.Allocating = .init(allo);
const down = make.make(allo, &buf2.writer, &mck2, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try docs.comm(&down, &.{"init"}));
try std.testing.expect(std.mem.indexOf(u8, buf2.written(), "cannot reach origin") != null and !hasCall(&mck2, "checkout"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
