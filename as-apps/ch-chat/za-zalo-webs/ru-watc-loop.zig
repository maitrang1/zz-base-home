// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Watch loop: check inbox at human pace, with rests
// Flo: segment now > break: wait it out > read unread > optional price reply > wait next check (log-normal gap) > repeat to limit or deadline
// I/O: Sess + limits (caller) > Res (checks, new messages, why it ended); chats read into the store
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const rd = @import("ru-chat-read.zig"); const rec = @import("ru-reci-main.zig"); const hs = @import("ru-huma-sess.zig");
const CF = .{ .mins = 60000, .rest = 15 * 60000 };
pub const Why = enum { limit, deadline, blocked };
pub const Res = struct { checks: u32 = 0, newm: u32 = 0, breaks: u32 = 0, why: Why = .limit, note: []const u8 = "" };
fn wait(ses: *sess.Sess, mill: i64) void { if (ses.fast and ses.fake_ms != 0) { std.Io.sleep(ses.iozz, .fromMilliseconds(10), .awake) catch {}; ses.fake_ms += mill; return; } std.Io.sleep(ses.iozz, .fromMilliseconds(mill), .awake) catch {}; }
pub fn run(ses: *sess.Sess, max_checks: u32, deadline_mins: u32) !Res { var res: Res = .{}; const t0 = ses.now(); const dead: i64 = @as(i64, deadline_mins) * CF.mins; const rng: hs.Rng = .{ .actv = ses.cfg.sess_actv_mins, .brek = ses.cfg.sess_brek_mins };
while (ses.now() - t0 < dead) { const seg = hs.segAt(ses.now(), ses.cfg.loca_utcz_mins, ses.cfg.rand_seed_fixd ^ ses.ahsh, rng); if (!seg.active) { res.breaks += 1; wait(ses, seg.left_ms); continue; }
const sum = rd.readUnread(ses) catch |err| { switch (err) { error.QuietHrs, error.CapHit => { res.breaks += 1; wait(ses, CF.rest); continue; }, error.Halted, error.NeedLogin, error.UnknownModal => { res.why = .blocked; res.note = @errorName(err); return res; }, else => return err } }; res.checks += 1; res.newm += sum.newm; if (ses.cfg.watc_repl_enab) { _ = rec.run(ses, .price) catch {}; }
if (max_checks > 0 and res.checks >= max_checks) { res.why = .limit; return res; } wait(ses, hs.nextCheck(ses.rand(), ses.cfg.inbx_chek_mins)); }
res.why = .deadline; return res; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
