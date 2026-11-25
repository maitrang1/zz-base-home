// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Human wheel scrolling: older messages, chat list, step caps
// Flo: find container center by registry selector > move mouse there > wheel ticks with pauses > stop on goal, no growth or cap
// I/O: Sess (caller) > message count reached; list scrolled
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const extr = @import("ru-page-extr.zig"); const inpu = @import("ru-huma-inpu.zig");
const CF = .{ .tick = 300, .nogr = 2 };
pub fn hover(ses: *sess.Sess, sel: []const u8) !?inpu.Pt { const pnt = (try extr.rectCenter(ses.aren, ses.conn, sel)) orelse return null; ses.pos = try inpu.moveTo(ses.aren, ses.conn, ses.rand(), ses.pos, pnt); return pnt; }
pub fn wheel(ses: *sess.Sess, sel: []const u8, deltay: i32) !bool { const pnt = (try hover(ses, sel)) orelse return false; try inpu.scrollBy(ses.aren, ses.conn, ses.rand(), pnt, deltay); return true; }
pub fn loadOlder(ses: *sess.Sess, want: u32) !u32 { const ext = ses.reg.ext; if (ext.scrl_sel.len == 0 or ext.msg_sel.len == 0) return error.NoElem; var cnt = try extr.countSel(ses.aren, ses.conn, ext.msg_sel); var stuck: u32 = 0; var step: u32 = 0; while (cnt < want and step < ses.cfg.scrl_step_maxz) : (step += 1) { if (!try wheel(ses, ext.scrl_sel, -CF.tick)) return error.NoElem; ses.readPause(); const now = try extr.countSel(ses.aren, ses.conn, ext.msg_sel); if (now <= cnt) { stuck += 1; if (stuck >= CF.nogr) break; } else stuck = 0; cnt = now; } return cnt; }
pub fn listDown(ses: *sess.Sess) !bool { const ext = ses.reg.ext; if (ext.list_sel.len == 0) return false; return wheel(ses, ext.list_sel, CF.tick); }
pub fn listUp(ses: *sess.Sess, steps: u32) !void { const ext = ses.reg.ext; if (ext.list_sel.len == 0) return; var idx: u32 = 0; while (idx < steps) : (idx += 1) _ = try wheel(ses, ext.list_sel, -CF.tick * 4); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
