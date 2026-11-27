// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for apply, rollback on every fault step, drift, dangling, lock
// Flo: happy path > every injected failure restores the tree byte for byte > drift > dangling > lock busy/stale > hub verdict
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
const tick = @import("ut-faul-tick.zig");
const exit = @import("ct-exit-code.zig");
const osys = @import("ut-osys-adap.zig");
const CURL = if (osys.wind) "curl.exe" else "curl";
const PAIRS = [_]tk.Pair{.{ .old = "cicd-stat", .new = "cics-stat" }};
const Env = struct { arena: std.heap.ArenaAllocator, fake: fk.Fake, ctxz: cx.Ctxz, wrtr: std.Io.Writer.Allocating, mck: mock.Mock, tck: tick.Tick };
fn setup(env: *Env, tmp: *std.testing.TmpDir) !void {
env.arena = std.heap.ArenaAllocator.init(std.testing.allocator);
const allo = env.arena.allocator();
env.fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
env.wrtr = .init(allo);
env.mck = .{};
env.tck = .{};
env.ctxz = try tc.make(allo, &env.wrtr.writer, env.fake, .{}, &env.mck);
}
fn treeOf(env: *Env) ![]u8 {
const allo = env.arena.allocator();
const left = try fk.dump(allo, std.testing.io, env.fake.repo);
const righ = try fk.dump(allo, std.testing.io, env.fake.hubd);
return std.mem.concat(allo, u8, &.{ left, "\n==\n", righ });
}
test "happy path: every file edited, state moved, the rest untouched" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.okay, resu.code);
try std.testing.expectEqual(@as(usize, 5), resu.edit);
try std.testing.expectEqual(@as(usize, 2), resu.mved);
try std.testing.expectEqual(@as(usize, 0), resu.left);
const wi = try fk.get(allo, std.testing.io, env.fake.repo, "ac-auto-task/aa-auto-task-wi01.json");
try std.testing.expect(std.mem.indexOf(u8, wi, "\"cics-stat\"") != null and std.mem.indexOf(u8, wi, "cicd-stat") == null);
const doc = try fk.get(allo, std.testing.io, env.fake.repo, "do-note/no-note-docs.txt");
try std.testing.expectEqualStrings("jobs: cics-stat runs every 15m; cicd-stat2 is another; see cics-stat.\n", doc);
try std.testing.expectEqualStrings(fk.DOCZ, try fk.get(allo, std.testing.io, env.fake.repo, "do-note/UPDATE.md"));
try std.testing.expectEqualStrings(fk.DOCZ, try fk.get(allo, std.testing.io, env.fake.repo, "zz-dele-auto/old.txt"));
try std.testing.expectEqualStrings("cicd-stat history stays\n", try fk.get(allo, std.testing.io, env.fake.hubd, "history.txt"));
try std.testing.expect(fk.has(allo, std.testing.io, env.fake.hubd, "task-state/cics-stat.last"));
try std.testing.expect(!fk.has(allo, std.testing.io, env.fake.hubd, "task-state/cicd-stat.last"));
try std.testing.expect(fk.has(allo, std.testing.io, env.fake.hubd, "task-log/cics-stat.log"));
try std.testing.expect(fk.has(allo, std.testing.io, env.fake.hubd, "task-log/fb-watc.log"));
}
test "every injected fault step rolls the tree back byte for byte" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
const before = try treeOf(&env);
const total = plan.files.len + plan.moves.len;
var left: usize = 0;
while (left < total) : (left += 1) {
env.tck = .{ .left = left };
env.ctxz.faul = &env.tck;
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.fail, resu.code);
try std.testing.expect(std.mem.indexOf(u8, resu.note, "rolled back") != null);
try std.testing.expectEqualStrings(before, try treeOf(&env));
}
}
test "drift: a file changed after the plan stops the run and rolls back" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
try fk.put(allo, std.testing.io, env.fake.repo, "do-note/no-note-docs.txt", "cicd-stat edited in between\n");
const before = try treeOf(&env);
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.fail, resu.code);
try std.testing.expect(std.mem.indexOf(u8, resu.note, "Drift") != null);
try std.testing.expectEqualStrings(before, try treeOf(&env));
}
test "dangling: job file renamed but the dispatchers were skipped, run rolls back" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
env.ctxz.conf.scan_skip_name = &.{ "ba-cmds-wind.bat", "sh-cmds-linu.sh" };
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
const before = try treeOf(&env);
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.fail, resu.code);
try std.testing.expect(std.mem.indexOf(u8, resu.note, "Dangling") != null);
try std.testing.expectEqualStrings(before, try treeOf(&env));
}
test "UTF-16 file keeps its BOM and encoding" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const wide = [_]u8{ 0xFF, 0xFE, 'c', 0, 'i', 0, 'c', 0, 'd', 0, '-', 0, 's', 0, 't', 0, 'a', 0, 't', 0 };
try fk.put(allo, std.testing.io, env.fake.repo, "x/wide.bat", &wide);
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.okay, resu.code);
const got = try fk.get(allo, std.testing.io, env.fake.repo, "x/wide.bat");
const want = [_]u8{ 0xFF, 0xFE, 'c', 0, 'i', 0, 'c', 0, 's', 0, '-', 0, 's', 0, 't', 0, 'a', 0, 't', 0 };
try std.testing.expectEqualSlices(u8, &want, got);
}
test "two pairs in one run, both applied" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const two = [_]tk.Pair{ .{ .old = "cicd-stat", .new = "cics-stat" }, .{ .old = "scra-raws", .new = "scra-rawz" } };
const plan = try pl.build(&env.ctxz, &two, .{});
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.okay, resu.code);
const wi = try fk.get(allo, std.testing.io, env.fake.repo, "ac-auto-task/aa-auto-task-wi01.json");
try std.testing.expect(std.mem.indexOf(u8, wi, "scra-rawz") != null and std.mem.indexOf(u8, wi, "cics-stat") != null);
}
test "lock: a fresh lock blocks, a stale one is moved aside" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
const allo = env.arena.allocator();
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
const stor = @import("st-runz-stor.zig");
const pth = try stor.pthsOf(&env.ctxz, "x");
try std.Io.Dir.cwd().createDirPath(std.testing.io, pth.data);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = pth.lock, .data = "other" });
const fresh = fl.applyPlan(&env.ctxz, plan);
try std.testing.expectError(stor.Erro.Busy, fresh);
const FAR = struct { fn nowz(iozz: std.Io) i64 { _ = iozz; return 4_000_000_000; } };
env.ctxz.nowf = FAR.nowz;
const resu = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.okay, resu.code);
try std.testing.expect(!fk.has(allo, std.testing.io, pth.data, "run.lock"));
}
test "hub verdict: reload seen = okay, old id still listed = find, files stay changed" {
const OLDZ = "{\"ok\":true,\"fileOk\":true,\"armErrorCount\":0,\"tasks\":[{\"id\":\"puls-15mi\",\"ids\":[\"fb-watc\",\"cicd-stat\"]}]}";
const NEWZ = "{\"ok\":true,\"fileOk\":true,\"armErrorCount\":0,\"tasks\":[{\"id\":\"puls-15mi\",\"ids\":[\"fb-watc\",\"cics-stat\"]}]}";
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var env: Env = undefined;
try setup(&env, &tmp);
defer env.arena.deinit();
env.mck.rule = &.{ .{ .pref = &.{CURL}, .outz = OLDZ, .maxz = 1 }, .{ .pref = &.{CURL}, .outz = NEWZ } };
const plan = try pl.build(&env.ctxz, &PAIRS, .{});
const good = try fl.applyPlan(&env.ctxz, plan);
try std.testing.expectEqual(exit.Code.okay, good.code);
try std.testing.expect(std.mem.indexOf(u8, good.hubz, "reloaded") != null);
var tmp2 = std.testing.tmpDir(.{});
defer tmp2.cleanup();
var env2: Env = undefined;
try setup(&env2, &tmp2);
defer env2.arena.deinit();
env2.mck.rule = &.{.{ .pref = &.{CURL}, .outz = OLDZ }};
const plan2 = try pl.build(&env2.ctxz, &PAIRS, .{});
const bad = try fl.applyPlan(&env2.ctxz, plan2);
try std.testing.expectEqual(exit.Code.find, bad.code);
try std.testing.expect(std.mem.indexOf(u8, bad.hubz, "cicd-stat") != null);
try std.testing.expect(!fk.has(env2.arena.allocator(), std.testing.io, env2.fake.hubd, "task-log/cicd-stat.log"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
