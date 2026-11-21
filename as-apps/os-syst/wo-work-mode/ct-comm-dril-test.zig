// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo dril: dry-run, good, bad, slow, failed
// Flo: mock restic/sqlite3/git + planted .db file > run > check facts, stamp, exit code
// I/O: scratch dir under .zig-cache/tmp > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const dril = @import("ct-comm-dril.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const stat = @import("st-stat-file.zig");
const exit = @import("ct-exit-code.zig");
var tick: i64 = 0;
var bump: i64 = 0;
var seen: i64 = 0;
fn slowNow(iozz: std.Io) i64 { _ = iozz; tick += 1000; return make.NOWZ + tick; }
fn edgeNow(iozz: std.Io) i64 { _ = iozz; seen += 1; return make.NOWZ + (if (seen > 2) bump else 0); }
fn edgeRun(allo: std.mem.Allocator, home: []const u8, secs: i64) !exit.Code {
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"restic"} }} };
var buff: std.Io.Writer.Allocating = .init(allo);
var ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
seen = 0;
bump = secs;
ctxz.nowf = edgeNow;
return dril.comm(&ctxz, &.{});
}
fn plant(allo: std.mem.Allocator, home: []const u8, name: []const u8) !void {
const scra = try std.fmt.allocPrint(allo, "{s}/as-apps/os-syst/wo-work-mode/dril-20231114-221320", .{home});
try std.Io.Dir.cwd().createDirPath(std.testing.io, scra);
const path = try std.fmt.allocPrint(allo, "{s}/{s}", .{ scra, name });
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = path, .data = "x" });
}
fn stamOf(allo: std.mem.Allocator, home: []const u8) ?stat.Stam {
const dirz = stat.dirzOf(allo, home, "as-apps/os-syst/wo-work-mode") catch return null;
return stat.stamRead(allo, std.testing.io, stat.pathOf(allo, dirz, "dril") catch return null);
}
test "dry-run touches nothing: no tool call, no scratch dir, no stamp" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try dril.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
try std.testing.expect(stamOf(allo, home) == null);
}
test "good drill: restore, every .db checked, fsck on mirror, stamp ok" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try plant(allo, home, "a.db");
var cfgv: cfgz.Conf = .{};
cfgv.dril_mirr_dirz = "mirr";
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{"restic"} }, .{ .pref = &.{"sqlite3"}, .outz = "ok\n" }, .{ .pref = &.{ "git", "-C", "mirr", "fsck" } } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try dril.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 3), mck.call.items.len);
try std.testing.expect(std.mem.startsWith(u8, mck.call.items[0], "restic restore latest --target "));
try std.testing.expect(std.mem.endsWith(u8, mck.call.items[0], "dril-20231114-221320"));
try std.testing.expect(std.mem.indexOf(u8, mck.call.items[1], "a.db PRAGMA integrity_check;") != null);
try std.testing.expectEqualStrings("git -C mirr fsck --no-progress", mck.call.items[2]);
const stam = stamOf(allo, home).?;
try std.testing.expect(stam.okay);
try std.testing.expectEqual(@as(i64, 0), stam.secs);
}
test "a db that fails integrity_check fails the drill and the stamp says not okay" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try plant(allo, home, "bad.db");
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{"restic"} }, .{ .pref = &.{"sqlite3"}, .outz = "row 3 missing\n" } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try dril.comm(&ctxz, &.{}));
try std.testing.expect(!stamOf(allo, home).?.okay);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "row 3 missing") != null);
}
test "restore failure skips the checks, fails, stamp not okay" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"restic"}, .code = 1, .errz = "repo locked" }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try dril.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 1), mck.call.items.len);
try std.testing.expect(!stamOf(allo, home).?.okay);
}
test "restic missing is blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try dril.comm(&ctxz, &.{}));
}
test "sqlite3 missing is blocked when a .db exists" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try plant(allo, home, "a.db");
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"restic"} }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try dril.comm(&ctxz, &.{}));
}
test "RTO boundary: exactly 900s passes, 901s fails" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try std.testing.expectEqual(exit.Code.okay, try edgeRun(allo, home, 900));
try std.testing.expectEqual(@as(i64, 900), stamOf(allo, home).?.secs);
try std.testing.expectEqual(exit.Code.fail, try edgeRun(allo, home, 901));
try std.testing.expectEqual(@as(i64, 901), stamOf(allo, home).?.secs);
}
test "a drill slower than the RTO fails even when every step passed" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"restic"} }} };
var buff: std.Io.Writer.Allocating = .init(allo);
var ctxz = make.make(allo, &buff.writer, &mck, .{}, home, true, false);
tick = 0;
ctxz.nowf = slowNow;
try std.testing.expectEqual(exit.Code.fail, try dril.comm(&ctxz, &.{}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "limit 900s") != null);
try std.testing.expect(!stamOf(allo, home).?.okay);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
