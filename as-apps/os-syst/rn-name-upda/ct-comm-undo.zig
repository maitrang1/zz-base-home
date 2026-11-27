// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: rn undo ID|last: restore a past run (dry-run default)
// Flo: pick id > run undo > print counts
// I/O: id + --live/--force > text or JSON; exit 0 ok · 1 no such run · 4 conflict (file changed since)
// Run: E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe undo last --live
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const stor = @import("st-runz-stor.zig");
const undo = @import("ru-flow-undo.zig");
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 1) return exit.Erro.Usag;
const id = if (std.mem.eql(u8, args[0], "last")) (try stor.idLast(ctxz) orelse { std.debug.print("rn: no runs yet. Nothing to undo.\n", .{}); return .fail; }) else args[0];
const rsl = undo.undoRun(ctxz, id, .{ .live = ctxz.ladd.live, .force = ctxz.ladd.forc }) catch |err| switch (err) {
undo.Erro.NoJournal => { std.debug.print("rn: no run named {s}. Run rn stat to see the last one.\n", .{id}); return .fail; },
undo.Erro.AlreadyUndone => { std.debug.print("rn: run {s} is already undone.\n", .{id}); return .fail; },
else => return err,
};
if (ctxz.ladd.json) { try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(ctxz.allo, rsl, .{})}); return rsl.code; }
if (rsl.code == .bloc) { try ctxz.outw.print("blocked {s}: {d} items changed since the run. Nothing undone. Add --force to overwrite them.\n", .{ id, rsl.conf }); return .bloc; }
try ctxz.outw.print("{s} {s} · restored {d} · already ok {d}{s}\n", .{ if (ctxz.ladd.live) "undone" else "dry-run", id, rsl.restd, rsl.skip, if (ctxz.ladd.live) "" else " · add --live to apply" });
return .okay;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
