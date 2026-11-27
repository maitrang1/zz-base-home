// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: ie plan: show what a rename would touch (read-only); also the printer run reuses
// Flo: parse map > build plan > print pairs, files, moves, guards > exit okay or blocked
// I/O: args > text or JSON on stdout; nothing written
// Run: E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe plan cicd-stat=cics-stat
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const args = @import("ct-comm-args.zig");
const pl = @import("pl-plan-buil.zig");
const FileJ = struct { path: []const u8, kind: []const u8, hits: usize, line: usize };
const MoveJ = struct { from: []const u8, to: []const u8 };
const GuarJ = struct { kind: []const u8, hard: bool, id: []const u8, note: []const u8 };
const PairJ = struct { old: []const u8, new: []const u8 };
const Outj = struct { ok: bool, cmd: []const u8, exit: u8, dry_run: bool, scope: []const u8, docs: bool, hits: usize, pairs: []const PairJ, files: []const FileJ, moves: []const MoveJ, guards: []const GuarJ, unresolved: usize, run_id: []const u8 = "", edited: usize = 0, moved: usize = 0, leftover: usize = 0, hub: []const u8 = "", msg: []const u8 = "" };
pub fn outOf(ctxz: *const cx.Ctxz, plan: pl.Plan, cmd: []const u8, code: exit.Code, dry: bool) !Outj {
const allo = ctxz.allo;
const pairs = try allo.alloc(PairJ, plan.pairs.len);
for (plan.pairs, 0..) |pair, indx| pairs[indx] = .{ .old = pair.old, .new = pair.new };
const files = try allo.alloc(FileJ, plan.files.len);
for (plan.files, 0..) |item, indx| files[indx] = .{ .path = item.path, .kind = @tagName(item.kind), .hits = item.hits, .line = item.line };
const moves = try allo.alloc(MoveJ, plan.moves.len);
for (plan.moves, 0..) |item, indx| moves[indx] = .{ .from = item.from, .to = item.to };
const guards = try allo.alloc(GuarJ, plan.guards.len);
for (plan.guards, 0..) |item, indx| guards[indx] = .{ .kind = item.kind, .hard = item.hard, .id = item.iden, .note = item.note };
return .{ .ok = code == .okay, .cmd = cmd, .exit = @intFromEnum(code), .dry_run = dry, .scope = @tagName(plan.opts.scope), .docs = plan.opts.docs, .hits = plan.hits, .pairs = pairs, .files = files, .moves = moves, .guards = guards, .unresolved = plan.unre.len };
}
pub fn show(ctxz: *const cx.Ctxz, plan: pl.Plan, code: exit.Code) !void {
const outw = ctxz.outw;
try outw.print("scope {s} · docs {s} · {d} pair(s)\n", .{ @tagName(plan.opts.scope), if (plan.opts.docs) "on" else "off", plan.pairs.len });
for (plan.pairs) |pair| try outw.print("  {s} → {s}\n", .{ pair.old, pair.new });
try outw.print("files {d} · hits {d}\n", .{ plan.files.len, plan.hits });
for (plan.files) |item| try outw.print("  {s}:{d} ×{d} ({s})\n", .{ item.path, item.line, item.hits, @tagName(item.kind) });
try outw.print("state moves {d}\n", .{plan.moves.len});
for (plan.moves) |item| try outw.print("  {s} → {s}\n", .{ item.from, item.to });
try outw.print("guards {d}\n", .{plan.guards.len});
for (plan.guards) |item| try outw.print("  [{s}] {s} {s}: {s}\n", .{ if (item.hard) "hard" else "soft", item.kind, item.iden, item.note });
if (code == .bloc) {
var hard = false;
for (plan.guards) |item| if (item.hard) { hard = true; };
try outw.print("blocked: {s}\n", .{if (hard) "fix the hard guards (force cannot pass them)" else "soft guards only: add --live --force to go on"});
}
}
pub fn comm(ctxz: *const cx.Ctxz, tail: []const []const u8) !exit.Code {
const req = try args.parse(ctxz, tail);
const plan = try pl.build(ctxz, req.pairs, req.opts);
const code = pl.verdict(plan, false);
if (ctxz.ladd.json) { try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(ctxz.allo, try outOf(ctxz, plan, "plan", code, true), .{})}); return code; }
try show(ctxz, plan, code);
try ctxz.outw.print("plan: {d} files · {d} hits · {d} moves · {d} guards → exit {d}\n", .{ plan.files.len, plan.hits, plan.moves.len, plan.guards.len, @intFromEnum(code) });
return code;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
