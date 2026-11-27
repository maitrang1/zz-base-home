// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: ie undo: put a past run back (dry-run by default)
// Flo: pick run id or "last" > undo from the journal > print counts > exit okay or blocked
// I/O: args > text or JSON on stdout; files restored on --live
// Run: E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe undo last --live
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const stor = @import("st-runz-stor.zig");
const un = @import("ru-flow-undo.zig");
const Outj = struct { ok: bool, cmd: []const u8, exit: u8, dry_run: bool, run_id: []const u8, restored: usize, moved_back: usize, skipped: usize, blocked: usize, done: bool };
pub fn comm(ctxz: *const cx.Ctxz, tail: []const []const u8) !exit.Code {
if (tail.len != 1) return exit.Erro.Usag;
const id: []const u8 = if (std.mem.eql(u8, tail[0], "last")) (try stor.idLast(ctxz)) orelse { std.debug.print("ie: no run to undo\n", .{}); return .bloc; } else tail[0];
const live = ctxz.ladd.live;
const lkid = if (live) try stor.idNew(ctxz) else "";
if (live) stor.lockTake(ctxz, lkid) catch |err| {
if (err == stor.Erro.Busy) { std.debug.print("ie: another run holds the lock in the data folder\nfix: wait for it, or after {d}s the lock counts as stale\n", .{ctxz.conf.lock_stal_seco}); return .bloc; }
return err;
};
defer if (live) stor.lockFree(ctxz, lkid);
const urs = un.undoRun(ctxz, id, live, ctxz.ladd.forc) catch |err| {
if (err == un.Erro.UnknownRun) { std.debug.print("ie: no journal for run {s}\nfix: ie stat shows the last run id\n", .{id}); return .usag; }
return err;
};
const code: exit.Code = if (urs.bloc > 0) .bloc else .okay;
if (ctxz.ladd.json) {
const outj: Outj = .{ .ok = code == .okay, .cmd = "undo", .exit = @intFromEnum(code), .dry_run = !live, .run_id = id, .restored = urs.back, .moved_back = urs.mved, .skipped = urs.skip, .blocked = urs.bloc, .done = urs.done };
try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(ctxz.allo, outj, .{})});
return code;
}
if (urs.done and urs.back == 0 and urs.mved == 0) { try ctxz.outw.print("undo {s}: already rolled back → exit 0\n", .{id}); return .okay; }
try ctxz.outw.print("undo {s}: {d} files {s} · {d} state files moved back · {d} skipped · {d} blocked\n", .{ id, urs.back, if (live) "restored" else "to restore", urs.mved, urs.skip, urs.bloc });
if (urs.bloc > 0) try ctxz.outw.print("blocked: a file changed after the run, or an old-name file exists. fix it, or add --force for edits\n", .{});
if (!live) try ctxz.outw.print("undo: dry-run, nothing changed. add --live to apply\n", .{});
return code;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
