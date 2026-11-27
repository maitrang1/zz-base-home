// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the plan builder and its guards
// Flo: clean plan > each guard once > scope switches > verdict with and without force
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const pl = @import("pl-plan-buil.zig");
const tk = @import("ut-iden-toke.zig");
const fk = @import("te-fake-repo.zig");
const tc = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const exit = @import("ct-exit-code.zig");
const Env = struct { arena: std.heap.ArenaAllocator, fake: fk.Fake, ctxz: @import("ct-ctrl-ctxz.zig").Ctxz, wrtr: std.Io.Writer.Allocating, mck: mock.Mock };
fn guardOf(plan: pl.Plan, kind: []const u8) ?pl.Guard { for (plan.guards) |gua| if (std.mem.eql(u8, gua.kind, kind)) return gua; return null; }
fn setup(env: *Env, tmp: *std.testing.TmpDir) !void {
env.arena = std.heap.ArenaAllocator.init(std.testing.allocator);
const allo = env.arena.allocator();
env.fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
env.wrtr = .init(allo);
env.mck = .{};
env.ctxz = try tc.make(allo, &env.wrtr.writer, env.fake, .{}, &env.mck);
}
test "clean rename of a step id: hits in 5 files, 2 moves, only the lane guard" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const pairs = [_]tk.Pair{.{ .old = "cicd-stat", .new = "cics-stat" }};
const plan = try pl.build(&env.ctxz, &pairs, .{});
try std.testing.expectEqual(@as(usize, 5), plan.files.len);
try std.testing.expectEqual(@as(usize, 6), plan.hits);
try std.testing.expectEqual(@as(usize, 2), plan.moves.len);
try std.testing.expectEqual(@as(usize, 1), plan.guards.len);
try std.testing.expectEqualStrings("lane", plan.guards[0].kind);
try std.testing.expectEqual(exit.Code.bloc, pl.verdict(plan, false));
try std.testing.expectEqual(exit.Code.okay, pl.verdict(plan, true));
}
test "same lane, no state: fully clean, verdict okay" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const pairs = [_]tk.Pair{.{ .old = "fb-watc", .new = "fb-aliv" }};
const plan = try pl.build(&env.ctxz, &pairs, .{});
try std.testing.expectEqual(@as(usize, 0), plan.guards.len);
try std.testing.expectEqual(exit.Code.okay, pl.verdict(plan, false));
try std.testing.expectEqual(@as(usize, 1), plan.moves.len);
}
test "hard guards: unknown old id and existing new id, force never passes them" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const pairs = [_]tk.Pair{ .{ .old = "nope-nope", .new = "nu-nu" }, .{ .old = "fb-watc", .new = "home-docs" } };
const plan = try pl.build(&env.ctxz, &pairs, .{});
try std.testing.expect(guardOf(plan, "oldz_miss").?.hard);
try std.testing.expect(guardOf(plan, "newz_exis").?.hard);
try std.testing.expectEqual(exit.Code.bloc, pl.verdict(plan, true));
}
test "chain guard: a saved chain for a job id" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const pairs = [_]tk.Pair{.{ .old = "puls-15mi", .new = "puls-quar" }};
const plan = try pl.build(&env.ctxz, &pairs, .{});
try std.testing.expect(!guardOf(plan, "chain").?.hard);
try std.testing.expectEqual(@as(usize, 1), plan.moves.len);
}
test "state target exists: hard guard, no move" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
try fk.put(env.arena.allocator(), std.testing.io, env.fake.hubd, "task-log/cics-stat.log", "x");
const pairs = [_]tk.Pair{.{ .old = "cicd-stat", .new = "cics-stat" }};
const plan = try pl.build(&env.ctxz, &pairs, .{});
try std.testing.expect(guardOf(plan, "stat_exis").?.hard);
try std.testing.expectEqual(@as(usize, 1), plan.moves.len);
}
test "clash guard: a file named like the old id" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
try fk.put(env.arena.allocator(), std.testing.io, env.fake.repo, "x/fb-watc.txt", "hi");
const pairs = [_]tk.Pair{.{ .old = "fb-watc", .new = "fb-aliv" }};
const plan = try pl.build(&env.ctxz, &pairs, .{});
try std.testing.expect(!guardOf(plan, "clash").?.hard);
}
test "scope state: no repo walk, no job-file checks, only moves" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const pairs = [_]tk.Pair{.{ .old = "fb-watc", .new = "fb-aliv" }};
const plan = try pl.build(&env.ctxz, &pairs, .{ .scope = .state });
try std.testing.expectEqual(@as(usize, 0), plan.files.len);
try std.testing.expectEqual(@as(usize, 1), plan.moves.len);
try std.testing.expectEqual(@as(usize, 0), plan.guards.len);
}
test "scope repo: no moves, chain not checked; docs off drops the docs file" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const pairs = [_]tk.Pair{.{ .old = "cicd-stat", .new = "cicd-stax" }};
const plan = try pl.build(&env.ctxz, &pairs, .{ .scope = .repo, .docs = false });
try std.testing.expectEqual(@as(usize, 0), plan.moves.len);
try std.testing.expectEqual(@as(usize, 4), plan.files.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
