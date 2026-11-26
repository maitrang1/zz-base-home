// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for er-erro-type: exit codes and messages
// Flo: map errors > assert codes > assert messages non-empty
// I/O: error values > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig");
test "exit codes follow the ladder" { try std.testing.expectEqual(@as(u8, 3), erro.exitCode(error.Ambiguous)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadUsage)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadJob)); try std.testing.expectEqual(@as(u8, 3), erro.exitCode(error.NoElem)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Halted)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.CapHit)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.QuietHrs)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NeedLogin)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NeedForce)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.BrowFail)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.OutOfMemory)); }
test "every listed error has a what-why-fix" { inline for (@typeInfo(erro.Erro).error_set.error_names.?) |name| { const err = @field(erro.Erro, name); const msg = erro.mesg(err); try std.testing.expect(msg.what.len > 0 and msg.whyz.len > 0 and msg.fixz.len > 0); } }
test "unknown error falls back to its name" { const msg = erro.mesg(error.OutOfMemory); try std.testing.expectEqualStrings("OutOfMemory", msg.whyz); }
test "Vietnamese table covers every typed error with three different non-empty lines" { inline for (@typeInfo(erro.Erro).error_set.error_names.?) |name| { const err = @field(erro.Erro, name); const en = erro.mesg(err); const vn = @import("er-erro-viet.zig").mesg(err); try std.testing.expect(vn.what.len > 0 and vn.whyz.len > 0 and vn.fixz.len > 0); try std.testing.expect(!std.mem.eql(u8, en.what, vn.what)); } }
test "mesgAny follows the language switch" { const old = erro.viet; defer erro.viet = old; erro.viet = false; try std.testing.expectEqualStrings("bad usage", erro.mesgAny(error.BadUsage).what); erro.viet = true; try std.testing.expectEqualStrings("dùng sai lệnh", erro.mesgAny(error.BadUsage).what); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NoConsent)); }
test "bad config is a usage error (2) and a held lock is blocked (4)" { try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadConfig)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Busy)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
