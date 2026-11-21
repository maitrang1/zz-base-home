// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for er-erro-type: exit codes and messages
// Flo: map each error > assert code > assert message not empty
// I/O: error values > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig");
test "exit codes map 0-4" { try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadUsage)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BlockedHost)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadUrl)); try std.testing.expectEqual(@as(u8, 3), erro.exitCode(error.Drift)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Blocked)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.Fail)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.OutOfMemory)); }
test "every typed error has what-why-fix" { inline for (@typeInfo(erro.Erro).error_set.error_names.?) |nam2| { const mesg = erro.mesg(@field(erro.Erro, nam2)); try std.testing.expect(mesg.what.len > 0 and mesg.whyz.len > 0 and mesg.fixz.len > 0); try std.testing.expect(!std.mem.eql(u8, mesg.what, "failed") or std.mem.eql(u8, nam2, "Fail")); } }
test "unknown error shows its name" { try std.testing.expectEqualStrings("OutOfMemory", erro.mesg(error.OutOfMemory).whyz); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
