// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Command-level tests: stat, plan, run, undo, JSON, usage errors, safety ladder
// Flo: plan is read-only > run dry changes nothing > run live applies > soft guard needs force > map file > undo last > bad input = usage
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fk = @import("te-fake-repo.zig");
const tc = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const exit = @import("ct-exit-code.zig");
const ladz = @import("ct-safe-ladd.zig");
const plan = @import("ct-comm-plan.zig");
const runz = @import("ct-comm-runz.zig");
const undo = @import("ct-comm-undo.zig");
const stat = @import("ct-comm-stat.zig");
const Env = struct { arena: std.heap.ArenaAllocator, fake: fk.Fake, ctxz: cx.Ctxz, wrtr: std.Io.Writer.Allocating, mck: mock.Mock };
fn setup(env: *Env, tmp: *std.testing.TmpDir, ladd: ladz.Ladd) !void {
env.arena = std.heap.ArenaAllocator.init(std.testing.allocator);
const allo = env.arena.allocator();
env.fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
env.wrtr = .init(allo);
env.mck = .{};
env.ctxz = try tc.make(allo, &env.wrtr.writer, env.fake, ladd, &env.mck);
}
fn treeOf(env: *Env) ![]u8 {
const allo = env.arena.allocator();
return std.mem.concat(allo, u8, &.{ try fk.dump(allo, std.testing.io, env.fake.repo), "\n==\n", try fk.dump(allo, std.testing.io, env.fake.hubd) });
}
fn outOf(env: *Env) []const u8 { return env.wrtr.written(); }
test "stat: counts and no open run" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{});
defer env.arena.deinit();
try std.testing.expectEqual(exit.Code.okay, try stat.comm(&env.ctxz, &.{}));
try std.testing.expect(std.mem.indexOf(u8, outOf(&env), "job files 2") != null);
try std.testing.expect(std.mem.indexOf(u8, outOf(&env), "last run none") != null);
try std.testing.expectError(exit.Erro.Usag, stat.comm(&env.ctxz, &.{"x"}));
}
test "plan is read-only: soft guard gives exit 4, a same-lane pair gives 0" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{});
defer env.arena.deinit();
const before = try treeOf(&env);
try std.testing.expectEqual(exit.Code.bloc, try plan.comm(&env.ctxz, &.{"cicd-stat=cics-stat"}));
try std.testing.expect(std.mem.indexOf(u8, outOf(&env), "[soft] lane") != null);
try std.testing.expectEqual(exit.Code.okay, try plan.comm(&env.ctxz, &.{"fb-watc=fb-aliv"}));
try std.testing.expectEqualStrings(before, try treeOf(&env));
}
test "plan --json prints one document with the core fields" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{ .json = true });
defer env.arena.deinit();
_ = try plan.comm(&env.ctxz, &.{"fb-watc=fb-aliv"});
const out = std.mem.trim(u8, outOf(&env), "\n");
try std.testing.expectEqual(@as(usize, 1), std.mem.count(u8, out, "\n") + 1);
const par = try std.json.parseFromSliceLeaky(std.json.Value, env.arena.allocator(), out, .{});
try std.testing.expect(par.object.get("ok").?.bool);
try std.testing.expectEqualStrings("plan", par.object.get("cmd").?.string);
try std.testing.expectEqual(@as(i64, 0), par.object.get("exit").?.integer);
try std.testing.expect(par.object.get("dry_run").?.bool);
}
test "run without --live changes nothing" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{});
defer env.arena.deinit();
const before = try treeOf(&env);
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&env.ctxz, &.{"fb-watc=fb-aliv"}));
try std.testing.expect(std.mem.indexOf(u8, outOf(&env), "dry-run, nothing changed") != null);
try std.testing.expectEqualStrings(before, try treeOf(&env));
}
test "run --live applies; soft guard needs --force; hard guard ignores force" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{ .live = true });
defer env.arena.deinit();
const before = try treeOf(&env);
try std.testing.expectEqual(exit.Code.bloc, try runz.comm(&env.ctxz, &.{"cicd-stat=cics-stat"}));
try std.testing.expectEqualStrings(before, try treeOf(&env));
env.ctxz.ladd.forc = true;
try std.testing.expectEqual(exit.Code.bloc, try runz.comm(&env.ctxz, &.{"nope-nope=nu-nu"}));
try std.testing.expectEqualStrings(before, try treeOf(&env));
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&env.ctxz, &.{"cicd-stat=cics-stat"}));
try std.testing.expect(!std.mem.eql(u8, before, try treeOf(&env)));
}
test "--map file works and undo last restores the tree" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{ .live = true });
defer env.arena.deinit();
const allo = env.arena.allocator();
try fk.put(allo, std.testing.io, env.fake.tena, "m.txt", "# map\nfb-watc = fb-aliv\nscra-raws -> scra-rawz\n");
const mpath = try std.fs.path.join(allo, &.{ env.fake.tena, "m.txt" });
const before = try treeOf(&env);
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&env.ctxz, &.{ "--map", mpath }));
try std.testing.expect(std.mem.indexOf(u8, try fk.get(allo, std.testing.io, env.fake.repo, "ac-auto-task/aa-auto-task-wi01.json"), "scra-rawz") != null);
try std.testing.expectEqual(exit.Code.okay, try undo.comm(&env.ctxz, &.{"last"}));
try std.testing.expectEqualStrings(before, try treeOf(&env));
try std.testing.expectEqual(exit.Code.okay, try stat.comm(&env.ctxz, &.{}));
try std.testing.expect(std.mem.indexOf(u8, outOf(&env), "last run 20231114-221320: rolled") != null);
}
test "undo dry-run by default; unknown run is usage; no run is blocked" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{});
defer env.arena.deinit();
try std.testing.expectEqual(exit.Code.bloc, try undo.comm(&env.ctxz, &.{"last"}));
try std.testing.expectEqual(exit.Code.usag, try undo.comm(&env.ctxz, &.{"19990101-000000"}));
try std.testing.expectError(exit.Erro.Usag, undo.comm(&env.ctxz, &.{}));
}
test "usage errors: bad pair, same ids, unknown flag, bad scope, missing map" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{});
defer env.arena.deinit();
for ([_][]const []const u8{ &.{"nopair"}, &.{"a=a"}, &.{"--zzz"}, &.{ "--scope", "x" }, &.{"--map"}, &.{ "--map", "/no/such/file" }, &.{}, &.{ "a-b=c d" } }) |argz| try std.testing.expectError(exit.Erro.Usag, plan.comm(&env.ctxz, argz));
}
test "scope state moves only state files; --no-docs skips docs" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{ .live = true });
defer env.arena.deinit();
const allo = env.arena.allocator();
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&env.ctxz, &.{ "fb-watc=fb-aliv", "--scope", "state" }));
try std.testing.expect(fk.has(allo, std.testing.io, env.fake.hubd, "task-log/fb-aliv.log"));
try std.testing.expect(std.mem.indexOf(u8, try fk.get(allo, std.testing.io, env.fake.repo, "ac-auto-task/aa-auto-task-wi01.json"), "fb-watc") != null);
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&env.ctxz, &.{ "scra-raws=scra-rawz", "--no-docs" }));
}
test "an open (never finished) run blocks the next live run until it is undone" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp, .{ .live = true });
defer env.arena.deinit();
const allo = env.arena.allocator();
try fk.put(allo, std.testing.io, env.fake.tena, "as-apps/os-syst/id-edit-iden/jour/19990101-000000.jsonl", "{\"op\":\"open\"}\n");
const before = try treeOf(&env);
try std.testing.expectEqual(exit.Code.bloc, try runz.comm(&env.ctxz, &.{"fb-watc=fb-aliv"}));
try std.testing.expectEqualStrings(before, try treeOf(&env));
try std.testing.expectEqual(exit.Code.find, try stat.comm(&env.ctxz, &.{}));
env.ctxz.ladd.forc = true;
try std.testing.expectEqual(exit.Code.okay, try undo.comm(&env.ctxz, &.{"19990101-000000"}));
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&env.ctxz, &.{"fb-watc=fb-aliv"}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
