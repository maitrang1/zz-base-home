// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests wo ci: every sub-command green, red, tool-absent
// Flo: mock gh/curl/git/zig/gitleaks + fixed clock > run ci > check argv, facts, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const ciii = @import("ct-comm-ci.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const exit = @import("ct-exit-code.zig");
fn hasCall(mck: *const mock.Mock, part: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
}
fn runCi(allo: std.mem.Allocator, rule: []const mock.Rule, home: []const u8, sub: []const u8, outb: *std.Io.Writer.Allocating, mck: *mock.Mock) !exit.Code {
mck.* = .{ .rule = rule };
const ctxz = make.make(allo, &outb.writer, mck, .{}, home, false, false);
return ciii.comm(&ctxz, &.{sub});
}
test "usage: no argument, extra argument and unknown sub-command" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", false, false);
try std.testing.expectError(exit.Erro.Usag, ciii.comm(&ctxz, &.{}));
try std.testing.expectError(exit.Erro.Usag, ciii.comm(&ctxz, &.{ "stat", "x" }));
try std.testing.expectError(exit.Erro.Usag, ciii.comm(&ctxz, &.{"nope"}));
}
test "leak and lock: green, red and tool absent" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{.{ .pref = &.{"gitleaks"} }}, "h", "leak", &buff, &mck));
try std.testing.expect(hasCall(&mck, "gitleaks git --redact --no-banner"));
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{"gitleaks"}, .code = 1, .errz = "leaks found" }}, "h", "leak", &buff, &mck));
try std.testing.expectEqual(exit.Code.bloc, try runCi(allo, &.{}, "h", "leak", &buff, &mck));
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{.{ .pref = &.{"gh"} }}, "h", "lock", &buff, &mck));
try std.testing.expect(hasCall(&mck, "gh actions-lock --no-fix"));
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{"gh"}, .code = 1 }}, "h", "lock", &buff, &mck));
}
test "test: both build files run, one red fails the run, the other still runs" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{.{ .pref = &.{"zig"} }}, "h", "test", &buff, &mck));
try std.testing.expect(hasCall(&mck, "--build-file as-apps/os-syst/wo-work-mode/build.zig") and hasCall(&mck, "--build-file ac-auto-task/build.zig"));
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{ "zig", "build", "test", "--summary", "all", "--build-file", "ac-auto-task/build.zig" }, .code = 1 }, .{ .pref = &.{"zig"} }}, "h", "test", &buff, &mck));
try std.testing.expectEqual(@as(usize, 2), mck.call.items.len);
try std.testing.expectEqual(exit.Code.bloc, try runCi(allo, &.{}, "h", "test", &buff, &mck));
}
test "stat: green, red GitHub, red GitLab, missing tools" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
const same = "aaa111\trefs/heads/main\n";
const gren: []const mock.Rule = &.{ .{ .pref = &.{"gh"}, .outz = "completed success\n" }, .{ .pref = &.{"curl"}, .outz = "[{\"id\":1,\"status\":\"success\",\"ref\":\"main\"}]" }, .{ .pref = &.{"git"}, .outz = same } };
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, gren, home, "stat", &buff, &mck));
try std.testing.expect(hasCall(&mck, "projects/dinhthimaitrang1%2Fzz-base-home/pipelines?ref=main&per_page=1") and hasCall(&mck, "git ls-remote origin refs/heads/main") and hasCall(&mck, "git ls-remote mirr refs/heads/main"));
const redg: []const mock.Rule = &.{ .{ .pref = &.{"gh"}, .outz = "completed failure\n" }, .{ .pref = &.{"curl"}, .outz = "[{\"status\":\"success\"}]" }, .{ .pref = &.{"git"}, .outz = same } };
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, redg, home, "stat", &buff, &mck));
const redl: []const mock.Rule = &.{ .{ .pref = &.{"gh"}, .outz = "in_progress \n" }, .{ .pref = &.{"curl"}, .outz = "[{\"status\":\"failed\"}]" }, .{ .pref = &.{"git"}, .outz = same } };
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, redl, home, "stat", &buff, &mck));
try std.testing.expectEqual(exit.Code.bloc, try runCi(allo, &.{}, home, "stat", &buff, &mck));
}
test "stat: mirror differs, inside the grace passes, past the grace fails, a match resets" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
const base: []const mock.Rule = &.{ .{ .pref = &.{"gh"}, .outz = "completed success\n" }, .{ .pref = &.{"curl"}, .outz = "[{\"status\":\"success\"}]" }, .{ .pref = &.{ "git", "ls-remote", "origin" }, .outz = "aaa\trefs/heads/main\n" }, .{ .pref = &.{ "git", "ls-remote", "mirr" }, .outz = "bbb\trefs/heads/main\n" } };
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, base, home, "stat", &buff, &mck));
const first = (make.make(allo, &buff.writer, &mck, .{}, home, false, false)).stamGet("cimi").?;
try std.testing.expect(!first.okay and first.when == make.NOWZ);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try ctxz.stamPut("cimi", .{ .when = make.NOWZ - 1000, .okay = false, .note = "differ" });
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, base, home, "stat", &buff, &mck));
const fixd: []const mock.Rule = &.{ .{ .pref = &.{"gh"}, .outz = "completed success\n" }, .{ .pref = &.{"curl"}, .outz = "[{\"status\":\"success\"}]" }, .{ .pref = &.{"git"}, .outz = "aaa\trefs/heads/main\n" } };
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, fixd, home, "stat", &buff, &mck));
try std.testing.expect(ctxz.stamGet("cimi").?.okay);
}
test "rele: none pending, pending, verified, mismatch" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{.{ .pref = &.{ "gh", "release", "list" }, .outz = "\n" }}, "h", "rele", &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "no pending prerelease") != null);
const lst: mock.Rule = .{ .pref = &.{ "gh", "release", "list" }, .outz = "v1.2.3\n" };
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{ lst, .{ .pref = &.{ "gh", "release", "view" }, .outz = "waiting on GitLab" } }, "h", "rele", &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "v1.2.3 still pending") != null);
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{ lst, .{ .pref = &.{ "gh", "release", "view" }, .outz = "Verified: GitHub and GitLab built identical bytes" } }, "h", "rele", &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "wo rels sign v1.2.3 --live") != null);
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{ lst, .{ .pref = &.{ "gh", "release", "view" }, .outz = "Verified: GitHub and GitLab built identical bytes\nsha256.txt\nsha256.txt.sig" } }, "h", "rele", &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "v1.2.3 Verified and signed") != null);
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{ lst, .{ .pref = &.{ "gh", "release", "view" }, .outz = "MISMATCH" } }, "h", "rele", &buff, &mck));
try std.testing.expectEqual(exit.Code.bloc, try runCi(allo, &.{}, "h", "rele", &buff, &mck));
}
test "deps: stale Dependabot PRs fail, none pass, the cut date is seven days back" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{.{ .pref = &.{"gh"}, .outz = "0\n" }}, "h", "deps", &buff, &mck));
try std.testing.expect(hasCall(&mck, "created:<2023-11-07"));
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{"gh"}, .outz = "2\n" }}, "h", "deps", &buff, &mck));
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{"gh"}, .outz = "oops" }}, "h", "deps", &buff, &mck));
}
fn binPut(allo: std.mem.Allocator, home: []const u8, run: []const u8, sub: []const u8, body: []const u8) !void {
const path = try std.fs.path.join(allo, &.{ home, "as-apps", "os-syst", "wo-work-mode", "repr", run, "dist", sub });
try std.Io.Dir.cwd().createDirPath(std.testing.io, std.fs.path.dirname(path).?);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = path, .data = body });
}
test "repr: identical builds pass, one differing file fails, a failed build stops" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = undefined;
var buff: std.Io.Writer.Allocating = .init(allo);
const subs = [_][]const u8{ "windows-x86_64/wo-work-mode.exe", "linux-x86_64/wo-work-mode", "linux-aarch64/wo-work-mode", "macos-aarch64/wo-work-mode" };
for (subs) |sub| { try binPut(allo, home, "run0", sub, sub); try binPut(allo, home, "run1", sub, sub); }
try std.testing.expectEqual(exit.Code.okay, try runCi(allo, &.{.{ .pref = &.{"zig"} }}, home, "repr", &buff, &mck));
try std.testing.expect(hasCall(&mck, "zig build dist --build-file as-apps/os-syst/wo-work-mode/build.zig --prefix"));
try binPut(allo, home, "run1", subs[1], "different");
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{"zig"} }}, home, "repr", &buff, &mck));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "two builds differ") != null);
try std.testing.expectEqual(exit.Code.fail, try runCi(allo, &.{.{ .pref = &.{"zig"}, .code = 1 }}, home, "repr", &buff, &mck));
try std.testing.expectEqual(@as(usize, 1), mck.call.items.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
