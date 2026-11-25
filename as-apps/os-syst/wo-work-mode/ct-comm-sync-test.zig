// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests wo sync: parse, gates, merge, clash, retries, verify
// Flo: mock git + tmp repo files + fake clock > run sync > check argv, facts, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const sync = @import("ct-comm-sync.zig");
const cx = @import("ct-ctrl-ctxz.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
var fakeNow: i64 = 0;
fn fakeNowFn(iozz: std.Io) i64 { _ = iozz; return fakeNow; }
fn hasCall(mck: *const mock.Mock, part: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
}
fn callN(mck: *const mock.Mock, part: []const u8) usize {
var coun: usize = 0;
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) coun += 1; }
return coun;
}
fn filePut(allo: std.mem.Allocator, home: []const u8, name: []const u8, body: []const u8) !void {
const path = try std.fs.path.join(allo, &.{ home, name });
if (std.fs.path.dirname(path)) |dirz| try std.Io.Dir.cwd().createDirPath(std.testing.io, dirz);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = path, .data = body });
}
const Env = struct { home: []const u8, mtim: i64 };
fn envMake(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir) !Env {
const home = try make.homeOf(allo, tmp);
try filePut(allo, home, "a/one.txt", "1");
try filePut(allo, home, "b/two.txt", "22");
try std.Io.Dir.cwd().createDirPath(std.testing.io, try std.fs.path.join(allo, &.{ home, ".git" }));
const info = try std.Io.Dir.cwd().statFile(std.testing.io, try std.fs.path.join(allo, &.{ home, "a/one.txt" }), .{});
return .{ .home = home, .mtim = info.mtime.toSeconds() };
}
const Opt = struct { stat: []const u8 = " M a/one.txt\x00?? b/two.txt\x00", bran: []const u8 = "main\n", lead: []const u8 = "1\n", anci: u8 = 0, ffwd: bool = false, commc: u8 = 0, mrgc: u8 = 0, pushc: u8 = 0, incoming: []const u8 = "", added: []const u8 = "", unmerged: []const u8 = "", head: []const u8 = "abc\n", remo: []const u8 = "abc\n" };
fn rules(allo: std.mem.Allocator, home: []const u8, opt: Opt) ![]const mock.Rule {
var out: std.ArrayList(mock.Rule) = .empty;
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "--show-toplevel" }, .outz = home });
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "--abbrev-ref" }, .outz = opt.bran });
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "--absolute-git-dir" }, .outz = try std.fs.path.join(allo, &.{ home, ".git" }) });
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "HEAD" }, .outz = opt.head });
try out.append(allo, .{ .pref = &.{ "git", "rev-parse" }, .outz = opt.remo });
try out.append(allo, .{ .pref = &.{ "git", "status" }, .outz = opt.stat });
if (opt.ffwd) { try out.append(allo, .{ .pref = &.{ "git", "merge-base", "--is-ancestor", "HEAD", "origin/main" } }); try out.append(allo, .{ .pref = &.{ "git", "merge-base", "--is-ancestor", "HEAD", "mirr/main" } }); }
try out.append(allo, .{ .pref = &.{ "git", "merge-base" }, .code = opt.anci });
try out.append(allo, .{ .pref = &.{ "git", "rev-list", "--count" }, .outz = opt.lead });
try out.append(allo, .{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=A" }, .outz = opt.added });
try out.append(allo, .{ .pref = &.{ "git", "diff", "--name-only", "--diff-filter=U" }, .outz = opt.unmerged });
try out.append(allo, .{ .pref = &.{ "git", "diff", "--name-only" }, .outz = opt.incoming });
try out.append(allo, .{ .pref = &.{ "git", "log", "-1" }, .outz = "100\n" });
try out.append(allo, .{ .pref = &.{ "git", "ls-files" }, .outz = "" });
try out.append(allo, .{ .pref = &.{ "git", "merge", "--abort" } });
try out.append(allo, .{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "merge" }, .code = opt.mrgc, .errz = "CONFLICT" });
try out.append(allo, .{ .pref = &.{ "git", "-c", "commit.gpgsign=false", "commit", "--no-edit" } });
try out.append(allo, .{ .pref = &.{ "git", "-c" }, .code = opt.commc, .errz = "hook said no" });
try out.append(allo, .{ .pref = &.{ "git", "push" }, .code = opt.pushc });
try out.append(allo, .{ .pref = &.{"git"} });
return out.items;
}
fn run(allo: std.mem.Allocator, env: Env, opt: Opt, cfgv: cfgz.Conf, live: bool, now: i64, outb: *std.Io.Writer.Allocating, mck: *mock.Mock) !exit.Code {
mck.* = .{ .rule = try rules(allo, env.home, opt) };
fakeNow = now;
var ctxz = make.make(allo, &outb.writer, mck, cfgv, env.home, live, false);
ctxz.nowf = fakeNowFn;
return sync.comm(&ctxz, &.{});
}
test "entrParse reads paths and skips the old name of a rename" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const got = try sync.entrParse(arna.allocator(), " M a/x.txt\x00?? new dir/y.txt\x00R  to.txt\x00from.txt\x00C  cp.txt\x00orig.txt\x00A  z.txt\x00");
try std.testing.expectEqual(@as(usize, 6), got.len);
try std.testing.expectEqualStrings("a/x.txt", got[0]);
try std.testing.expectEqualStrings("new dir/y.txt", got[1]);
try std.testing.expectEqualStrings("to.txt", got[2]);
try std.testing.expectEqualStrings("from.txt", got[3]);
try std.testing.expectEqualStrings("cp.txt", got[4]);
try std.testing.expectEqualStrings("z.txt", got[5]);
}
test "mesg names the device, the count and at most three top folders" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const got = try sync.mesg(arna.allocator(), "dev1", &.{ "a/x", "a/y", "b/z", "c/q", "d/w", "root.txt" });
try std.testing.expectEqualStrings("auto(dev1): 6 file(s) · a, b, c", got);
}
test "usage: an argument; git absent is blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", true, false);
try std.testing.expectError(exit.Erro.Usag, sync.comm(&ctxz, &.{"x"}));
try std.testing.expectEqual(exit.Code.bloc, try sync.comm(&ctxz, &.{}));
}
test "dry-run commits, merges and pushes nothing, says what it would do" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{}, .{}, false, env.mtim + 1000, &buff, &mck));
try std.testing.expect(!hasCall(&mck, "git add") and !hasCall(&mck, "commit") and !hasCall(&mck, "git push") and !hasCall(&mck, "merge"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "dry-run: 2 to commit, 0 held") != null);
}
test "not on main, or git busy: blocked before anything changes" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.bloc, try run(allo, env, .{ .bran = "feature\n" }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(!hasCall(&mck, "git add"));
try filePut(allo, env.home, ".git/MERGE_HEAD", "x");
try std.testing.expectEqual(exit.Code.bloc, try run(allo, env, .{}, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "git is busy: MERGE_HEAD") != null and !hasCall(&mck, "git add"));
}
test "live, remotes already inside HEAD: commit, push both, verify equal, stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{}, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git add -A -f -- a/one.txt b/two.txt"));
try std.testing.expect(hasCall(&mck, "commit -q -m auto(devb): 2 file(s) · a, b -- a/one.txt b/two.txt"));
try std.testing.expect(hasCall(&mck, "git fetch origin main") and hasCall(&mck, "git fetch mirr main"));
try std.testing.expect(hasCall(&mck, "git push origin main") and hasCall(&mck, "git push mirr main"));
try std.testing.expect(!hasCall(&mck, "git -c commit.gpgsign=false merge") and !hasCall(&mck, "rebase"));
try std.testing.expect(mck.envz.items.len == 1 and std.mem.startsWith(u8, mck.envz.items[0], "GIT_AUTHOR_DATE=") and std.mem.endsWith(u8, mck.envz.items[0], " +0000"));
const ctxz = make.make(allo, &buff.writer, &mck, .{}, env.home, true, false);
try std.testing.expect(ctxz.stamGet("sync").?.okay);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "all devices on one version") != null);
}
test "a staged rename or a deleted file: the old path is dropped from the index and committed, never git-added" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .stat = "R  a/one.txt\x00old/gone.txt\x00D  old/two.txt\x00" }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git add -A -f -- a/one.txt") and !hasCall(&mck, "add -A -f -- a/one.txt old"));
try std.testing.expect(hasCall(&mck, "git rm --cached --ignore-unmatch -q -- old/gone.txt old/two.txt"));
try std.testing.expect(hasCall(&mck, "-- a/one.txt old/gone.txt old/two.txt"));
}
test "quiet window: files edited a moment ago are held, nothing to commit" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .lead = "0\n" }, .{}, true, env.mtim + 10, &buff, &mck));
try std.testing.expect(!hasCall(&mck, "git add") and !hasCall(&mck, "commit") and !hasCall(&mck, "git push"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "2 held") != null);
}
test "deny-list keeps a path out" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var cfgv: cfgz.Conf = .{};
cfgv.sync_deny_list = &.{"b/"};
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{}, cfgv, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git add -A -f -- a/one.txt") and !hasCall(&mck, "b/two.txt"));
}
test "a file over the size limit is kept out and reported; too many files blocks, nothing staged" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
var big: cfgz.Conf = .{};
big.sync_file_maxz = 1;
try std.testing.expectEqual(exit.Code.drif, try run(allo, env, .{}, big, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "over 1 bytes kept out, never published: b/two.txt") != null and hasCall(&mck, "git add -A -f -- a/one.txt") and !hasCall(&mck, "b/two.txt"));
var many: cfgz.Conf = .{};
many.sync_file_cntz = 1;
try std.testing.expectEqual(exit.Code.bloc, try run(allo, env, .{}, many, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(!hasCall(&mck, "git add"));
}
test "a hook that rejects the commit fails the run and resets the index" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .commc = 1 }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git reset -q -- a/one.txt b/two.txt") and !hasCall(&mck, "git push"));
}
test "a remote ahead (fast-forward): saved undo point, ff-only merge, then push and verify" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .stat = "", .lead = "0\n", .anci = 1, .ffwd = true }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git update-ref refs/wo-sync/pre-devb HEAD"));
try std.testing.expect(hasCall(&mck, "git merge --ff-only -q origin/main") and hasCall(&mck, "git merge --ff-only -q mirr/main") and !hasCall(&mck, "git push"));
}
test "diverged: a real merge of the remote tip, no clash, pushes the union" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
const opt: Opt = .{ .stat = "", .anci = 1 };
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, opt, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git -c commit.gpgsign=false merge --no-edit -q origin/main") or hasCall(&mck, "git merge --ff-only -q origin/main"));
try std.testing.expect(hasCall(&mck, "git push origin main") and hasCall(&mck, "git push mirr main"));
}
test "a same-line clash: the newer edit wins, the loser is saved, exit 3 lists the file" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
const now = env.mtim + 1000;
const stmp = try cx.stamTxt(allo, now);
try filePut(allo, env.home, try std.fmt.allocPrint(allo, "zz-dele-auto/_code-{s}/a/one.txt", .{stmp}), "loser");
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.drif, try run(allo, env, .{ .stat = "", .anci = 1, .mrgc = 1, .unmerged = "a/one.txt\x00" }, .{}, true, now, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git checkout --theirs -- ") and hasCall(&mck, "git add -f --") and hasCall(&mck, "commit --no-edit -q"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "resolved 1 file(s): the newer edit wins") != null and std.mem.indexOf(u8, buff.written(), "a/one.txt") != null);
try std.testing.expect(!hasCall(&mck, "merge --abort"));
}
test "a failed merge with nothing to resolve is aborted and fails" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .stat = "", .anci = 1, .mrgc = 1 }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git merge --abort") and !hasCall(&mck, "git push"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "nothing lost") != null);
}
test "incoming change on a file being edited: skipped, retried later, never overwritten" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .anci = 1, .incoming = "a/one.txt\n" }, .{}, true, env.mtim + 10, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "a/one.txt is being edited") != null);
try std.testing.expect(!hasCall(&mck, "merge --ff-only") and !hasCall(&mck, "merge --no-edit") and !hasCall(&mck, "git push"));
const ctxz = make.make(allo, &buff.writer, &mck, .{}, env.home, true, false);
try std.testing.expect(ctxz.stamGet("sync") == null);
}
test "a local file an incoming commit would overwrite is copied to zz-dele-auto first" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
try filePut(allo, env.home, "c/private.env", "SECRET_LOCAL");
const now = env.mtim + 1000;
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.drif, try run(allo, env, .{ .stat = "", .anci = 1, .ffwd = true, .added = "c/private.env\n" }, .{}, true, now, &buff, &mck));
const saved = try std.fs.path.join(allo, &.{ env.home, "zz-dele-auto", try std.fmt.allocPrint(allo, "_code-{s}", .{try cx.stamTxt(allo, now)}), "c/private.env" });
const data = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, saved, allo, .limited(1024));
try std.testing.expectEqualStrings("SECRET_LOCAL", data);
try std.testing.expect(hasCall(&mck, "git merge --ff-only -q origin/main"));
}
test "a push that keeps failing is tried three times, then fails" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .pushc = 1 }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expectEqual(@as(usize, 3), callN(&mck, "git fetch origin main"));
try std.testing.expectEqual(@as(usize, 1), callN(&mck, "git add"));
}
test "after the push a remote that is not at HEAD fails the verify" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .head = "aaa\n", .remo = "bbb\n" }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "is not at HEAD after the push") != null);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, env.home, true, false);
try std.testing.expect(ctxz.stamGet("sync") == null);
}
test "nothing changed and nothing ahead: ok, no push, no commit" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .stat = "", .lead = "0\n" }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(!hasCall(&mck, "git push") and !hasCall(&mck, "commit"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
