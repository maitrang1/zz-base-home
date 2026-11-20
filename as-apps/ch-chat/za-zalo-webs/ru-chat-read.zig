// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read job: list chats, open a chat, save only new messages
// Flo: snapshot chat list > match unread > open chat with human click > read message nodes > diff with saved tail > save
// I/O: Sess (caller) > Chat list, new message count, rows in msgs table
// ===================================================================
const std = @import("std"); const snap = @import("ru-page-snap.zig"); const data = @import("st-stat-data.zig"); const sess = @import("ru-sess-ctxz.zig");
pub const Chat = struct { name: []const u8, unre: bool, node: snap.Node };
pub const Summ = struct { chats: u32 = 0, newm: u32 = 0 };
pub fn chatName(label: []const u8, mark: []const u8) []const u8 { if (mark.len > 0) { if (std.ascii.findIgnoreCase(label, mark)) |idx| return std.mem.trim(u8, label[0..idx], " "); } return std.mem.trim(u8, label, " "); }
pub fn isUnread(label: []const u8, mark: []const u8) bool { return mark.len > 0 and std.ascii.findIgnoreCase(label, mark) != null; }
pub fn listChats(ses: *sess.Sess) ![]Chat { const lst = try ses.nodes(); const raw = try snap.findAll(ses.aren, lst, ses.cfg.labl_chat_role, ""); var out: std.ArrayList(Chat) = .empty; for (raw) |nod| { if (nod.name.len == 0) continue; try out.append(ses.aren, .{ .name = chatName(nod.name, ses.cfg.labl_unre_mark), .unre = isUnread(nod.name, ses.cfg.labl_unre_mark), .node = nod }); } return out.items; }
pub fn openChat(ses: *sess.Sess, name: []const u8) ![]const u8 { var cnt: u32 = 0; while (cnt < ses.cfg.retr_coun_maxz) : (cnt += 1) { const chats = try listChats(ses); for (chats) |cht| { if (std.ascii.eqlIgnoreCase(cht.name, name)) { try ses.clickNode(cht.node); ses.readPause(); return cht.name; } } std.Io.sleep(ses.iozz, .fromMilliseconds(if (ses.fast) 1 else 400), .awake) catch {}; } const msg = try std.fmt.allocPrint(ses.aren, "chat not in list: {s}", .{name}); ses.logz("warn", msg); return error.NoElem; }
pub fn parseMsg(ses: *sess.Sess, name: []const u8) data.Msgz { const pre = ses.cfg.labl_self_pref; if (pre.len > 0 and std.mem.startsWith(u8, name, pre)) return .{ .who = "me", .body = name[pre.len..], .ts = ses.now() }; return .{ .who = "them", .body = name, .ts = ses.now() }; }
pub fn msgsNow(ses: *sess.Sess) ![]data.Msgz { const lst = try ses.nodes(); const raw = try snap.findAll(ses.aren, lst, ses.cfg.labl_mesg_role, ""); const keep = @min(raw.len, ses.cfg.read_msgz_maxz); var out: std.ArrayList(data.Msgz) = .empty; for (raw[raw.len - keep ..]) |nod| try out.append(ses.aren, parseMsg(ses, nod.name)); return out.items; }
fn same(one: data.Msgz, two: data.Msgz) bool { return std.mem.eql(u8, one.who, two.who) and std.mem.eql(u8, one.body, two.body); }
pub fn newSince(tail: []const data.Msgz, shot: []const data.Msgz) []const data.Msgz { var ovl: usize = @min(tail.len, shot.len); while (ovl > 0) : (ovl -= 1) { var okay = true; for (0..ovl) |idx| { if (!same(tail[tail.len - ovl + idx], shot[idx])) { okay = false; break; } } if (okay) break; } return shot[ovl..]; }
pub fn readChat(ses: *sess.Sess, name: []const u8) !u32 { try ses.pre(.read); const canon = try openChat(ses, name); const shot = try msgsNow(ses); const tail = try ses.sto.msgTail(ses.aren, canon, ses.cfg.read_msgz_maxz); const fresh = newSince(tail, shot); for (fresh) |msg| try ses.sto.msgAdd(canon, msg.who, msg.body, msg.ts); const note = try std.fmt.allocPrint(ses.aren, "read {s}: {d} new", .{ canon, fresh.len }); ses.logz("info", note); return @intCast(fresh.len); }
pub fn readUnread(ses: *sess.Sess) !Summ { var sum: Summ = .{}; const chats = try listChats(ses); var names: std.ArrayList([]const u8) = .empty; for (chats) |cht| { if (cht.unre) try names.append(ses.aren, cht.name); } for (names.items) |nam| { const cnt = readChat(ses, nam) catch |err| { if (err == error.NoElem) continue; return err; }; sum.chats += 1; sum.newm += cnt; ses.pause(); } return sum; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
