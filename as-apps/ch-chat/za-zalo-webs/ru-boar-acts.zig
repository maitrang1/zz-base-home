// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Board, social and group admin: polls, notes, labels, quick messages, friends, message requests, group admin, profile read
// Flo: mode gate > halt+pace gate (new contact budget for friends) > open chat > open dialog by registry key > fill fields > confirm > log
// I/O: Sess + chat + words (caller) > page state change; preview in dry mode; ask-first actions need force
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const opn = @import("ru-chat-open.zig"); const snap = @import("ru-page-snap.zig"); const fnd = @import("ru-labl-find.zig");
pub const Op = enum { poll, note, labl, quik, qkus, freq, facc, fign, macc, mign, gren, gadd, grem, gdep, glea, prof };
pub const Fld = struct { key: []const u8, val: []const u8 };
pub fn force(op: Op) bool { return switch (op) { .freq, .gadd, .grem, .gdep, .glea => true, else => false }; }
fn newc(op: Op) bool { return op == .freq or op == .macc; }
fn nameOf(op: Op) []const u8 { return @tagName(op); }
fn dialog(ses: *sess.Sess, open: []const u8, fields: []const Fld, ok: []const u8) !void { const btn = try ses.findKey(open); try ses.clickNode(btn); ses.readPause(); for (fields) |fld| { const box = try ses.findKey(fld.key); try ses.clickNode(box); try ses.typeIn(fld.val); ses.readPause(); } const okz = try ses.findKey(ok); try ses.clickNode(okz); }
fn answer(ses: *sess.Sess, panel: []const u8, key: []const u8, who: []const u8) !void { const btn = try ses.findKey(panel); try ses.clickNode(btn); ses.readPause(); const pick = try ses.findWith(key, who); try ses.clickNode(pick); }
pub fn run(ses: *sess.Sess, op: Op, chat: []const u8, a: []const u8, b: []const u8, c: []const u8) !bool { if (ses.mode == .read) return error.BadUsage; if (a.len == 0 and op != .glea and op != .prof) return error.BadJob; if (force(op) and ses.mode == .live) return error.NeedForce;
if (ses.mode == .dry) { try ses.pre(.read); const note = try std.fmt.allocPrint(ses.aren, "PREVIEW {s} {s}", .{ nameOf(op), chat }); ses.logz("info", note); return false; }
try ses.pre(if (newc(op)) .newc else .read); const needs_chat = switch (op) { .poll, .note, .labl, .qkus, .gren, .gadd, .grem, .gdep, .glea => true, else => false }; if (needs_chat) { if (chat.len == 0) return error.BadJob; _ = try opn.openChat(ses, chat); }
switch (op) { .poll => { if (b.len == 0 or c.len == 0) return error.BadJob; try dialog(ses, "poll_butt", &.{ .{ .key = "ques_boxz", .val = a }, .{ .key = "opt1_boxz", .val = b }, .{ .key = "opt2_boxz", .val = c } }, "crea_butt"); }, .note => try dialog(ses, "note_butt", &.{.{ .key = "ntex_boxz", .val = a }}, "crea_butt"), .labl => try dialog(ses, "labl_butt", &.{.{ .key = "lnam_boxz", .val = a }}, "crea_butt"), .quik => { if (b.len == 0) return error.BadJob; try dialog(ses, "quik_butt", &.{ .{ .key = "shor_boxz", .val = a }, .{ .key = "cont_boxz", .val = b } }, "crea_butt"); }, .qkus => { const btn = try ses.findKey("qkus_butt"); try ses.clickNode(btn); ses.readPause(); const nm = try std.fmt.allocPrint(ses.aren, "/{s}", .{a}); const pick = try ses.find("button", nm); try ses.clickNode(pick); },
.freq => try dialog(ses, "addf_butt", &.{.{ .key = "phon_boxz", .val = a }}, "areq_butt"), .facc => try answer(ses, "frie_butt", "acce_butt", a), .fign => try answer(ses, "frie_butt", "igno_butt", a), .macc => try answer(ses, "mreq_butt", "acce_butt", a), .mign => try answer(ses, "mreq_butt", "igno_butt", a),
.gren => try dialog(ses, "gren_butt", &.{.{ .key = "gnam_boxz", .val = a }}, "crea_butt"), .gadd => try dialog(ses, "gadd_butt", &.{.{ .key = "memb_boxz", .val = a }}, "crea_butt"), .grem => try dialog(ses, "grem_butt", &.{.{ .key = "memb_boxz", .val = a }}, "crea_butt"), .gdep => try dialog(ses, "gdep_butt", &.{.{ .key = "memb_boxz", .val = a }}, "crea_butt"), .glea => { const btn = try ses.findKey("glea_butt"); try ses.clickNode(btn); }, .prof => { const btn = try ses.findKey("prof_butt"); try ses.clickNode(btn); ses.readPause(); } }
if (newc(op)) try ses.sto.actAdd(ses.now(), "newc"); const note = try std.fmt.allocPrint(ses.aren, "{s} done {s}", .{ nameOf(op), chat }); ses.logz("info", note); ses.pause(); return true; }
pub fn profileText(ses: *sess.Sess) ![]const u8 { const lst = try ses.nodes(); for (lst) |nod| { if (std.mem.startsWith(u8, nod.name, "Họ tên") or std.mem.startsWith(u8, nod.name, "Name:")) return nod.name; } return error.NoElem; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
