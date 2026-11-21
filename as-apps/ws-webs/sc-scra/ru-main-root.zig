// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Entry point: run the command, print typed errors
// Flo: main > ct-ctrl-main.runMain > on error print what/why/fix > exit code 0-4
// I/O: argv (scra help) > stdout result, stderr error, exit 0-4
// Run: E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe status --json
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig"); const ctrl = @import("ct-ctrl-main.zig");
pub fn main(init: std.process.Init) void { const code: u8 = ctrl.runzMain(init) catch |err3| blkz: { const mesg = erro.mesg(err3); std.debug.print("error: {s}\n why: {s}\n fix: {s}\n", .{ mesg.what, mesg.whyz, mesg.fixz }); break :blkz erro.exitCode(err3); }; std.process.exit(code); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
