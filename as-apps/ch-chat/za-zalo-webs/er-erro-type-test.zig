// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for er-erro-type: exit codes and messages
// Flo: map errors > assert codes > assert messages non-empty
// I/O: error values > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig");
test "exit codes follow the ladder" { try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadUsage)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadJob)); try std.testing.expectEqual(@as(u8, 3), erro.exitCode(error.NoElem)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Halted)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.CapHit)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.QuietHrs)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NeedLogin)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NeedForce)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.BrowFail)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.OutOfMemory)); }
test "every listed error has a what-why-fix" { inline for (@typeInfo(erro.Erro).error_set.error_names.?) |name| { const err = @field(erro.Erro, name); const msg = erro.mesg(err); try std.testing.expect(msg.what.len > 0 and msg.whyz.len > 0 and msg.fixz.len > 0); } }
test "unknown error falls back to its name" { const msg = erro.mesg(error.OutOfMemory); try std.testing.expectEqualStrings("OutOfMemory", msg.whyz); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
