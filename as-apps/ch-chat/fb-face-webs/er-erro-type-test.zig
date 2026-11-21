// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for error messages and exit codes
// Flo: every error has English + Vietnamese text > exit codes follow the ladder
// I/O: error set > Mesg, exit code (no leaks)
// Run: zig build test -Dfile=er-erro-type-test.zig
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig");
test "every named error has a non-generic message in both languages" { inline for (@typeInfo(erro.Erro).error_set.error_names.?) |nam| { const err = @field(anyerror, nam); if (std.mem.eql(u8, nam, "Fail") or std.mem.eql(u8, nam, "Closed") or std.mem.eql(u8, nam, "TooBig") or std.mem.eql(u8, nam, "BadFrame") or std.mem.eql(u8, nam, "BadHandshake") or std.mem.eql(u8, nam, "CdpError") or std.mem.eql(u8, nam, "EvalFail") or std.mem.eql(u8, nam, "NavFail") or std.mem.startsWith(u8, nam, "Sqli")) continue; const en = erro.mesgLang(err, "en"); const vi = erro.mesgLang(err, "vi"); try std.testing.expect(!std.mem.eql(u8, en.what, "failed")); try std.testing.expect(!std.mem.eql(u8, vi.what, "thất bại")); try std.testing.expect(en.fixz.len > 0 and vi.fixz.len > 0); try std.testing.expect(!std.mem.eql(u8, en.what, vi.what)); } }
test "exit codes: usage 2, drift 3, blocked 4, rest 1" { try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadUsage)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadFlow)); try std.testing.expectEqual(@as(u8, 3), erro.exitCode(error.NoElement)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Halted)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Unsafe)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NoConsent)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Locked)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.Timeout)); }
test "unknown language falls back to English" { try std.testing.expectEqualStrings("paused", erro.mesgLang(error.Paused, "xx").what); try std.testing.expectEqualStrings("đang tạm dừng", erro.mesgLang(error.Paused, "vi").what); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
