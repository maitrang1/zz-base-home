// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build the rename plan: file hits, state moves, guards
// Flo: check ids against the job files > walk the repo > list state/log moves > raise guards (hard never passes, soft passes with --force) > verdict
// I/O: Ctxz + Pair list + Opts > Plan; Plan + force > exit code okay or bloc
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
const tk = @import("ut-iden-toke.zig");
const jz = @import("tk-jobz-read.zig");
const hub = @import("tk-hubz-conf.zig");
const wk = @import("se-scan-walk.zig");
pub const Scope = enum { all, repo, state };
pub const Opts = struct { scope: Scope = .all, docs: bool = true };
pub const Guard = struct { kind: []const u8, hard: bool, iden: []const u8, note: []const u8 };
pub const Move = struct { from: []const u8, to: []const u8 };
pub const Plan = struct { pairs: []const tk.Pair, opts: Opts, files: []const wk.Fhit, moves: []const Move, guards: []const Guard, hits: usize, wst: wk.Wstat, hubz: hub.Hubz, unre: []const []const u8 };
const Slot = struct { dirz: []const u8, suff: []const u8 };
const SLOTS = [_]Slot{ .{ .dirz = "task-state", .suff = ".last" }, .{ .dirz = "task-state", .suff = ".chain" }, .{ .dirz = "task-state", .suff = ".done" }, .{ .dirz = "task-log", .suff = ".log" } };
pub fn existz(ctxz: *const cx.Ctxz, path: []const u8) bool { return if (std.Io.Dir.cwd().statFile(ctxz.iozz, path, .{})) |_| true else |_| false; }
fn slotPath(ctxz: *const cx.Ctxz, hubd: []const u8, slot: Slot, iden: []const u8) ![]u8 { return std.fs.path.join(ctxz.allo, &.{ hubd, slot.dirz, try std.fmt.allocPrint(ctxz.allo, "{s}{s}", .{ iden, slot.suff }) }); }
fn guardAdd(ctxz: *const cx.Ctxz, list: *std.ArrayList(Guard), kind: []const u8, hard: bool, iden: []const u8, note: []const u8) !void { try list.append(ctxz.allo, .{ .kind = kind, .hard = hard, .iden = iden, .note = note }); }
pub fn confOf(ctxz: *const cx.Ctxz, opts: Opts) cfgz.Conf { var conf = ctxz.conf; if (!opts.docs) conf.scan_docs_on = false; return conf; }
pub fn build(ctxz: *const cx.Ctxz, pairs: []const tk.Pair, opts: Opts) !Plan {
const allo = ctxz.allo;
const conf = confOf(ctxz, opts);
const jobs = try jz.loadAll(allo, ctxz.iozz, ctxz.repo, conf);
const hubz = try hub.load(allo, ctxz.iozz, conf, ctxz.repo, ctxz.home);
var guards: std.ArrayList(Guard) = .empty;
var moves: std.ArrayList(Move) = .empty;
for (pairs) |pair| {
if (opts.scope != .state) {
if (!jz.hasIden(jobs, pair.old)) try guardAdd(ctxz, &guards, "oldz_miss", true, pair.old, "not a job id or chain step in any job file");
if (jz.hasIden(jobs, pair.new)) try guardAdd(ctxz, &guards, "newz_exis", true, pair.new, "already a job id or chain step");
}
const lold = hubz.laneOf(pair.old);
const lnew = hubz.laneOf(pair.new);
if (!std.mem.eql(u8, lold, lnew)) try guardAdd(ctxz, &guards, "lane", false, pair.old, try std.fmt.allocPrint(allo, "lock lane changes: '{s}' to '{s}'", .{ lold, lnew }));
if (opts.scope == .repo or hubz.data.len == 0) continue;
const chai = try slotPath(ctxz, hubz.data, SLOTS[1], pair.old);
if (existz(ctxz, chai)) try guardAdd(ctxz, &guards, "chain", false, pair.old, "a chain run is saved: wait for it, or force");
for (SLOTS) |slot| {
const from = try slotPath(ctxz, hubz.data, slot, pair.old);
if (!existz(ctxz, from)) continue;
const toto = try slotPath(ctxz, hubz.data, slot, pair.new);
if (existz(ctxz, toto)) { try guardAdd(ctxz, &guards, "stat_exis", true, pair.new, try std.fmt.allocPrint(allo, "{s}{s} already exists", .{ slot.dirz, slot.suff })); continue; }
try moves.append(allo, .{ .from = from, .to = toto });
}
}
var outc: wk.Outc = .{};
if (opts.scope != .state) try wk.walk(allo, ctxz.gpaz, ctxz.iozz, conf, ctxz.repo, pairs, &outc);
for (outc.clash.items) |item| try guardAdd(ctxz, &guards, "clash", false, item.iden, item.path);
var hits: usize = 0;
for (outc.files.items) |item| hits += item.hits;
const unre = try jz.unresolved(allo, ctxz.iozz, ctxz.repo, conf, try jz.calls(allo, jobs));
return .{ .pairs = pairs, .opts = opts, .files = outc.files.items, .moves = moves.items, .guards = guards.items, .hits = hits, .wst = outc.wst, .hubz = hubz, .unre = unre };
}
pub fn verdict(plan: Plan, forc: bool) exit.Code {
for (plan.guards) |guar| if (guar.hard or !forc) return .bloc;
return .okay;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
