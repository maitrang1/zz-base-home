// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Wait for the human: needs-you pages (QR, captcha), notify once, poll, deadline, settle, cool pace
// Flo: 2nd challenge in 24 h is unsafe > notify > poll page every 3 s without touching it > cleared: settle, re-verify, cool pace > or deadline > or unsafe
// I/O: Sess + stat dir + why (caller) > Wait (cleared, deadline, unsafe); meta cool_until, interventions, wait time
// ===================================================================
const std = @import("std"); const sess = @import("ru-sess-ctxz.zig"); const halt = @import("ru-safe-halt.zig"); const noti = @import("ru-noti-send.zig"); const snap = @import("ru-page-snap.zig"); const flo = @import("st-flow-data.zig");
const CF = .{ .poll = 3000, .minu = 60000, .hour = 3600000 };
pub const Wait = enum { cleared, deadline, unsafe };
fn verdict(ses: *sess.Sess) !halt.Verd { const txt = try halt.pageOf(ses.aren, ses.conn, &ses.reg); return halt.check(ses.aren, ses.cfg, &ses.reg, txt); }
fn nap(ses: *sess.Sess, mill: i64) void { if (ses.fast) { std.Io.sleep(ses.iozz, .fromMilliseconds(20), .awake) catch {}; ses.fake_ms += mill; return; } std.Io.sleep(ses.iozz, .fromMilliseconds(mill), .awake) catch {}; }
pub fn recheck(ses: *sess.Sess) !bool { if ((try ses.sto.haltGet(ses.aren)) == null) return false; if (try halt.classOf(ses.sto, ses.aren) != .need) return false; const ver = try verdict(ses); if (ver.kind != .okay) return false; try ses.sto.haltClear(); try ses.sto.metaSet("halt_class", ""); ses.logz("info", "owner cleared the check while za was parked"); return true; }
pub fn wait(ses: *sess.Sess, stat: []const u8, why: []const u8, real_toast: bool) !Wait { const t0 = ses.now(); const prev = try flo.metaInt(ses.sto, ses.aren, "chal_ts", 0); const span: i64 = @as(i64, ses.cfg.cool_hour_coun) * CF.hour; if (prev > 0 and t0 - prev < span) { ses.logz("halt", "second challenge within the cool window"); return .unsafe; } try flo.metaPutInt(ses.sto, "chal_ts", t0); try flo.metaPutInt(ses.sto, "interv_n", try flo.metaInt(ses.sto, ses.aren, "interv_n", 0) + 1);
const line = try noti.plain(ses.aren, why, "Solve it in the open Zalo window. za waits and continues by itself."); _ = try noti.send(ses.aren, ses.iozz, ses.cfg, stat, line, t0, real_toast); ses.logz("info", "waiting for the owner");
const dead: i64 = @as(i64, ses.cfg.wait_dead_mins) * CF.minu; while (ses.now() - t0 < dead) { const ver = try verdict(ses); switch (ver.kind) { .okay => break, .unsf => return .unsafe, .login, .need => nap(ses, CF.poll) } } else { try flo.metaPutInt(ses.sto, "wait_ms", try flo.metaInt(ses.sto, ses.aren, "wait_ms", 0) + (ses.now() - t0)); ses.logz("warn", "wait deadline reached, parked"); return .deadline; }
nap(ses, @as(i64, ses.cfg.wait_sett_mins) * CF.minu); const again = try verdict(ses); if (again.kind != .okay) { ses.logz("halt", "challenge came back after settling"); return .unsafe; }
try flo.metaPutInt(ses.sto, "cool_until", ses.now() + span); try flo.metaPutInt(ses.sto, "wait_ms", try flo.metaInt(ses.sto, ses.aren, "wait_ms", 0) + (ses.now() - t0)); try ses.sto.haltClear(); try ses.sto.metaSet("halt_class", ""); ses.logz("info", "owner handled it, resuming at cool pace"); return .cleared; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
