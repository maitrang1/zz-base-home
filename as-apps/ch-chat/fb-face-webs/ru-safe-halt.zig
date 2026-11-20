// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Spot Facebook challenges and logouts so the agent stops
// Flo: lowercase url and page text > match url parts > match phrases (EN + VI) > Halt kind or none
// I/O: url + visible page text (caller) > optional Halt kind (never bypassed, never retried)
// ===================================================================
const std = @import("std"); const fld = @import("ut-text-fold.zig");
const CF = .{ .scan = 6000 };
pub const Halt = enum { checkpoint, captcha, twofa, warning, blocked, ratelimit, logout };
const Rule = struct { kind: Halt, urlz: []const []const u8, text: []const []const u8 };
const RULES = [_]Rule{ .{ .kind = .checkpoint, .urlz = &.{ "/checkpoint", "/confirmemail", "/recover", "/disabled" }, .text = &.{ "confirm your identity", "we suspended your account", "your account has been disabled", "your account has been locked", "xác nhận danh tính", "tài khoản của bạn đã bị khóa", "tài khoản của bạn đã bị vô hiệu hóa" } }, .{ .kind = .captcha, .urlz = &.{ "/captcha", "/recaptcha" }, .text = &.{ "security check", "type the characters", "i'm not a robot", "kiểm tra bảo mật", "nhập các ký tự" } }, .{ .kind = .twofa, .urlz = &.{ "/two_step_verification", "/two_factor", "/login/approvals" }, .text = &.{ "two-factor authentication required", "enter the code we sent", "enter the 6-digit code", "mã xác thực", "nhập mã gồm 6 chữ số" } }, .{ .kind = .blocked, .urlz = &.{}, .text = &.{ "action blocked", "you're temporarily blocked", "you have been temporarily blocked", "we limit how often you can post", "bạn tạm thời bị chặn", "hành động bị chặn" } }, .{ .kind = .ratelimit, .urlz = &.{}, .text = &.{ "you're going too fast", "slow down", "try again later", "bạn thao tác quá nhanh", "thử lại sau" } }, .{ .kind = .warning, .urlz = &.{}, .text = &.{ "we noticed unusual activity", "unusual activity", "you can't use this feature right now", "against our community standards and you", "hoạt động bất thường", "bạn không thể sử dụng tính năng này" } }, .{ .kind = .logout, .urlz = &.{ "/login", "login.php", "/login/identify" }, .text = &.{ "log in to facebook", "log into facebook", "you must log in", "đăng nhập facebook", "bạn phải đăng nhập" } } };
pub fn check(urlz: []const u8, text: []const u8) ?Halt { var ubuf: [512]u8 = undefined; var tbuf: [CF.scan * 2]u8 = undefined; const lurl = fld.fold(&ubuf, urlz[0..@min(urlz.len, ubuf.len / 2)]); const body = fld.fold(&tbuf, text[0..@min(text.len, CF.scan)]); for (RULES) |rul| { if (fld.hasAny(lurl, rul.urlz)) return rul.kind; } for (RULES) |rul| { if (fld.hasAny(body, rul.text)) return rul.kind; } return null; }
pub fn name(kind: Halt) []const u8 { return @tagName(kind); }
pub fn isLogout(kind: Halt) bool { return kind == .logout; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
