// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Turn plain words into a job (no AI needed)
// Flo: lowercase copy (same byte length) > match known phrases (English + Vietnamese) > cut the rest as arguments > Cmd or null
// I/O: owner's sentence (caller) > Cmd {job, Args} or null when not understood
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig"); const fld = @import("ut-text-fold.zig");
pub const Job = enum { post, reply, renew, renewall, sold, dm };
pub const Cmd = struct { job: Job, args: task.Args };
const POST = [_][]const u8{ "post:", "post ", "đăng:", "đăng " };
const REPL = [_][]const u8{ "reply to my comments", "reply to comments", "answer my comments", "trả lời bình luận", "trả lời comment" };
const RALL = [_][]const u8{ "renew my listings", "renew all", "renew listings", "gia hạn tất cả", "gia hạn tin" };
const RENE = [_][]const u8{ "renew ", "gia hạn " };
const MSGZ = [_][]const u8{ "message ", "nhắn ", "nhắn tin " };
const SOLD = [_][]const u8{ "sold:", "sold ", "đã bán:", "đã bán " };
fn cutRest(low: []const u8, orig: []const u8, pres: []const []const u8) ?[]const u8 { for (pres) |pre| { if (std.mem.startsWith(u8, low, pre)) return std.mem.trim(u8, orig[pre.len..], " :\t\r\n\""); } return null; }
pub fn parse(aren: std.mem.Allocator, text: []const u8) !?Cmd { const trm = std.mem.trim(u8, text, " \t\r\n"); if (trm.len == 0) return null; const low = try fld.foldAlloc(aren, trm); if (fld.hasAny(low, &REPL)) return .{ .job = .reply, .args = .{} }; if (fld.hasAny(low, &RALL)) return .{ .job = .renewall, .args = .{} }; if (cutRest(low, trm, &POST)) |rst| { if (rst.len > 0) return .{ .job = .post, .args = .{ .text = rst } }; return null; } if (cutRest(low, trm, &MSGZ)) |rst| { const sp = std.mem.findScalar(u8, rst, ' ') orelse return null; const tox = rst[0..sp]; const msg = std.mem.trim(u8, rst[sp + 1 ..], " :\""); if (tox.len == 0 or msg.len == 0) return null; return .{ .job = .dm, .args = .{ .to = tox, .text = msg } }; } if (cutRest(low, trm, &RENE)) |rst| { if (rst.len > 0) return .{ .job = .renew, .args = .{ .title = rst } }; return null; } if (cutRest(low, trm, &SOLD)) |rst| { if (rst.len > 0) return .{ .job = .sold, .args = .{ .title = rst } }; return null; } if (std.mem.startsWith(u8, low, "mark ") and std.mem.endsWith(u8, low, " sold") and trm.len > 10) return .{ .job = .sold, .args = .{ .title = std.mem.trim(u8, trm[5 .. trm.len - 5], " \"") } }; return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
