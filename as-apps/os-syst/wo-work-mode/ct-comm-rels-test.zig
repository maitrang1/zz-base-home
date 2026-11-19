// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo rels sign: tag check, verified gate, dry-run, live order
// Flo: mock gh + ssh-keygen > run sign > check argv order, gates, stamp, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const rels = @import("ct-comm-rels.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
const OKAY = "release notes\n\xe2\x9c\x85 Verified: GitHub and GitLab built identical bytes (4 binaries).\n";
fn hasCall(mck: *const mock.Mock, part: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
}
fn keyMake(allo: std.mem.Allocator, home: []const u8) !void {
try std.Io.Dir.cwd().createDirPath(std.testing.io, home);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = try std.fs.path.join(allo, &.{ home, "key.pub" }), .data = "ssh-ed25519 AAAA test\n" });
}
fn confMake() cfgz.Conf {
var cfgv: cfgz.Conf = .{};
cfgv.rels_keyz_file = "key.pub";
return cfgv;
}
test "tagOkay: v-prefixed plain names only" {
try std.testing.expect(rels.tagOkay("v0.1.0-rc2") and rels.tagOkay("v1"));
try std.testing.expect(!rels.tagOkay("0.1.0") and !rels.tagOkay("v") and !rels.tagOkay("v1/../x") and !rels.tagOkay("v1 2") and !rels.tagOkay("v1;rm"));
}
test "usage: sign TAG only" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", false, false);
try std.testing.expectError(exit.Erro.Usag, rels.comm(&ctxz, &.{}));
try std.testing.expectError(exit.Erro.Usag, rels.comm(&ctxz, &.{"sign"}));
try std.testing.expectError(exit.Erro.Usag, rels.comm(&ctxz, &.{ "verify", "v1" }));
}
test "bad tag fails, missing key blocks, nothing runs" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"gh"}, .outz = OKAY }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confMake(), home, true, false);
try std.testing.expectEqual(exit.Code.fail, try rels.comm(&ctxz, &.{ "sign", "../x" }));
try std.testing.expectEqual(exit.Code.bloc, try rels.comm(&ctxz, &.{ "sign", "v1" }));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
test "a release that is not Verified yet is blocked and nothing is signed" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try keyMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "gh", "release", "view" }, .outz = "Pending: the GitLab cross-build check has not finished\n" }, .{ .pref = &.{"gh"} }, .{ .pref = &.{"ssh-keygen"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confMake(), home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try rels.comm(&ctxz, &.{ "sign", "v1.0.0" }));
try std.testing.expect(!hasCall(&mck, "ssh-keygen") and !hasCall(&mck, "release upload") and ctxz.stamGet("rels") == null);
}
test "dry-run on a verified release reports the plan and signs nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try keyMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "gh", "release", "view" }, .outz = OKAY }, .{ .pref = &.{"gh"} }, .{ .pref = &.{"ssh-keygen"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confMake(), home, false, false);
try std.testing.expectEqual(exit.Code.okay, try rels.comm(&ctxz, &.{ "sign", "v1.0.0" }));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would sign sha256.txt of v1.0.0 with key.pub") != null);
try std.testing.expect(!hasCall(&mck, "ssh-keygen") and !hasCall(&mck, "download"));
}
test "live: download, sign with the namespace, upload the signature, stamp, in that order" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try keyMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "gh", "release", "view" }, .outz = OKAY }, .{ .pref = &.{"gh"} }, .{ .pref = &.{"ssh-keygen"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confMake(), home, true, false);
try std.testing.expectEqual(exit.Code.okay, try rels.comm(&ctxz, &.{ "sign", "v1.0.0" }));
try std.testing.expectEqual(@as(usize, 4), mck.call.items.len);
try std.testing.expect(std.mem.startsWith(u8, mck.call.items[1], "gh release download v1.0.0 -p sha256.txt -D "));
try std.testing.expect(std.mem.startsWith(u8, mck.call.items[2], "ssh-keygen -Y sign -f ") and std.mem.indexOf(u8, mck.call.items[2], "-n zz-base-home-release") != null and std.mem.endsWith(u8, mck.call.items[2], "sha256.txt"));
try std.testing.expect(std.mem.startsWith(u8, mck.call.items[3], "gh release upload v1.0.0 ") and std.mem.endsWith(u8, mck.call.items[3], "sha256.txt.sig --clobber"));
try std.testing.expect(ctxz.stamGet("rels").?.okay);
}
test "a failing signature step stops before the upload" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try keyMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "gh", "release", "view" }, .outz = OKAY }, .{ .pref = &.{"gh"} }, .{ .pref = &.{"ssh-keygen"}, .code = 255, .errz = "no agent" } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confMake(), home, true, false);
try std.testing.expectEqual(exit.Code.fail, try rels.comm(&ctxz, &.{ "sign", "v1.0.0" }));
try std.testing.expect(!hasCall(&mck, "release upload") and ctxz.stamGet("rels") == null);
}
test "gh absent blocks" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try keyMake(allo, home);
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confMake(), home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try rels.comm(&ctxz, &.{ "sign", "v1.0.0" }));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
