// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo secr: usage, init dry-run/live/again, lend blocked
// Flo: scratch home > run each sub-command > check dir and exit code
// I/O: scratch dir under .zig-cache/tmp > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const secr = @import("ct-comm-secr.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const exit = @import("ct-exit-code.zig");
fn exists(allo: std.mem.Allocator, home: []const u8) bool {
const dirz = std.fmt.allocPrint(allo, "{s}/.zz-base-home-secr", .{home}) catch return false;
return if (std.Io.Dir.cwd().statFile(std.testing.io, dirz, .{})) |_| true else |_| false;
}
test "no sub-command or an unknown one is a usage error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", true, false);
try std.testing.expectError(exit.Erro.Usag, secr.comm(&ctxz, &.{}));
try std.testing.expectError(exit.Erro.Usag, secr.comm(&ctxz, &.{"bogus"}));
}
test "init: dry-run creates nothing, live creates, second live skips" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{} };
var buf1: std.Io.Writer.Allocating = .init(allo);
const dry = make.make(allo, &buf1.writer, &mck, .{}, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try secr.comm(&dry, &.{"init"}));
try std.testing.expect(!exists(allo, home));
try std.testing.expect(std.mem.indexOf(u8, buf1.written(), "dry-run: would create") != null);
var buf2: std.Io.Writer.Allocating = .init(allo);
const live = make.make(allo, &buf2.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try secr.comm(&live, &.{"init"}));
try std.testing.expect(exists(allo, home));
try std.testing.expect(std.mem.indexOf(u8, buf2.written(), "created") != null);
var buf3: std.Io.Writer.Allocating = .init(allo);
const again = make.make(allo, &buf3.writer, &mck, .{}, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try secr.comm(&again, &.{"init"}));
try std.testing.expect(std.mem.startsWith(u8, buf3.written(), "skip\tinit\texists"));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
test "lend is blocked until the vault exists" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", true, false);
try std.testing.expectEqual(exit.Code.bloc, try secr.comm(&ctxz, &.{ "lend", "--scope", "x" }));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
