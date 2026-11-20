// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Chat actions by label: pin, mute, forward, new group
// Flo: mode gate > halt+pace gate > open chat > find button by label > human click > log
// I/O: Sess + chat name + Act (caller) > page state change, log row; preview only in dry mode
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const rd = @import("ru-chat-read.zig");
pub const Act = enum { pin, mute, forw, grop };
fn labelOf(ses: *sess.Sess, act: Act) []const u8 { return switch (act) { .pin => ses.cfg.labl_pinz_butt, .mute => ses.cfg.labl_mute_butt, .forw => ses.cfg.labl_forw_butt, .grop => ses.cfg.labl_grou_butt }; }
pub fn actName(act: Act) []const u8 { return @tagName(act); }
pub fn chatAct(ses: *sess.Sess, act: Act, chat: []const u8, extra: []const u8) !bool { if (ses.mode == .read) return error.BadUsage; if (chat.len == 0 and act != .grop) return error.BadJob; if ((act == .grop or act == .forw) and ses.mode == .live) return error.NeedForce; if (ses.mode == .dry) { try ses.pre(.read); const note = try std.fmt.allocPrint(ses.aren, "PREVIEW {s} {s} {s}", .{ actName(act), chat, extra }); ses.logz("info", note); return false; }
try ses.pre(if (act == .grop) .newc else .read); if (act != .grop) _ = try rd.openChat(ses, chat); const btn = try ses.find("button", labelOf(ses, act)); try ses.clickNode(btn);
if (act == .grop and extra.len > 0) { const box = try ses.find("textbox", ses.cfg.labl_grou_name); try ses.clickNode(box); try ses.typeIn(extra); ses.readPause(); const okz = try ses.find("button", ses.cfg.labl_remi_okay); try ses.clickNode(okz); }
if (act == .forw and extra.len > 0) { const chats = try rd.listChats(ses); for (chats) |cht| { if (std.ascii.eqlIgnoreCase(cht.name, extra)) { try ses.clickNode(cht.node); break; } } else return error.NoElem; ses.readPause(); const sendb = try ses.find("button", ses.cfg.labl_send_butt); try ses.clickNode(sendb); }
if (act == .grop) try ses.sto.actAdd(ses.now(), "newc"); const note = try std.fmt.allocPrint(ses.aren, "{s} {s} {s}", .{ actName(act), chat, extra }); ses.logz("info", note); ses.pause(); return true; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
