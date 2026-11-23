// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Spot ZenRows challenges, bans and logouts so the agent stops or waits
// Flo: lowercase url, page text, dialog text > match url parts > strong phrases on page text > weak phrases only inside dialogs > Halt kind > class (needs you or unsafe)
// I/O: url + page text + dialog/alert text (caller) > optional Halt kind, its Class (never bypassed, never retried blindly)
// ===================================================================
const std = @import("std"); const fld = @import("ut-text-fold.zig");
const CF = .{ .scan = 6000 };
pub const Halt = enum { checkpoint, captcha, twofa, warning, blocked, ratelimit, logout, overlay, emailcode };
pub const Class = enum { needs, unsafe };
const Rule = struct { kind: Halt, weak: bool, urlz: []const []const u8, text: []const []const u8 };
const RULES = [_]Rule{ .{ .kind = .checkpoint, .weak = false, .urlz = &.{ "/suspended", "/disabled" }, .text = &.{ "your account has been suspended", "your account is disabled", "your account has been disabled", "account suspended" } }, .{ .kind = .captcha, .weak = false, .urlz = &.{ "/captcha", "/recaptcha", "/cdn-cgi/challenge" }, .text = &.{ "verify you are human", "i'm not a robot", "complete the captcha", "checking your browser before", "just a moment" } }, .{ .kind = .twofa, .weak = false, .urlz = &.{ "/two-factor", "/2fa", "/mfa" }, .text = &.{ "two-factor authentication", "authenticator app", "enter the code from your authenticator", "2-step verification" } }, .{ .kind = .emailcode, .weak = false, .urlz = &.{ "/verify-email", "/verification" }, .text = &.{ "enter the 6-digit code", "we sent a code to", "check your email for a code", "verify your email" } }, .{ .kind = .blocked, .weak = false, .urlz = &.{}, .text = &.{ "access denied", "you have been blocked", "your api key has been banned", "api key banned", "ip address has been blocked" } }, .{ .kind = .warning, .weak = false, .urlz = &.{}, .text = &.{ "unusual activity", "suspicious activity detected", "violation of our terms" } }, .{ .kind = .ratelimit, .weak = true, .urlz = &.{}, .text = &.{ "too many requests", "rate limit exceeded", "slow down", "try again later" } }, .{ .kind = .logout, .weak = false, .urlz = &.{ "/login", "/signin", "/sign-in", "/log-in" }, .text = &.{ "sign in to your account", "log in to your account", "sign in to zenrows", "log in to zenrows", "your session has expired", "session expired" } } };
pub fn check(urlz: []const u8, text: []const u8, dlg: []const u8) ?Halt { var ubuf: [512]u8 = undefined; var tbuf: [CF.scan * 2]u8 = undefined; var dbuf: [CF.scan * 2]u8 = undefined; const lurl = fld.fold(&ubuf, urlz[0..@min(urlz.len, ubuf.len / 2)]); const body = fld.fold(&tbuf, text[0..@min(text.len, CF.scan)]); const dial = fld.fold(&dbuf, dlg[0..@min(dlg.len, CF.scan)]); for (RULES) |rul| { if (fld.hasAny(lurl, rul.urlz)) return rul.kind; } for (RULES) |rul| { if (!rul.weak and fld.hasAny(body, rul.text)) return rul.kind; } for (RULES) |rul| { if (fld.hasAny(dial, rul.text)) return rul.kind; } return null; }
pub fn classOf(kind: Halt) Class { return switch (kind) { .checkpoint, .captcha, .twofa, .emailcode, .logout, .overlay => .needs, .warning, .blocked, .ratelimit => .unsafe }; }
pub fn name(kind: Halt) []const u8 { return @tagName(kind); }
pub fn isLogout(kind: Halt) bool { return kind == .logout; }
pub fn isAuth(kind: Halt) bool { return kind == .logout or kind == .emailcode or kind == .twofa; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
