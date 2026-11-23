// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Account pages: logout, devices (list, remote logout), settings (notify, language), storage, help, feedback, password hand-off
// Flo: mode gate > halt+pace gate > open panel by registry key > click or read > read back the page state > log
// I/O: Sess + words (caller) > Out (done flag + text); ask-first actions need force; password is a hand-task, never typed
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const snap = @import("ru-page-snap.zig"); const fnd = @import("ru-labl-find.zig");
pub const Op = enum { logo, devl, devo, setn, setl, stor, help, feed, pwdz };
pub const Out = struct { done: bool, text: []const u8 = "" };
pub fn force(op: Op) bool { return switch (op) { .logo, .devo, .feed => true, else => false }; }
pub fn isRead(op: Op) bool { return switch (op) { .devl, .stor, .help => true, else => false }; }
fn nameOf(op: Op) []const u8 { return @tagName(op); }
fn open(ses: *sess.Sess, key: []const u8) !void { const btn = try ses.findKey(key); try ses.clickNode(btn); ses.readPause(); }
fn prefLen(ses: *sess.Sess, key: []const u8, name: []const u8) ?usize { const ent = ses.reg.get(key) orelse return null; for (ent.vi) |pre| { if (pre.len > 0 and std.mem.startsWith(u8, name, pre)) return pre.len; } for (ent.en) |pre| { if (pre.len > 0 and std.mem.startsWith(u8, name, pre)) return pre.len; } return null; }
fn grab(ses: *sess.Sess, key: []const u8, tag: []const u8) ![]const u8 { const lst = try ses.nodes(); var out: std.ArrayList(u8) = .empty; for (lst) |nod| { const len = prefLen(ses, key, nod.name) orelse continue; const rest = nod.name[len..]; if (tag.len > 0) { if (!std.mem.startsWith(u8, rest, tag)) continue; if (out.items.len > 0) try out.appendSlice(ses.aren, "; "); try out.appendSlice(ses.aren, rest[tag.len..]); } else { if (out.items.len > 0) try out.appendSlice(ses.aren, "; "); try out.appendSlice(ses.aren, rest); } } return out.items; }
fn setOf(ses: *sess.Sess, tag: []const u8) ![]const u8 { try open(ses, "sett_butt"); return grab(ses, "sets_pref", tag); }
fn dialog(ses: *sess.Sess, openk: []const u8, field: []const u8, text: []const u8, ok: []const u8) !void { try open(ses, openk); const box = try ses.findKey(field); try ses.clickNode(box); try ses.typeIn(text); ses.readPause(); const okz = try ses.findKey(ok); try ses.clickNode(okz); }
fn badVal(op: Op, a: []const u8) bool { return switch (op) { .setn => !(std.mem.eql(u8, a, "on") or std.mem.eql(u8, a, "off")), .setl => !(std.mem.eql(u8, a, "vi") or std.mem.eql(u8, a, "en")), else => false }; }
pub fn run(ses: *sess.Sess, op: Op, a: []const u8) !Out { if (ses.mode == .read and !isRead(op)) return error.BadUsage; if ((op == .devo or op == .setn or op == .setl or op == .feed) and a.len == 0) return error.BadJob; if (badVal(op, a)) return error.BadJob; if (force(op) and ses.mode == .live) return error.NeedForce;
if (ses.mode == .dry and !isRead(op)) { try ses.pre(.read); const note = try std.fmt.allocPrint(ses.aren, "PREVIEW {s} {s}", .{ nameOf(op), if (op == .feed) "" else a }); ses.logz("info", note); return .{ .done = false }; }
try ses.pre(.read); var text: []const u8 = "";
switch (op) { .logo => { try open(ses, "logo_butt"); const okz = try ses.findKey("conf_butt"); try ses.clickNode(okz); ses.readPause(); const page = try snap.pageText(ses.aren, ses.conn); if (fnd.markPos(&ses.reg, page, "qrcd_page") == null) return error.Fail; },
.devl => { try open(ses, "devi_butt"); text = try grab(ses, "devi_pref", ""); if (text.len == 0) return error.NoElem; },
.devo => { try open(ses, "devi_butt"); const btn = try ses.findWith("devo_butt", a); try ses.clickNode(btn); ses.readPause(); try open(ses, "devi_butt"); const lst = try ses.nodes(); if (fnd.findWith(&ses.reg, lst, "devo_butt", a) != null) return error.Fail; },
.setn => { try open(ses, "sett_butt"); const btn = try ses.findKey(if (std.mem.eql(u8, a, "on")) "notn_butt" else "notf_butt"); try ses.clickNode(btn); ses.readPause(); const got = try setOf(ses, "notify="); if (!std.mem.eql(u8, got, a)) return error.Fail; },
.setl => { try open(ses, "sett_butt"); const btn = try ses.findKey(if (std.mem.eql(u8, a, "vi")) "lanv_butt" else "lane_butt"); try ses.clickNode(btn); ses.readPause(); const got = try setOf(ses, "lang="); if (!std.mem.eql(u8, got, a)) return error.Fail; },
.stor => { try open(ses, "stor_butt"); text = try grab(ses, "stor_pref", ""); if (text.len == 0) return error.NoElem; },
.help => { try open(ses, "help_butt"); text = try grab(ses, "help_pref", ""); if (text.len == 0) return error.NoElem; },
.feed => try dialog(ses, "feed_butt", "feed_boxz", a, "fsen_butt"),
.pwdz => { try open(ses, "pwdz_butt"); const note = try std.fmt.allocPrint(ses.aren, "hand {s}: owner types the password", .{nameOf(op)}); ses.logz("info", note); return error.HandTask; } }
const note = try std.fmt.allocPrint(ses.aren, "{s} done {s}", .{ nameOf(op), if (op == .feed) "" else a }); ses.logz("info", note); if (!isRead(op)) ses.pause(); return .{ .done = true, .text = text }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
