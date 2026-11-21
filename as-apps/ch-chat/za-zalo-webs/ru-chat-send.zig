// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Send job: preview or send one text once, verify it appeared, log it
// Flo: mode check > halt+pace gate > open chat > begin send row (dup or resume check) > type > click send > verify > mark sent
// I/O: Sess + chat name + text (caller) > Out (sent, dup, dry); rows in sends, acts, logz
// ===================================================================
const std = @import("std"); const snap = @import("ru-page-snap.zig"); const sess = @import("ru-sess-ctxz.zig"); const rd = @import("ru-chat-read.zig"); const priv = @import("ru-safe-priv.zig");
const CF = .{ .vfy = 6 };
pub const Out = enum { sent, dup, dry };
fn shown(ses: *sess.Sess, text: []const u8) !bool { const shot = try rd.msgsNow(ses); var idx: usize = shot.len; var seen: u32 = 0; while (idx > 0 and seen < CF.vfy) : (seen += 1) { idx -= 1; if (std.mem.eql(u8, shot[idx].who, "me") and std.mem.eql(u8, shot[idx].body, text)) return true; } return false; }
fn verify(ses: *sess.Sess, text: []const u8) !bool { var cnt: u32 = 0; while (cnt < ses.cfg.retr_coun_maxz) : (cnt += 1) { if (try shown(ses, text)) return true; std.Io.sleep(ses.iozz, .fromMilliseconds(if (ses.fast) 1 else 500), .awake) catch {}; } return false; }
fn exists(ses: *sess.Sess, name: []const u8) !bool { const chats = try rd.listChats(ses); for (chats) |cht| { if (std.ascii.eqlIgnoreCase(cht.name, name)) return true; } return false; }
pub fn sendText(ses: *sess.Sess, chat: []const u8, text: []const u8) !Out { const trim = std.mem.trim(u8, text, " \r\n\t"); if (trim.len == 0 or chat.len == 0) return error.BadJob; if (ses.mode == .read) return error.BadUsage; if (ses.mode == .dry) { try ses.pre(.read); if (!try exists(ses, chat)) return error.NoElem; const note = try std.fmt.allocPrint(ses.aren, "PREVIEW {s}: {s}", .{ chat, priv.bodyLog(ses.aren, trim, ses.cfg.logz_body_enab) }); ses.logz("info", note); return .dry; }
try ses.pre(.send); const canon = try rd.openChat(ses, chat); const beg = try ses.sto.sendBegin(canon, trim, ses.now()); if (beg == .dup) { ses.logz("info", "duplicate send skipped"); return .dup; }
if (beg == .pend and try shown(ses, trim)) { try ses.sto.sendDone(canon, trim, ses.now()); ses.logz("info", "resumed: message already in chat"); return .sent; }
const box = try ses.findKey("mesg_boxz"); try ses.clickNode(box); try ses.typeIn(trim); ses.readPause(); const btn = try ses.findKey("send_butt"); try ses.clickNode(btn);
if (!try verify(ses, trim)) { ses.logz("error", "send not confirmed in chat"); return error.Fail; }
try ses.sto.sendDone(canon, trim, ses.now()); const note = try std.fmt.allocPrint(ses.aren, "sent to {s}: {d} chars", .{ canon, trim.len }); ses.logz("info", note); ses.pause(); return .sent; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
