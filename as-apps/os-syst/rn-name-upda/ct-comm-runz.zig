// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: rn runz OLD NEW: rename, fix refs, dry-run default
// Flo: check pair > dry-run prints the plan > live runs the flow > one-line result
// I/O: OLD NEW + --live/--force > text or JSON; exit 0 ok · 1 failed (rolled back) · 3 flagged or left · 4 blocked
// Run: E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe runz E:\proj\old E:\proj\new --live
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const scan = @import("ru-flow-scan.zig");
const plan = @import("ct-comm-plan.zig");
const flow = @import("ru-flow-main.zig");
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 2) return exit.Erro.Usag;
const old = try ctxz.absOf(args[0]);
const new = try ctxz.absOf(args[1]);
const bad = scan.checkPair(ctxz, old, new);
if (bad != .none) { std.debug.print("{s}", .{scan.badText(bad)}); return .fail; }
if (!ctxz.ladd.live) {
const code = try plan.render(ctxz, old, new, try scan.collect(ctxz, old, new));
if (!ctxz.ladd.json) try ctxz.outw.print("dry-run: nothing written. Add --live to apply.\n", .{});
return code;
}
const rsl = try flow.runFlow(ctxz, old, new, .{ .force = ctxz.ladd.forc });
if (ctxz.ladd.json) { try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(ctxz.allo, rsl, .{})}); return rsl.code; }
if (rsl.note.len > 0) { try ctxz.outw.print("failed {s}: {s} · rolled back, nothing changed\n", .{ rsl.id, rsl.note }); return rsl.code; }
try ctxz.outw.print("ok {s} · patched {d} refs in {d} files · renamed · left {d} · flagged {d}\nundo: rn undo {s} --live\n", .{ rsl.id, rsl.patched, rsl.files, rsl.left, rsl.flagd, rsl.id });
if (rsl.hint.len > 0) try ctxz.outw.print("note: {s}\n", .{rsl.hint});
return rsl.code;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
