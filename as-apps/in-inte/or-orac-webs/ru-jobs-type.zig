// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job row types and step builders shared by the catalog files
// Flo: types (Job, T, Arg, Host, Risk) > one-line step builders (g, c, cm, cf, cl, ty, ck, up, ex, ek, sl, tg, en)
// I/O: none (types + pure builders) > used by ru-jobs-rows-* and ru-jobs-tabl
// ===================================================================
const std = @import("std"); const pace = @import("ru-huma-pace.zig"); const flow = @import("ru-flow-runz.zig");
pub const Risk = enum { w, x };
pub const Host = enum { app, www, docs };
pub const Arg = enum { none, text, to, url, title, price, desc, group, photo, opt, date, time, user, pass, tena };
pub const T = struct { op: flow.Op, role: []const u8 = "", key: []const u8 = "", larg: Arg = .none, arg: Arg = .none, lit: []const u8 = "", commit: bool = false };
pub const Job = struct { name: []const u8, kind: pace.Kind, risk: Risk, host: Host, path: []const u8, need: []const Arg, steps: []const T, hint: []const u8, auth: bool = false, once: bool = false };
pub fn g() T { return .{ .op = .goto }; }
pub fn c(key: []const u8) T { return .{ .op = .click, .key = key }; }
pub fn cm(key: []const u8) T { return .{ .op = .click, .key = key, .commit = true }; }
pub fn cf(key: []const u8) T { return .{ .op = .confirm, .key = key, .commit = true }; }
pub fn cl(arg: Arg) T { return .{ .op = .click, .larg = arg }; }
pub fn ty(key: []const u8, arg: Arg) T { return .{ .op = .typez, .key = key, .arg = arg }; }
pub fn ck(key: []const u8) T { return .{ .op = .clear, .key = key }; }
pub fn up(arg: Arg) T { return .{ .op = .upload, .arg = arg }; }
pub fn ex(arg: Arg) T { return .{ .op = .expect, .arg = arg }; }
pub fn ek(key: []const u8) T { return .{ .op = .expect, .key = key }; }
pub fn sl(key: []const u8, arg: Arg) T { return .{ .op = .select, .key = key, .arg = arg }; }
pub fn tg(key: []const u8, lit: []const u8) T { return .{ .op = .toggle, .key = key, .lit = lit, .commit = true }; }
pub fn en() T { return .{ .op = .key, .lit = "Enter", .commit = true }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
