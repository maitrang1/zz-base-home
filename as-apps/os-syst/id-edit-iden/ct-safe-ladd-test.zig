// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for global flag parsing and the safety ladder
// Flo: defaults > each flag > flags anywhere > bad combos
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const ladz = @import("ct-safe-ladd.zig");
fn run(allo: std.mem.Allocator, args: []const []const u8) !ladz.Pars { return ladz.parse(allo, args); }
test "default is dry-run: nothing live" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{"plan"});
try std.testing.expect(!pars.ladd.live and !pars.ladd.forc and !pars.ladd.json);
try std.testing.expectEqual(@as(usize, 1), pars.rest.len);
try std.testing.expectEqualStrings("plan", pars.rest[0]);
try std.testing.expect(pars.conf == null);
}
test "--force without --live is refused, with --live accepted" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(ladz.Erro.ForcNeedLive, run(arna.allocator(), &.{ "runz", "--force" }));
const pars = try run(arna.allocator(), &.{ "--force", "runz", "--live" });
try std.testing.expect(pars.ladd.live and pars.ladd.forc);
}
test "flags work before, between and after positionals; positionals keep order" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{ "--json", "plan", "--live", "old", "new" });
try std.testing.expect(pars.ladd.json and pars.ladd.live);
try std.testing.expectEqual(@as(usize, 3), pars.rest.len);
try std.testing.expectEqualStrings("plan", pars.rest[0]);
try std.testing.expectEqualStrings("old", pars.rest[1]);
try std.testing.expectEqualStrings("new", pars.rest[2]);
}
test "--conf takes the next arg, not a positional" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{ "--conf", "x.json", "stat" });
try std.testing.expectEqualStrings("x.json", pars.conf.?);
try std.testing.expectEqual(@as(usize, 1), pars.rest.len);
}
test "a value flag at the end has no value" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(ladz.Erro.FlagNeedValu, run(arna.allocator(), &.{ "stat", "--conf" }));
try std.testing.expectError(ladz.Erro.FlagNeedValu, run(arna.allocator(), &.{"--conf"}));
}
test "empty args give an empty rest" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const pars = try run(arna.allocator(), &.{});
try std.testing.expectEqual(@as(usize, 0), pars.rest.len);
}
test "--dry-run with --live is refused, alone it is accepted" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(ladz.Erro.DryAndLive, run(arna.allocator(), &.{ "run", "--dry-run", "--live" }));
const pars = try run(arna.allocator(), &.{ "run", "--dry-run" });
try std.testing.expect(pars.ladd.dryz and !pars.ladd.live);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
