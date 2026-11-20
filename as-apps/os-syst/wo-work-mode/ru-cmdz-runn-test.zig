// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the tool runner and its mock
// Flo: absent tool > real exit code + stdout > env pairs reach the child > mock matching
// I/O: spawns only `zig` (the test toolchain) > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const runm = @import("ru-cmdz-runn.zig");
const mock = @import("te-mock-runn.zig");
test "a missing exe is ToolAbsent, not a crash" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
var envm: std.process.Environ.Map = .init(arna.allocator());
var real: runm.Real = .{ .iozz = std.testing.io, .envm = &envm };
try std.testing.expectError(runm.Erro.ToolAbsent, real.runn().exec(arna.allocator(), &.{"wo-no-such-tool-xyz"}, &.{}));
}
test "real run returns the exit code and stdout" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var envm = try std.testing.environ.createMap(allo);
var real: runm.Real = .{ .iozz = std.testing.io, .envm = &envm };
const okay = try real.runn().exec(allo, &.{ "zig", "version" }, &.{});
try std.testing.expectEqual(@as(u8, 0), okay.code);
try std.testing.expect(std.mem.startsWith(u8, std.mem.trim(u8, okay.outz, "\r\n "), "0."));
const bad = try real.runn().exec(allo, &.{ "zig", "no-such-subcommand-xyz" }, &.{});
try std.testing.expect(bad.code != 0);
try std.testing.expect(bad.errz.len > 0);
}
test "mock: longest-listed rule that is a prefix wins, no match = absent, calls are logged" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "git", "push", "bad" }, .code = 1, .errz = "no" }, .{ .pref = &.{"git"}, .outz = "fine" } } };
const bad = try mck.runn().exec(allo, &.{ "git", "push", "bad", "x" }, &.{});
try std.testing.expectEqual(@as(u8, 1), bad.code);
try std.testing.expectEqualStrings("no", bad.errz);
const okay = try mck.runn().exec(allo, &.{ "git", "status" }, &.{.{ "K", "V" }});
try std.testing.expectEqualStrings("fine", okay.outz);
try std.testing.expectError(runm.Erro.ToolAbsent, mck.runn().exec(allo, &.{"zig"}, &.{}));
try std.testing.expectEqual(@as(usize, 3), mck.call.items.len);
try std.testing.expectEqualStrings("git push bad x", mck.call.items[0]);
try std.testing.expectEqualStrings("K=V", mck.envz.items[0]);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
