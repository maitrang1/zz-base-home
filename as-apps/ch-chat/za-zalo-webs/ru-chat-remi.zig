// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Reminder job: open chat, fill reminder dialog, confirm
// Flo: mode gate > halt+pace gate > open chat > click reminder button > type title + time > click create > log
// I/O: Sess + chat + title + time text (caller) > reminder dialog filled in the page; preview in dry mode
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const rd = @import("ru-chat-read.zig");
pub fn remind(ses: *sess.Sess, chat: []const u8, title: []const u8, whenz: []const u8) !bool { const ttl = std.mem.trim(u8, title, " \r\n\t"); const wht = std.mem.trim(u8, whenz, " \r\n\t"); if (chat.len == 0 or ttl.len == 0 or wht.len == 0) return error.BadJob; if (ses.mode == .read) return error.BadUsage; if (ses.mode == .dry) { try ses.pre(.read); const note = try std.fmt.allocPrint(ses.aren, "PREVIEW remind {s} at {s}: {s}", .{ chat, wht, ttl }); ses.logz("info", note); return false; }
try ses.pre(.read); _ = try rd.openChat(ses, chat); const btn = try ses.find("button", ses.cfg.labl_remi_butt); try ses.clickNode(btn); ses.readPause();
const tbx = try ses.find("textbox", ses.cfg.labl_remi_titl); try ses.clickNode(tbx); try ses.typeIn(ttl); const wbx = try ses.find("textbox", ses.cfg.labl_remi_time); try ses.clickNode(wbx); try ses.typeIn(wht); ses.readPause(); const okz = try ses.find("button", ses.cfg.labl_remi_okay); try ses.clickNode(okz);
const note = try std.fmt.allocPrint(ses.aren, "reminder set {s} at {s}: {s}", .{ chat, wht, ttl }); ses.logz("info", note); ses.pause(); return true; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
