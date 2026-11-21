// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job table: run one job by name and words, shared by run and flow commands
// Flo: job name > words > matching job function > Report
// I/O: Sess + job + words (caller) > Report (counts, lines)
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const rd = @import("ru-chat-read.zig"); const grp = @import("ru-chat-grou.zig"); const rec = @import("ru-reci-main.zig"); const cana = @import("ru-labl-cana.zig");
pub const JOBS = [_][]const u8{ "read", "reply", "summ", "canary", "say", "send", "remind", "pin", "mute", "group", "forward" };
pub fn known(job: []const u8) bool { for (JOBS) |nam| { if (std.mem.eql(u8, nam, job)) return true; } return false; }
fn join(aren: std.mem.Allocator, words: []const []const u8) ![]const u8 { return std.mem.join(aren, " ", words); }
fn one(done: bool) rec.Report { return if (done) .{ .sent = 1 } else .{ .prev = 1 }; }
fn readJob(ses: *sess.Sess) !rec.Report { const sum = try rd.readUnread(ses); var lines: std.ArrayList([]const u8) = .empty; try lines.append(ses.aren, try std.fmt.allocPrint(ses.aren, "read {d} chats, {d} new messages", .{ sum.chats, sum.newm })); return .{ .prev = sum.chats, .lines = lines.items }; }
pub fn dispatch(ses: *sess.Sess, job: []const u8, arg: []const []const u8) !rec.Report { const aren = ses.aren; if (std.mem.eql(u8, job, "read")) return readJob(ses); if (std.mem.eql(u8, job, "reply")) return rec.run(ses, .price); if (std.mem.eql(u8, job, "summ")) return rec.run(ses, .summ); if (std.mem.eql(u8, job, "canary")) return cana.run(ses, if (arg.len > 0) arg[0] else ""); if (std.mem.eql(u8, job, "say")) { if (arg.len == 0) return error.BadJob; return rec.run(ses, try rec.parse(try join(aren, arg))); } if (std.mem.eql(u8, job, "send")) { if (arg.len < 2) return error.BadJob; return rec.run(ses, .{ .send = .{ .chat = arg[0], .text = try join(aren, arg[1..]) } }); } if (std.mem.eql(u8, job, "remind")) { if (arg.len < 3) return error.BadJob; return rec.run(ses, .{ .remind = .{ .chat = arg[0], .whenz = arg[1], .titl = try join(aren, arg[2..]) } }); } if (std.mem.eql(u8, job, "pin") or std.mem.eql(u8, job, "mute")) { if (arg.len < 1) return error.BadJob; return one(try grp.chatAct(ses, if (job[0] == 'p') .pin else .mute, arg[0], "")); } if (std.mem.eql(u8, job, "group")) { return one(try grp.chatAct(ses, .grop, "", if (arg.len > 0) try join(aren, arg) else "")); } if (std.mem.eql(u8, job, "forward")) { if (arg.len < 2) return error.BadJob; return one(try grp.chatAct(ses, .forw, arg[0], arg[1])); } return error.BadJob; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
