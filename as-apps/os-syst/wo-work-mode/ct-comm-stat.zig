// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo stat: read-only view of last wipz/backup/drill
// Flo: print version > read each state file > report its age or "none"
// I/O: Ctxz > facts on stdout, always exit 0 (it only reports)
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
pub const VERS = "0.1.0";
const NAME = [_][]const u8{ "wipz", "bkup", "bknt", "docs", "rels", "dril" };
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
_ = args;
var facts: std.ArrayList(fcts.Fact) = .empty;
try facts.append(ctxz.allo, cx.mkfa("vers", .okay, "wo " ++ VERS));
for (NAME) |name| {
const stam = ctxz.stamGet(name) orelse { try facts.append(ctxz.allo, cx.mkfa(name, .skip, "none yet")); continue; };
try facts.append(ctxz.allo, cx.mkfa(name, if (stam.okay) .okay else .skip, try std.fmt.allocPrint(ctxz.allo, "age {d}s{s}", .{ ctxz.nowz() - stam.when, if (stam.okay) "" else " (last run failed)" })));
}
_ = try ctxz.emit(facts.items);
return .okay;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
