// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Entry point: run the command, print typed errors
// Flo: main > ct-ctrl-main.runMain > on error print 2 lines (what - why / fix) > exit code 0-4
// I/O: argv (fb-face-webs help) > stdout result, stderr error, exit 0-4
// Run: E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb-face-webs.exe status --json
// ===================================================================
const std = @import("std"); const logz = @import("lo-logz-line.zig"); const erro = @import("er-erro-type.zig"); const ctrl = @import("ct-ctrl-main.zig");
pub fn main(init: std.process.Init) void { logz.begin(init.io); const code: u8 = ctrl.runMain(init) catch |err| blk: { const mesg = erro.mesg(err); logz.logz("main", .erro, mesg.what, mesg.whyz, mesg.fixz); break :blk erro.exitCode(err); }; std.process.exit(code); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
