// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo-work-mode kill: run kill-switch steps from config
// Flo: read steps from config > dry-run lists them > --live runs each, never stops early > emit facts
// I/O: Ctxz + kill_step_list > one fact per step, exit 0 all ok / 1 any failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
_ = args;
var facts: std.ArrayList(fcts.Fact) = .empty;
if (ctxz.conf.kill_step_list.len == 0) { try facts.append(ctxz.allo, cx.mkfa("kill", .bloc, "kill_step_list is empty")); return ctxz.emit(facts.items); }
for (ctxz.conf.kill_step_list, 0..) |argv, indx| {
const name = try std.fmt.allocPrint(ctxz.allo, "step{d}", .{indx + 1});
if (argv.len == 0) { try facts.append(ctxz.allo, cx.mkfa(name, .fail, "empty step")); continue; }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa(name, .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would run {s}", .{try std.mem.join(ctxz.allo, " ", argv)}))); continue; }
_ = try ctxz.step(&facts, name, argv, &.{});
}
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
