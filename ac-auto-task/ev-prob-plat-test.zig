// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for OS process and sensor queries
// Flo: query own process > query nonsense > assert
// I/O: name + io > bool or null
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const modu = @import("ev-task-prob.zig");
const tszz = std.testing; const Prob = modu.Prob; const Kind = modu.Kind; const Cond = modu.Cond; const ArmzErro = modu.ArmzErro; const CF = modu.CF; const probArmz = modu.probArmz; const probTypeChec = modu.probTypeChec; const sizePars = modu.sizePars; const duraPars = modu.duraPars; const statPars = modu.statPars; const procRunn = modu.procRunn;
var test_iozz_impl = std.Io.Threaded.init_single_threaded; const iozz: std.Io = test_iozz_impl.io();
fn edge(prob: *Prob, read: Cond) bool { prob.poll_coun += 1; const prev = prob.last; prob.last = read; if (read != .onzz) return false; if (prev != .offz) return false; return true; }
test "proc sense: this very process is running, a nonsense name is not" { const myzz = if (builtin.os.tag == .windows) "test.exe" else "test"; if (procRunn(iozz, myzz)) |runn| { try tszz.expect(runn); } else { return error.SkipZigTest; } const ghos = procRunn(iozz, "definitely-not-a-real-process-xyz.exe") orelse return; try tszz.expect(!ghos); }
test "idle/power/disk sensors report unknown rather than lying when unreadable" { if (comptime builtin.os.tag == .windows) return error.SkipZigTest; var idle = try probArmz("idle", "5m"); try tszz.expectEqual(Cond.unkn, idle.idleSens(iozz)); try tszz.expect(idle.last_erro); var disk = try probArmz("disk", "/definitely-not-a-real-mount-xyz<1GB"); try tszz.expectEqual(Cond.unkn, disk.diskSens(iozz)); try tszz.expect(disk.last_erro); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
