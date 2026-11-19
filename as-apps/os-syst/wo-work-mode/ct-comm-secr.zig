// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo secr: secret-dir setup; lend waits for vault
// Flo: pick sub-command > init makes the per-device secret dir (owner-only on POSIX) > lend reports blocked
// I/O: Ctxz + "init"|"lend" > facts, exit 0 ok / 2 usage / 4 blocked. Never reads or prints a secret value
// ===================================================================
const std = @import("std");
const builtin = @import("builtin");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const perm: std.Io.Dir.Permissions = if (builtin.os.tag == .windows) .default_dir else @enumFromInt(0o700);
fn initDirz(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const dirz = try std.fs.path.join(ctxz.allo, &.{ ctxz.home, ctxz.conf.secr_home_loca });
if (std.Io.Dir.cwd().statFile(ctxz.iozz, dirz, .{})) |_| { try facts.append(ctxz.allo, cx.mkfa("init", .skip, try std.fmt.allocPrint(ctxz.allo, "exists: {s}", .{dirz}))); return; } else |_| {}
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("init", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would create {s}", .{dirz}))); return; }
_ = try std.Io.Dir.cwd().createDirPathStatus(ctxz.iozz, dirz, perm);
try facts.append(ctxz.allo, cx.mkfa("init", .okay, try std.fmt.allocPrint(ctxz.allo, "created {s}", .{dirz})));
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len == 0) return exit.Erro.Usag;
var facts: std.ArrayList(fcts.Fact) = .empty;
if (std.mem.eql(u8, args[0], "init")) try initDirz(ctxz, &facts) else if (std.mem.eql(u8, args[0], "lend")) try facts.append(ctxz.allo, cx.mkfa("lend", .bloc, "needs the vault: finish W1.3 first (human step)")) else return exit.Erro.Usag;
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
