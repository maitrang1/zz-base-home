// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo push: parse, message, every gate, commit, rebase, retries
// Flo: mock git + tmp repo files + fake clock > run push > check argv, facts, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const push = @import("ct-comm-push.zig");
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
const Opt = struct { stat: []const u8 = " M a/one.txt\x00?? b/two.txt\x00", bran: []const u8 = "main\n", lead: []const u8 = "1\n", lagz: []const u8 = "0\n", anci: u8 = 0, commc: u8 = 0, rebc: u8 = 0, pushc: u8 = 0, diff: []const u8 = "" };
fn rules(allo: std.mem.Allocator, home: []const u8, opt: Opt) ![]const mock.Rule {
var out: std.ArrayList(mock.Rule) = .empty;
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "--show-toplevel" }, .outz = home });
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "--abbrev-ref" }, .outz = opt.bran });
try out.append(allo, .{ .pref = &.{ "git", "rev-parse", "--absolute-git-dir" }, .outz = try std.fs.path.join(allo, &.{ home, ".git" }) });
try out.append(allo, .{ .pref = &.{ "git", "status" }, .outz = opt.stat });
try out.append(allo, .{ .pref = &.{ "git", "merge-base" }, .code = opt.anci });
try out.append(allo, .{ .pref = &.{ "git", "rev-list", "--count", "HEAD..origin/main" }, .outz = opt.lagz });
try out.append(allo, .{ .pref = &.{ "git", "rev-list", "--count", "HEAD..mirr/main" }, .outz = opt.lagz });
try out.append(allo, .{ .pref = &.{ "git", "rev-list", "--count" }, .outz = opt.lead });
try out.append(allo, .{ .pref = &.{ "git", "diff", "--name-only" }, .outz = opt.diff });
try out.append(allo, .{ .pref = &.{ "git", "rebase", "--abort" } });
try out.append(allo, .{ .pref = &.{ "git", "rebase" }, .code = opt.rebc });
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
return push.comm(&ctxz, &.{});
}
test "entrParse reads paths and skips the old name of a rename" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const got = try push.entrParse(arna.allocator(), " M a/x.txt\x00?? new dir/y.txt\x00R  to.txt\x00from.txt\x00A  z.txt\x00");
try std.testing.expectEqual(@as(usize, 4), got.len);
try std.testing.expectEqualStrings("a/x.txt", got[0]);
try std.testing.expectEqualStrings("new dir/y.txt", got[1]);
try std.testing.expectEqualStrings("to.txt", got[2]);
try std.testing.expectEqualStrings("z.txt", got[3]);
}
test "mesg names the device, the count and at most three top folders" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const got = try push.mesg(arna.allocator(), "dev1", &.{ "a/x", "a/y", "b/z", "c/q", "d/w", "root.txt" });
try std.testing.expectEqualStrings("auto(dev1): 6 file(s) · a, b, c", got);
}
test "usage: an argument" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", false, false);
try std.testing.expectError(exit.Erro.Usag, push.comm(&ctxz, &.{"x"}));
}
test "git absent is blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", true, false);
try std.testing.expectEqual(exit.Code.bloc, try push.comm(&ctxz, &.{}));
}
test "dry-run commits and pushes nothing, says what it would do" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{}, .{}, false, env.mtim + 1000, &buff, &mck));
try std.testing.expect(!hasCall(&mck, "git add") and !hasCall(&mck, "commit") and !hasCall(&mck, "git push"));
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
test "live: idle files are added, committed with a message, fetched, pushed to both remotes, stamped" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{}, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git add -A -- a/one.txt b/two.txt"));
try std.testing.expect(hasCall(&mck, "commit -q -m auto(devb): 2 file(s) · a, b -- a/one.txt b/two.txt"));
try std.testing.expect(hasCall(&mck, "git fetch origin main") and hasCall(&mck, "git fetch mirr main"));
try std.testing.expect(hasCall(&mck, "git push origin main") and hasCall(&mck, "git push mirr main"));
try std.testing.expect(!hasCall(&mck, "rebase"));
const ctxz = make.make(allo, &buff.writer, &mck, .{}, env.home, true, false);
try std.testing.expect(ctxz.stamGet("push").?.okay);
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
cfgv.push_deny_list = &.{"b/"};
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{}, cfgv, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git add -A -- a/one.txt") and !hasCall(&mck, "b/two.txt"));
}
test "a file over the size limit or too many files: blocked, nothing staged" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
var big: cfgz.Conf = .{};
big.push_file_maxz = 1;
try std.testing.expectEqual(exit.Code.bloc, try run(allo, env, .{}, big, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "over 1 bytes: b/two.txt") != null and !hasCall(&mck, "git add"));
var many: cfgz.Conf = .{};
many.push_file_cntz = 1;
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
test "remotes diverged: fails, pushes nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .anci = 1 }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "diverged") != null and !hasCall(&mck, "git push"));
}
test "behind with local commits: rebase, then push; a conflict aborts and pushes nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .lagz = "2\n" }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(hasCall(&mck, "git rebase --autostash mirr/main") and hasCall(&mck, "git push origin main"));
var mck2: mock.Mock = undefined;
var buf2: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .lagz = "2\n", .rebc = 1 }, .{}, true, env.mtim + 1000, &buf2, &mck2));
try std.testing.expect(hasCall(&mck2, "git rebase --abort") and !hasCall(&mck2, "git push"));
}
test "incoming change on a file being edited: fails before the rebase" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.fail, try run(allo, env, .{ .lagz = "1\n", .diff = "a/one.txt\n" }, .{}, true, env.mtim + 10, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "incoming change touches a/one.txt") != null and !hasCall(&mck, "git rebase --autostash"));
}
test "behind only, no local commit: never pulls, says so" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const env = try envMake(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try run(allo, env, .{ .stat = "", .lead = "0\n", .lagz = "3\n" }, .{}, true, env.mtim + 1000, &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "behind mirr/main by 3: pull by hand") != null and !hasCall(&mck, "rebase") and !hasCall(&mck, "git push"));
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
test "nothing changed and nothing ahead: ok, no push" {
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
