// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for undo of a finished run
// Flo: dry undo changes nothing > live undo restores byte for byte > twice = already done > later edit blocks unless forced > unknown id
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fk = @import("te-fake-repo.zig");
const tc = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const tk = @import("ut-iden-toke.zig");
const pl = @import("pl-plan-buil.zig");
const fl = @import("ru-flow-main.zig");
const un = @import("ru-flow-undo.zig");
const PAIRS = [_]tk.Pair{.{ .old = "cicd-stat", .new = "cics-stat" }};
const Env = struct { arena: std.heap.ArenaAllocator, fake: fk.Fake, ctxz: cx.Ctxz, wrtr: std.Io.Writer.Allocating, mck: mock.Mock };
fn setup(env: *Env, tmp: *std.testing.TmpDir) !void {
env.arena = std.heap.ArenaAllocator.init(std.testing.allocator);
const allo = env.arena.allocator();
env.fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
env.wrtr = .init(allo);
env.mck = .{};
env.ctxz = try tc.make(allo, &env.wrtr.writer, env.fake, .{}, &env.mck);
}
fn treeOf(env: *Env) ![]u8 {
const allo = env.arena.allocator();
return std.mem.concat(allo, u8, &.{ try fk.dump(allo, std.testing.io, env.fake.repo), "\n==\n", try fk.dump(allo, std.testing.io, env.fake.hubd) });
}
test "dry undo changes nothing, live undo restores every byte, a second undo says done" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const before = try treeOf(&env);
const resu = try fl.applyPlan(&env.ctxz, try pl.build(&env.ctxz, &PAIRS, .{}));
const after = try treeOf(&env);
try std.testing.expect(!std.mem.eql(u8, before, after));
const dry = try un.undoRun(&env.ctxz, resu.id, false, false);
try std.testing.expectEqual(@as(usize, 5), dry.back);
try std.testing.expectEqual(@as(usize, 2), dry.mved);
try std.testing.expect(!dry.done);
try std.testing.expectEqualStrings(after, try treeOf(&env));
const live = try un.undoRun(&env.ctxz, resu.id, true, false);
try std.testing.expect(live.done);
try std.testing.expectEqualStrings(before, try treeOf(&env));
const again = try un.undoRun(&env.ctxz, resu.id, true, false);
try std.testing.expect(again.done);
try std.testing.expectEqual(@as(usize, 0), again.back);
}
test "a file edited after the run blocks undo, force restores it anyway" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const resu = try fl.applyPlan(&env.ctxz, try pl.build(&env.ctxz, &PAIRS, .{}));
try fk.put(allo, std.testing.io, env.fake.repo, "do-note/no-note-docs.txt", "someone edited this later\n");
const blk = try un.undoRun(&env.ctxz, resu.id, true, false);
try std.testing.expectEqual(@as(usize, 1), blk.bloc);
try std.testing.expect(!blk.done);
try std.testing.expectEqualStrings("someone edited this later\n", try fk.get(allo, std.testing.io, env.fake.repo, "do-note/no-note-docs.txt"));
const frc = try un.undoRun(&env.ctxz, resu.id, true, true);
try std.testing.expect(frc.done);
try std.testing.expectEqualStrings(fk.DOCZ, try fk.get(allo, std.testing.io, env.fake.repo, "do-note/no-note-docs.txt"));
}
test "a state file recreated at the old name blocks the move back" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const resu = try fl.applyPlan(&env.ctxz, try pl.build(&env.ctxz, &PAIRS, .{}));
try fk.put(allo, std.testing.io, env.fake.hubd, "task-log/cicd-stat.log", "new run wrote this\n");
const blk = try un.undoRun(&env.ctxz, resu.id, true, false);
try std.testing.expectEqual(@as(usize, 1), blk.bloc);
try std.testing.expect(!blk.done);
try std.testing.expectEqualStrings("new run wrote this\n", try fk.get(allo, std.testing.io, env.fake.hubd, "task-log/cicd-stat.log"));
}
test "unknown run id" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
try std.testing.expectError(un.Erro.UnknownRun, un.undoRun(&env.ctxz, "19990101-000000", true, false));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
