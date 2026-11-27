// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo-work-mode kill: dry-run, live, bad config
// Flo: mock tools > run > check calls and exit code
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const kill = @import("ct-comm-kill.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
fn confK(steps: []const []const []const u8) cfgz.Conf { var cfgv: cfgz.Conf = .{}; cfgv.kill_step_list = steps; return cfgv; }
test "dry-run lists every step and runs none" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confK(&.{ &.{ "gh", "variable" }, &.{"claude"} }), "h", false, false);
try std.testing.expectEqual(exit.Code.okay, try kill.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would run gh variable") != null);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would run claude") != null);
}
test "live runs all steps in order even after one fails; result is fail" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{"one"}, .code = 1, .errz = "boom" }, .{ .pref = &.{"two"} }, .{ .pref = &.{"three"} } } };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confK(&.{ &.{"one"}, &.{ "two", "x" }, &.{"three"} }), "h", true, false);
try std.testing.expectEqual(exit.Code.fail, try kill.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 3), mck.call.items.len);
try std.testing.expectEqualStrings("one", mck.call.items[0]);
try std.testing.expectEqualStrings("two x", mck.call.items[1]);
try std.testing.expectEqualStrings("three", mck.call.items[2]);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "exit 1: boom") != null);
}
test "live, all steps pass: ok" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"one"}, .outz = "done" }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, confK(&.{&.{"one"}}), "h", true, false);
try std.testing.expectEqual(exit.Code.okay, try kill.comm(&ctxz, &.{}));
}
test "missing tool is blocked, empty step is a failure, empty list is blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buf1: std.Io.Writer.Allocating = .init(allo);
const ct1 = make.make(allo, &buf1.writer, &mck, confK(&.{&.{"ghost"}}), "h", true, false);
try std.testing.expectEqual(exit.Code.bloc, try kill.comm(&ct1, &.{}));
var buf2: std.Io.Writer.Allocating = .init(allo);
const ct2 = make.make(allo, &buf2.writer, &mck, confK(&.{&.{}}), "h", true, false);
try std.testing.expectEqual(exit.Code.fail, try kill.comm(&ct2, &.{}));
var buf3: std.Io.Writer.Allocating = .init(allo);
const ct3 = make.make(allo, &buf3.writer, &mck, confK(&.{}), "h", true, false);
try std.testing.expectEqual(exit.Code.bloc, try kill.comm(&ct3, &.{}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
