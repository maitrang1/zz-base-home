// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Chaos helpers: cut the CDP socket at a named stage, reconnect a second client to the same page
// Flo: stage name > hook kills the socket when that stage fires > second connection > new session on it
// I/O: Rig + stage (test) > a session whose link dies at the stage; a fresh session on the same page
// ===================================================================
const std = @import("std"); const cdp = @import("nt-cdpz-sock.zig"); const brow = @import("nt-brow-laun.zig"); const sess = @import("ru-sess-ctxz.zig"); const rig = @import("te-rigz-main.zig"); const conf = @import("cf-conf-load.zig");
pub var stage: []const u8 = "";
pub fn killHook(ses: *sess.Sess, st: []const u8) void { if (std.mem.eql(u8, st, stage)) ses.conn.strm.shutdown(ses.iozz, .both) catch {}; }
pub fn second(rg: *rig.Rig) !*cdp.Conn { const gpa = std.testing.allocator; const path = try brow.pageWs(gpa, std.testing.io, rg.mok.bro.port, 5000); defer gpa.free(path); return cdp.connect(gpa, std.testing.io, rg.mok.bro.port, path, 5000); }
pub fn jsC(rg: *rig.Rig, conn: *cdp.Conn, code: []const u8) ![]const u8 { return @import("ru-page-snap.zig").evalStr(rg.aren.allocator(), conn, code); }
pub fn numC(rg: *rig.Rig, conn: *cdp.Conn, code: []const u8) !i64 { return std.fmt.parseInt(i64, try jsC(rg, conn, code), 10) catch -1; }
pub fn dying(rg: *rig.Rig, cfg: conf.Conf, mode: sess.Mode, st: []const u8) sess.Sess { stage = st; var out = rg.ses(cfg, mode); out.hook = killHook; return out; }
pub fn onConn(rg: *rig.Rig, conn: *cdp.Conn, cfg: conf.Conf, mode: sess.Mode) sess.Sess { var out = sess.Sess.init(std.testing.allocator, std.testing.io, rg.aren.allocator(), cfg, &rg.sto, conn, mode); out.fast = true; out.fake_ms = rig.NOON + 3600000; out.job = "chaos"; out.reg.ext = rig.SIM_EXT; return out; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
