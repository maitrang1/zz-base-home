// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo stat: version, ages, failed runs
// Flo: scratch state files > run stat > check text and that exit is always ok
// I/O: scratch dir under .zig-cache/tmp > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const comm = @import("ct-comm-stat.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const stat = @import("st-stat-file.zig");
const exit = @import("ct-exit-code.zig");
test "fresh home: version + seven 'none yet' lines, exit ok, no tool run" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try comm.comm(&ctxz, &.{}));
try std.testing.expectEqualStrings("okay\tvers\two 0.1.0\nskip\twipz\tnone yet\nskip\tbkup\tnone yet\nskip\tbknt\tnone yet\nskip\tdocs\tnone yet\nskip\tsync\tnone yet\nskip\trels\tnone yet\nskip\tdril\tnone yet\n", buff.written());
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
test "ages come from the stamp; a failed last run is shown but never fails stat" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
const dirz = try stat.dirzOf(allo, home, "as-apps/os-syst/wo-work-mode");
try stat.stamWrit(allo, std.testing.io, dirz, try stat.pathOf(allo, dirz, "wipz"), .{ .when = make.NOWZ - 42, .okay = true });
try stat.stamWrit(allo, std.testing.io, dirz, try stat.pathOf(allo, dirz, "dril"), .{ .when = make.NOWZ - 7, .okay = false });
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try comm.comm(&ctxz, &.{}));
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "okay\twipz\tage 42s\n") != null);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "skip\tdril\tage 7s (last run failed)\n") != null);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
