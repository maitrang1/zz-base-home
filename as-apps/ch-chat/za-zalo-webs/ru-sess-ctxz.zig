// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job session: pace gate, halt check, find with retry, human click and type
// Flo: init rng + clock > pre (halt guard, pace gate, wait) > find (re-snapshot, retry) > click/type > log
// I/O: Conf + store + CDP Conn (caller) > page actions, log rows, typed errors
// ===================================================================
const std = @import("std"); const conf = @import("cf-conf-load.zig"); const data = @import("st-stat-data.zig"); const pace = @import("ru-huma-pace.zig"); const inpu = @import("ru-huma-inpu.zig"); const snap = @import("ru-page-snap.zig"); const halt = @import("ru-safe-halt.zig"); const cdp = @import("nt-cdpz-sock.zig");
const CF = .{ .gapz = 400 };
pub const Mode = enum { read, dry, live, force };
pub const Sess = struct { gpaz: std.mem.Allocator, iozz: std.Io, aren: std.mem.Allocator, cfg: conf.Conf, sto: *data.Stor, conn: *cdp.Conn, prn: std.Random.DefaultPrng, pos: inpu.Pt = .{ .x = 5, .y = 5 }, mode: Mode = .dry, fast: bool = false, fake_ms: i64 = 0, job: []const u8 = "",
pub fn init(gpaz: std.mem.Allocator, iozz: std.Io, aren: std.mem.Allocator, cfg: conf.Conf, sto: *data.Stor, conn: *cdp.Conn, mode: Mode) Sess { var seed: u64 = cfg.rand_seed_fixd; if (seed == 0) { var rnd: [8]u8 = undefined; iozz.random(&rnd); seed = std.mem.readInt(u64, &rnd, .little); } return .{ .gpaz = gpaz, .iozz = iozz, .aren = aren, .cfg = cfg, .sto = sto, .conn = conn, .prn = std.Random.DefaultPrng.init(seed), .mode = mode }; }
pub fn now(self: *Sess) i64 { if (self.fake_ms != 0) return self.fake_ms; return @intCast(std.Io.Clock.real.now(self.iozz).toMilliseconds()); }
pub fn rand(self: *Sess) std.Random { return self.prn.random(); }
pub fn logz(self: *Sess, lvl: []const u8, msg: []const u8) void { self.sto.logAdd(self.now(), lvl, self.job, msg) catch {}; }
fn nap(self: *Sess, mill: u32) void { if (self.fast) return; std.Io.sleep(self.iozz, .fromMilliseconds(mill), .awake) catch {}; }
pub fn pre(self: *Sess, kind: pace.Kind) !void { try halt.guard(self.aren, self.cfg, self.sto, self.conn, self.now()); const lim = pace.limsOf(self.cfg); var loop: u32 = 0; while (loop < 4) : (loop += 1) { const sta = try self.sto.statGet(self.aren, self.now()); const ver = pace.gate(lim, sta, self.now(), kind); switch (ver.kind) { .go => return, .wait => { if (self.fake_ms != 0) { self.fake_ms += ver.msec; } else self.nap(ver.msec); }, .quie => { self.logz("warn", "quiet hours"); return error.QuietHrs; }, .cap => { self.logz("warn", "cap reached"); return error.CapHit; } } } return error.CapHit; }
pub fn pause(self: *Sess) void { if (self.fast) return; _ = inpu.pauseAct(self.conn, self.rand(), self.cfg.acti_dely_secs[0], self.cfg.acti_dely_secs[1]); }
pub fn readPause(self: *Sess) void { if (self.fast) return; _ = inpu.pauseMsec(self.conn, self.rand(), self.cfg.read_dely_msec[0], self.cfg.read_dely_msec[1]); }
pub fn nodes(self: *Sess) ![]snap.Node { return snap.axSnap(self.aren, self.conn); }
pub fn find(self: *Sess, role: []const u8, name: []const u8) !snap.Node { var cnt: u32 = 0; while (cnt < self.cfg.retr_coun_maxz) : (cnt += 1) { const lst = try self.nodes(); if (snap.findNode(lst, role, name)) |nod| return nod; self.nap(CF.gapz); } const msg = try std.fmt.allocPrint(self.aren, "element missing: {s} {s}", .{ role, name }); self.logz("warn", msg); return error.NoElem; }
pub fn clickNode(self: *Sess, nod: snap.Node) !void { const pnt = try snap.boxCenter(self.aren, self.conn, nod.bid); self.pos = try inpu.clickAt(self.aren, self.conn, self.rand(), self.pos, pnt); }
pub fn typeIn(self: *Sess, text: []const u8) !void { try inpu.typeText(self.aren, self.conn, self.rand(), text, self.cfg.type_dely_msec[0], self.cfg.type_dely_msec[1]); }
pub fn evalNum(self: *Sess, js: []const u8) !i64 { const txt = try snap.evalStr(self.aren, self.conn, js); return std.fmt.parseInt(i64, txt, 10) catch 0; } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
