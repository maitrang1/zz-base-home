// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for rn stat output
// Flo: text lists skip keys > a flipped key drops out > json > usage
// I/O: tmp dir fake machine > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const stat = @import("ct-comm-stat.zig");
const exit = @import("ct-exit-code.zig");
const cfgz = @import("cf-conf-load.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const names = [_][]const u8{ "bina", "arch", "sign_hash", "othe_user", "syst_owne", "runn_proc", "sync_remo", "pack_mana", "comp_part", "urls_exte", "enco_vari", "gitz_hist" };
test "text lists the version and every skip key that is on" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
try std.testing.expectEqual(exit.Code.okay, try stat.comm(&ctxz, &.{}));
const outz = aw.written();
try std.testing.expect(std.mem.startsWith(u8, outz, "rn 0.1.0 · "));
for (names) |name| try std.testing.expect(std.mem.indexOf(u8, outz, name) != null);
}
test "a key set to false drops out of the list" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var conf: cfgz.Conf = .{};
conf.skip_gitz_hist = false;
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
_ = try stat.comm(&ctxz, &.{});
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "gitz_hist") == null);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "enco_vari") != null);
}
test "json carries the skip flags" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, true);
_ = try stat.comm(&ctxz, &.{});
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "\"gitz_hist\":true") != null);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "\"vers\":\"0.1.0\"") != null);
}
test "stat takes no args" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
try std.testing.expectError(exit.Erro.Usag, stat.comm(&ctxz, &.{"x"}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
