// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for size and duration parse
// Flo: parse specs > assert exact values or null
// I/O: spec text > bytes or ms
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const modu = @import("ev-task-prob.zig");
const tszz = std.testing; const Prob = modu.Prob; const Kind = modu.Kind; const Cond = modu.Cond; const ArmzErro = modu.ArmzErro; const CF = modu.CF; const probArmz = modu.probArmz; const probTypeChec = modu.probTypeChec; const sizePars = modu.sizePars; const duraPars = modu.duraPars; const statPars = modu.statPars; const procRunn = modu.procRunn;
var test_iozz_impl = std.Io.Threaded.init_single_threaded; const iozz: std.Io = test_iozz_impl.io();
fn edge(prob: *Prob, read: Cond) bool { prob.poll_coun += 1; const prev = prob.last; prob.last = read; if (read != .onzz) return false; if (prev != .offz) return false; return true; }
test "sizePars: units are binary, and overflow is rejected" { try tszz.expectEqual(@as(?u64, 1024), sizePars("1k")); try tszz.expectEqual(@as(?u64, 1024), sizePars("1KB")); try tszz.expectEqual(@as(?u64, 512), sizePars("512")); try tszz.expectEqual(@as(?u64, 512), sizePars("512B")); try tszz.expectEqual(@as(?u64, 2 * 1024 * 1024 * 1024), sizePars("2GB")); try tszz.expectEqual(@as(?u64, null), sizePars("10ZB")); try tszz.expectEqual(@as(?u64, null), sizePars("GB")); try tszz.expectEqual(@as(?u64, null), sizePars("")); try tszz.expectEqual(@as(?u64, null), sizePars("99999999999999999999TB")); }
test "duraPars: bare number is minutes; zero is rejected" { try tszz.expectEqual(@as(?u64, 900_000), duraPars("15m")); try tszz.expectEqual(@as(?u64, 900_000), duraPars("15")); try tszz.expectEqual(@as(?u64, 90_000), duraPars("90s")); try tszz.expectEqual(@as(?u64, 7_200_000), duraPars("2h")); try tszz.expectEqual(@as(?u64, null), duraPars("0m")); try tszz.expectEqual(@as(?u64, null), duraPars("5d")); try tszz.expectEqual(@as(?u64, null), duraPars("abc")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
