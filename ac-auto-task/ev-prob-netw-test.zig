// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for HTTP status line parse
// Flo: feed status lines > assert code or null
// I/O: head text > status code
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const modu = @import("ev-task-prob.zig");
const tszz = std.testing; const Prob = modu.Prob; const Kind = modu.Kind; const Cond = modu.Cond; const ArmzErro = modu.ArmzErro; const CF = modu.CF; const probArmz = modu.probArmz; const probTypeChec = modu.probTypeChec; const sizePars = modu.sizePars; const duraPars = modu.duraPars; const statPars = modu.statPars; const procRunn = modu.procRunn;
var test_iozz_impl = std.Io.Threaded.init_single_threaded; const iozz: std.Io = test_iozz_impl.io();
fn edge(prob: *Prob, read: Cond) bool { prob.poll_coun += 1; const prev = prob.last; prob.last = read; if (read != .onzz) return false; if (prev != .offz) return false; return true; }
test "statPars reads the code out of a status line" { try tszz.expectEqual(@as(?u16, 200), statPars("HTTP/1.1 200 OK\r\n")); try tszz.expectEqual(@as(?u16, 404), statPars("HTTP/1.1 404 Not Found\r\n")); try tszz.expectEqual(@as(?u16, 503), statPars("HTTP/1.0 503 Service Unavailable\r\n")); try tszz.expectEqual(@as(?u16, null), statPars("garbage")); try tszz.expectEqual(@as(?u16, null), statPars("HTTP/1.1 xx OK")); try tszz.expectEqual(@as(?u16, null), statPars("")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
