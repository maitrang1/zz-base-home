// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for global flag parsing and the safety ladder
// Flo: defaults > each flag > flags anywhere > bad combos
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const ladz = @import("ct-safe-ladd.zig");
fn run(allo: std.mem.Allocator, args: []const []const u8) !ladz.Pars { return ladz.parse(allo, args); }
test "default is dry-run: nothing live" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{ "doct" });
try std.testing.expect(!pars.ladd.live and !pars.ladd.forc and !pars.ladd.json);
try std.testing.expectEqual(@as(usize, 1), pars.rest.len);
try std.testing.expectEqualStrings("doct", pars.rest[0]);
}
test "--force without --live is refused, with --live accepted" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(ladz.Erro.ForcNeedLive, run(arna.allocator(), &.{ "kill", "--force" }));
const pars = try run(arna.allocator(), &.{ "--force", "kill", "--live" });
try std.testing.expect(pars.ladd.live and pars.ladd.forc);
}
test "flags work before, between and after positionals; positionals keep order" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{ "--json", "secr", "--live", "init" });
try std.testing.expect(pars.ladd.json and pars.ladd.live);
try std.testing.expectEqual(@as(usize, 2), pars.rest.len);
try std.testing.expectEqualStrings("secr", pars.rest[0]);
try std.testing.expectEqualStrings("init", pars.rest[1]);
}
test "--conf and --prof take the next arg, not a positional" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{ "--conf", "x.json", "doct", "--prof", "ci" });
try std.testing.expectEqualStrings("x.json", pars.conf.?);
try std.testing.expectEqualStrings("ci", pars.prof.?);
try std.testing.expectEqual(@as(usize, 1), pars.rest.len);
}
test "a value flag at the end has no value" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(ladz.Erro.FlagNeedValu, run(arna.allocator(), &.{ "doct", "--conf" }));
try std.testing.expectError(ladz.Erro.FlagNeedValu, run(arna.allocator(), &.{"--prof"}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
