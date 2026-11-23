// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for error messages and exit codes
// Flo: loop user-facing errors > check message fields > check exit code classes
// I/O: none (pure) > pass or fail
// Run: cd E:\zz-base-home\as-apps\in-inte\zr-zrow-webs && zig build test -Dfile=er-erro-type-test.zig
// ===================================================================
const std = @import("std"); const erro = @import("er-erro-type.zig");
test "every user-facing error has a non-generic message" { const list = [_]anyerror{ error.BadUsage, error.BadConfig, error.Drift, error.Halted, error.CapHit, error.QuietHour, error.NeedApprove, error.NeedLogin, error.Paused, error.NoBrowser, error.BrowFail, error.Timeout, error.NoElement, error.NoJob, error.Dupe, error.NoConsent, error.Locked, error.Unsafe, error.WaitTimeout, error.BadFlow, error.NoSecret }; for (list) |err| { const msg = erro.mesg(err); try std.testing.expect(msg.what.len > 0 and msg.whyz.len > 0 and msg.fixz.len > 0); try std.testing.expect(!std.mem.eql(u8, msg.what, "failed")); } }
test "exit codes: usage 2, drift 3, blocked 4, rest 1" { try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.BadUsage)); try std.testing.expectEqual(@as(u8, 2), erro.exitCode(error.NoSecret)); try std.testing.expectEqual(@as(u8, 3), erro.exitCode(error.NoElement)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.Halted)); try std.testing.expectEqual(@as(u8, 4), erro.exitCode(error.NeedApprove)); try std.testing.expectEqual(@as(u8, 1), erro.exitCode(error.Timeout)); }
test "messages name the zr command, never fb" { const msg = erro.mesg(error.BadUsage); try std.testing.expect(std.mem.find(u8, msg.fixz, "zr") != null); try std.testing.expect(std.mem.find(u8, msg.fixz, "fb") == null); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
