// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Types and row helpers shared by every job table
// Flo: Job = name + cap kind + risk + page source + steps; helper fns build one step each; class A/G/H comes from the rows
// I/O: none (types + comptime helpers) > used by ru-jobs-tabl and the area tables
// ===================================================================
const pace = @import("ru-huma-pace.zig"); const flow = @import("ru-flow-runz.zig");
pub const Risk = enum { w, x };
pub const Area = enum { acct, core, data, mone, acce, sett, help, edge };
pub const Src = enum { none, url, home, noti, frie_requ, birt, msgr, msgr_requ, mark_sell, evnt_crea, stor_crea, reel_crea, prof, bizz, dmsg_thre, cfgp };
pub const Arg = enum { none, text, to, url, title, price, desc, group, photo, opt, date, time, s_login, s_pass, s_newp, s_firs, s_last, s_mail, s_birt };
pub const T = struct { op: flow.Op, role: []const u8 = "", key: []const u8 = "", larg: Arg = .none, arg: Arg = .none, lit: []const u8 = "", commit: bool = false, idx: bool = false, soft: bool = false };
pub const Job = struct { name: []const u8, kind: pace.Kind, risk: Risk, src: Src, need: []const Arg, each: bool = false, steps: []const T, area: Area = .core, pkey: []const u8 = "", rep: bool = false, dl: bool = false, spend: bool = false, free: bool = false };
pub fn g() T { return .{ .op = .goto }; }
pub fn gs() T { return .{ .op = .goto, .soft = true }; }
pub fn c(key: []const u8) T { return .{ .op = .click, .key = key }; }
pub fn cm(key: []const u8) T { return .{ .op = .click, .key = key, .commit = true }; }
pub fn cs(key: []const u8) T { return .{ .op = .click, .key = key, .soft = true }; }
pub fn cms(key: []const u8) T { return .{ .op = .click, .key = key, .commit = true, .soft = true }; }
pub fn cf(key: []const u8) T { return .{ .op = .confirm, .key = key, .commit = true }; }
pub fn cl(arg: Arg) T { return .{ .op = .click, .larg = arg }; }
pub fn ty(key: []const u8, arg: Arg) T { return .{ .op = .typez, .key = key, .arg = arg }; }
pub fn tyi(key: []const u8, arg: Arg) T { return .{ .op = .typez, .key = key, .arg = arg, .idx = true }; }
pub fn ck(key: []const u8) T { return .{ .op = .clear, .key = key }; }
pub fn up(arg: Arg) T { return .{ .op = .upload, .arg = arg }; }
pub fn ex(arg: Arg) T { return .{ .op = .expect, .arg = arg }; }
pub fn exk(key: []const u8) T { return .{ .op = .expect, .key = key }; }
pub fn sl(key: []const u8, arg: Arg) T { return .{ .op = .select, .key = key, .arg = arg, .role = "button" }; }
pub fn hv(key: []const u8) T { return .{ .op = .hover, .key = key }; }
pub fn mi(arg: Arg, key: []const u8) T { return .{ .op = .click, .key = key, .larg = arg, .role = "menuitem", .commit = true }; }
pub fn en() T { return .{ .op = .key, .lit = "Enter", .commit = true }; }
pub fn tg(key: []const u8, arg: Arg) T { return .{ .op = .toggle, .key = key, .arg = arg, .commit = true }; }
pub fn tgl(key: []const u8, lit: []const u8) T { return .{ .op = .toggle, .key = key, .lit = lit, .commit = true }; }
pub fn hn(key: []const u8, why: []const u8) T { return .{ .op = .hand, .key = key, .lit = why }; }
pub fn sk(key: []const u8) T { return .{ .op = .stopif, .key = key }; }
pub fn readOnly(job: *const Job) bool { for (job.steps) |tpl| { if (tpl.op != .goto and tpl.op != .expect and tpl.op != .stopif) return false; } return true; }
pub fn classOf(job: *const Job) u8 { for (job.steps) |tpl| { if (tpl.op == .hand) return 'H'; } return if (job.risk == .x) 'G' else 'A'; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
