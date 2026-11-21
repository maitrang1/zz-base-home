// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo wipz: dry-run, clean, live, chain, leaks
// Flo: mock git + gitleaks + restic > run > check the call order, env, stamp file and exit code
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const wipz = @import("ct-comm-wipz.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const stat = @import("st-stat-file.zig");
const exit = @import("ct-exit-code.zig");
const SHAA: *const [40]u8 = &@splat('a');
const SHAB: *const [40]u8 = &@splat('b');
const SHAC: *const [40]u8 = &@splat('c');
const REFZ = "refs/wipz/devb/head";
const MARK = "refs/wipz/devb/d20231114";
const Opts = struct { leak: u8 = 0, absn: bool = false, badp: bool = false, prev: bool = false, ptre: []const u8 = SHAC, bigz: []const u8 = "" };
fn rules(opt: Opts) [17]mock.Rule {
return .{
.{ .pref = &.{ "git", "status" }, .outz = " M file\n" },
.{ .pref = &.{ "git", "ls-files" }, .outz = opt.bigz },
.{ .pref = &.{ "git", "read-tree" } },
.{ .pref = &.{ "git", "add" } },
.{ .pref = &.{ "git", "rm" } },
.{ .pref = &.{ "git", "write-tree" }, .outz = SHAA ++ "\n" },
.{ .pref = &.{ "git", "rev-parse", "--verify" }, .code = if (opt.prev) 0 else 1, .outz = SHAC ++ "\n" },
.{ .pref = &.{ "git", "rev-parse", SHAC ++ "^{tree}" }, .outz = opt.ptre },
.{ .pref = &.{ "git", "commit-tree" }, .outz = SHAB ++ "\n" },
.{ .pref = &.{ "git", "update-ref" } },
.{ .pref = &.{ "git", "bundle" } },
.{ .pref = &.{"restic"} },
.{ .pref = &.{"gitleaks"}, .code = opt.leak, .absn = opt.absn },
.{ .pref = &.{ "git", "push", "mirr" }, .code = if (opt.badp) 1 else 0, .errz = "denied" },
.{ .pref = &.{ "git", "push", "orig" } },
.{ .pref = &.{"zzzz"} },
.{ .pref = &.{"zzzy"} },
};
}
fn conf2() cfgz.Conf { var cfgv: cfgz.Conf = .{}; cfgv.wipz_remo_list = &.{ "orig", "mirr" }; return cfgv; }
fn hasCall(mck: *const mock.Mock, pref: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.startsWith(u8, line, pref)) return true; }
return false;
}
test "clean tree: skip, one git call only" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "git", "status" }, .outz = "\n" }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), "h", true, false);
try std.testing.expectEqual(exit.Code.okay, try wipz.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 1), mck.call.items.len);
try std.testing.expectEqualStrings("skip\tsnap\tclean, nothing to snapshot\n", buff.written());
}
test "dry-run on a dirty tree changes nothing and names the head ref" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const rul = rules(.{});
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), "h", false, false);
try std.testing.expectEqual(exit.Code.okay, try wipz.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 1), mck.call.items.len);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), REFZ) != null);
}
test "no remotes configured is blocked, nothing runs after status" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const rul = rules(.{});
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", true, false);
try std.testing.expectEqual(exit.Code.bloc, try wipz.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 1), mck.call.items.len);
}
test "live first run: exact call order, parent HEAD, head ref, bookmark, both stamps" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const rul = rules(.{});
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.okay, try wipz.comm(&ctxz, &.{}));
const want = [_][]const u8{ "git status --porcelain", "git ls-files -z --others --modified --exclude-standard", "git read-tree HEAD", "git add -A", "git write-tree", "git rev-parse --verify -q " ++ REFZ, "git commit-tree " ++ SHAA ++ " -p HEAD -m wipz", "gitleaks git --redact --no-banner --exit-code 9 --log-opts=" ++ SHAB ++ "^!", "git update-ref " ++ REFZ ++ " " ++ SHAB, "git push orig " ++ REFZ ++ ":" ++ REFZ, "git push mirr " ++ REFZ ++ ":" ++ REFZ, "git update-ref " ++ MARK ++ " " ++ SHAB, "git push orig " ++ MARK ++ ":" ++ MARK, "git push mirr " ++ MARK ++ ":" ++ MARK };
try std.testing.expectEqual(want.len, mck.call.items.len);
for (want, 0..) |line, indx| try std.testing.expectEqualStrings(line, mck.call.items[indx]);
try std.testing.expectEqual(@as(usize, 3), mck.envz.items.len);
for (mck.envz.items) |envl| try std.testing.expect(std.mem.startsWith(u8, envl, "GIT_INDEX_FILE=") and std.mem.endsWith(u8, envl, "wipz.idx"));
const dirz = try stat.dirzOf(allo, home, "as-apps/os-syst/wo-work-mode");
const stam = stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "wipz")).?;
try std.testing.expectEqual(make.NOWZ, stam.when);
try std.testing.expect(stam.okay);
try std.testing.expectEqualStrings(SHAB, stam.note);
const stmd = stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "wipzd")).?;
try std.testing.expectEqualStrings(MARK, stmd.note);
}
test "second run the same day: parent is the previous head, no new bookmark" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const dirz = try stat.dirzOf(allo, home, "as-apps/os-syst/wo-work-mode");
try stat.stamWrit(allo, std.testing.io, dirz, try stat.pathOf(allo, dirz, "wipzd"), .{ .when = make.NOWZ - 600, .okay = true, .note = MARK });
const rul = rules(.{ .prev = true, .ptre = SHAB });
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.okay, try wipz.comm(&ctxz, &.{}));
try std.testing.expect(hasCall(&mck, "git commit-tree " ++ SHAA ++ " -p " ++ SHAC ++ " -m wipz"));
try std.testing.expect(!hasCall(&mck, "git update-ref " ++ MARK));
try std.testing.expect(!hasCall(&mck, "git push orig " ++ MARK));
}
test "tree equal to the last snapshot: skip, nothing committed or pushed" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const rul = rules(.{ .prev = true, .ptre = SHAA ++ "\n" });
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.okay, try wipz.comm(&ctxz, &.{}));
try std.testing.expect(!hasCall(&mck, "git commit-tree"));
try std.testing.expect(!hasCall(&mck, "git push"));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "same as the last snapshot") != null);
}
test "a file over the limit is dropped from the snapshot and alerted" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const bigp = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}/big.bin", .{tmp.sub_path});
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = bigp, .data = "0123456789ABCDEF" });
const lsfl = try std.fmt.allocPrint(allo, "{s}\x00", .{bigp});
const rul = rules(.{ .bigz = lsfl });
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv = conf2();
cfgv.wipz_file_maxz = 8;
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.drif, try wipz.comm(&ctxz, &.{}));
try std.testing.expect(hasCall(&mck, try std.fmt.allocPrint(allo, "git rm --cached -q --ignore-unmatch -- {s}", .{bigp})));
try std.testing.expect(hasCall(&mck, "git push orig " ++ REFZ));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "skipped 1 file(s)") != null);
}
test "gitleaks hit: no git push, ref kept local, restic gets the bundle, exit fail, no stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const rul = rules(.{ .leak = 9 });
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.fail, try wipz.comm(&ctxz, &.{}));
try std.testing.expect(!hasCall(&mck, "git push"));
try std.testing.expect(!hasCall(&mck, "git update-ref " ++ REFZ));
try std.testing.expect(hasCall(&mck, "git update-ref refs/wipz/devb/held " ++ SHAB));
try std.testing.expect(hasCall(&mck, "git bundle create "));
try std.testing.expect(std.mem.indexOf(u8, mck.call.items[mck.call.items.len - 2], "^HEAD") != null);
try std.testing.expect(std.mem.startsWith(u8, mck.call.items[mck.call.items.len - 1], "restic backup --tag wipz-held "));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "LEAK found") != null);
const dirz = try stat.dirzOf(allo, home, "as-apps/os-syst/wo-work-mode");
try std.testing.expect(stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "wipz")) == null);
}
test "gitleaks error (not a leak) and gitleaks missing both abort the push" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const err = rules(.{ .leak = 1 });
var mck1: mock.Mock = .{ .rule = &err };
var buf1: std.Io.Writer.Allocating = .init(allo);
const ct1 = make.make(allo, &buf1.writer, &mck1, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.fail, try wipz.comm(&ct1, &.{}));
try std.testing.expect(std.mem.indexOf(u8, buf1.written(), "LEAK") == null);
try std.testing.expect(!hasCall(&mck1, "restic"));
const abs = rules(.{ .absn = true });
var mck2: mock.Mock = .{ .rule = &abs };
var buf2: std.Io.Writer.Allocating = .init(allo);
const ct2 = make.make(allo, &buf2.writer, &mck2, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try wipz.comm(&ct2, &.{}));
try std.testing.expect(!hasCall(&mck2, "git push"));
}
test "one failing remote fails the run, no bookmark, no stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const rul = rules(.{ .badp = true });
var mck: mock.Mock = .{ .rule = &rul };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.fail, try wipz.comm(&ctxz, &.{}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "denied") != null);
try std.testing.expect(!hasCall(&mck, "git update-ref " ++ MARK));
const dirz = try stat.dirzOf(allo, home, "as-apps/os-syst/wo-work-mode");
try std.testing.expect(stat.stamRead(allo, std.testing.io, try stat.pathOf(allo, dirz, "wipz")) == null);
}
test "a garbage tree sha stops the run before commit" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "git", "status" }, .outz = "M f" }, .{ .pref = &.{ "git", "ls-files" } }, .{ .pref = &.{ "git", "read-tree" } }, .{ .pref = &.{ "git", "add" } }, .{ .pref = &.{ "git", "write-tree" }, .outz = "xyz\n" } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, conf2(), home, true, false);
try std.testing.expectEqual(exit.Code.fail, try wipz.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 5), mck.call.items.len);
}
test "ref names pad fields and use UTC" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
try std.testing.expectEqualStrings("refs/wipz/d/head", try wipz.headName(allo, "d"));
try std.testing.expectEqualStrings("refs/wipz/d/held", try wipz.heldName(allo, "d"));
try std.testing.expectEqualStrings("refs/wipz/d/d19700101", try wipz.markName(allo, "d", 0));
try std.testing.expectEqualStrings("refs/wipz/d/d20240229", try wipz.markName(allo, "d", 1709210096));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
