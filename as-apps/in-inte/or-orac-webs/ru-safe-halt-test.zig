// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the halt detector
// Flo: feed url, text and dialog samples > expect the right Halt kind or none
// I/O: none (pure) > pass or fail
// Run: cd E:\zz-base-home\as-apps\in-inte\or-orac-webs && zig build test -Dfile=ru-safe-halt-test.zig
// ===================================================================
const std = @import("std"); const halt = @import("ru-safe-halt.zig");
test "suspended account by url and text" { try std.testing.expectEqual(halt.Halt.checkpoint, halt.check("https://cloud.oracle.com/suspended", "", "").?); try std.testing.expectEqual(halt.Halt.checkpoint, halt.check("https://cloud.oracle.com/", "Your account has been suspended", "").?); }
test "captcha, 2FA, email code, blocked, warning on page text" { try std.testing.expectEqual(halt.Halt.captcha, halt.check("https://x/y", "Please verify you are human", "").?); try std.testing.expectEqual(halt.Halt.twofa, halt.check("https://x/y", "Enter the code from your Authenticator app", "").?); try std.testing.expectEqual(halt.Halt.emailcode, halt.check("https://x/y", "Enter the 6-digit code", "").?); try std.testing.expectEqual(halt.Halt.blocked, halt.check("https://x/y", "Access denied", "").?); try std.testing.expectEqual(halt.Halt.warning, halt.check("https://x/y", "We saw unusual activity", "").?); }
test "weak rate-limit phrases count only inside a dialog" { try std.testing.expect(halt.check("https://x/y", "Too many requests, try again later", "") == null); try std.testing.expectEqual(halt.Halt.ratelimit, halt.check("https://x/y", "", "Too many requests").?); }
test "classes: challenges need you, limits are unsafe" { try std.testing.expectEqual(halt.Class.needs, halt.classOf(.captcha)); try std.testing.expectEqual(halt.Class.needs, halt.classOf(.emailcode)); try std.testing.expectEqual(halt.Class.needs, halt.classOf(.twofa)); try std.testing.expectEqual(halt.Class.needs, halt.classOf(.logout)); try std.testing.expectEqual(halt.Class.unsafe, halt.classOf(.warning)); try std.testing.expectEqual(halt.Class.unsafe, halt.classOf(.blocked)); try std.testing.expectEqual(halt.Class.unsafe, halt.classOf(.ratelimit)); }
test "logout by login url or text, auth kinds" { try std.testing.expectEqual(halt.Halt.logout, halt.check("https://cloud.oracle.com/login?next=x", "", "").?); try std.testing.expectEqual(halt.Halt.logout, halt.check("https://cloud.oracle.com/", "Sign in to your account", "").?); try std.testing.expect(halt.isLogout(.logout)); try std.testing.expect(halt.isAuth(.emailcode)); try std.testing.expect(!halt.isAuth(.captcha)); }
test "normal pages are clear, only the first 6000 bytes are scanned" { try std.testing.expect(halt.check("https://cloud.oracle.com/settings/api-keys", "Your API keys: default. Create key.", "") == null); const allo = std.testing.allocator; const big = try allo.alloc(u8, 7000); defer allo.free(big); @memset(big, 'a'); @memcpy(big[6500..6521], "verify you are human."); try std.testing.expect(halt.check("https://x/y", big, "") == null); }
test "kind names for logs" { try std.testing.expectEqualStrings("captcha", halt.name(.captcha)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
