// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Entry point: run the command, print typed errors
// Flo: main > ct-ctrl-main.runMain > on error print 2 lines (what - why / fix) > exit code 0-4
// I/O: argv (or-orac-webs help) > stdout result, stderr error, exit 0-4
// Run: E:\zz-base-home\as-apps\in-inte\or-orac-webs\zig-out\bin\or-orac-webs.exe status --json
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig"); const ctrl = @import("ct-ctrl-main.zig");
pub fn main(init: std.process.Init) void { const code: u8 = ctrl.runMain(init) catch |err| blk: { const mesg = erro.mesg(err); std.debug.print("error: {s} - {s}\nfix: {s}\n", .{ mesg.what, mesg.whyz, mesg.fixz }); break :blk erro.exitCode(err); }; std.process.exit(code); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
