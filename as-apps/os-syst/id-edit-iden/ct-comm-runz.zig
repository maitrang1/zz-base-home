// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: ie run: dry-run by default, --live applies, --live --force passes soft guards
// Flo: parse map > build plan > verdict > dry: print and stop > live: apply, print result > exit code
// I/O: args > text or JSON on stdout; files edited and state moved on --live
// Run: E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\ie.exe run cicd-stat=cics-stat --live
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const args = @import("ct-comm-args.zig");
const pl = @import("pl-plan-buil.zig");
const cp = @import("ct-comm-plan.zig");
const fl = @import("ru-flow-main.zig");
const stor = @import("st-runz-stor.zig");
pub fn comm(ctxz: *const cx.Ctxz, tail: []const []const u8) !exit.Code {
const req = try args.parse(ctxz, tail);
const plan = try pl.build(ctxz, req.pairs, req.opts);
const live = ctxz.ladd.live;
const verd = pl.verdict(plan, ctxz.ladd.forc);
const jsn = ctxz.ladd.json;
if (!live or verd != .okay) {
const code = if (!live) pl.verdict(plan, false) else verd;
if (jsn) { try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(ctxz.allo, try cp.outOf(ctxz, plan, "run", code, !live), .{})}); return code; }
try cp.show(ctxz, plan, code);
if (live) try ctxz.outw.print("run: blocked, nothing changed → exit 4\n", .{}) else try ctxz.outw.print("run: dry-run, nothing changed. add --live to apply → exit {d}\n", .{@intFromEnum(code)});
return code;
}
const resu = fl.applyPlan(ctxz, plan) catch |err| {
if (err == stor.Erro.Busy) { std.debug.print("ie: another run holds the lock in the data folder\nfix: wait for it, or after {d}s the lock counts as stale\n", .{ctxz.conf.lock_stal_seco}); return .bloc; }
return err;
};
if (jsn) {
var outj = try cp.outOf(ctxz, plan, "run", resu.code, false);
outj.run_id = resu.id;
outj.edited = resu.edit;
outj.moved = resu.mved;
outj.leftover = resu.left;
outj.hub = resu.hubz;
outj.msg = resu.note;
try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(ctxz.allo, outj, .{})});
return resu.code;
}
if (resu.code == .fail) { std.debug.print("ie: run {s} failed: {s}\n", .{ resu.id, resu.note }); try ctxz.outw.print("run {s}: failed, tree restored → exit 1\n", .{resu.id}); return .fail; }
try ctxz.outw.print("run {s}: {d} files edited · {d} state files moved · {d} leftover · hub: {s}\n", .{ resu.id, resu.edit, resu.mved, resu.left, if (resu.hubz.len == 0) "not checked" else resu.hubz });
if (resu.code == .find) try ctxz.outw.print("finding: check the leftovers or the hub, or undo: ie undo {s} --live\n", .{resu.id});
try ctxz.outw.print("run: done → exit {d}\n", .{@intFromEnum(resu.code)});
return resu.code;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
