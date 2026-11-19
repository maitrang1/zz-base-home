// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo conf: print the settings wo is using
// Flo: serialize Conf as indented JSON > stdout
// I/O: Ctxz > JSON on stdout, exit 0
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
_ = args;
try std.json.Stringify.value(ctxz.conf, .{ .whitespace = .indent_2 }, ctxz.outw);
try ctxz.outw.writeAll("\n");
return .okay;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
