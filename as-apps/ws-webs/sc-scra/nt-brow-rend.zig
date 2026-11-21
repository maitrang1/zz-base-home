// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Local browser session: launch once, render pages, kill on error
// Flo: find exe > launch with own profile on first use > connect tab > navigate + actions > flatten DOM > on any error kill the browser so none is orphaned
// I/O: Conf + profile dir (caller) > Rndr; render(url, wait, selector, actions) > HTML + error count; avail() says if a browser exists
// ===================================================================
const std = @import("std"); const chro = @import("nt-brow-chro.zig"); const pg = @import("nt-brow-page.zig"); const acts = @import("nt-brow-acts.zig"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .lnch = 20000 };
pub const Rndr = struct { gpaz: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, exez: []u8, prof: []const u8, brow: ?chro.Brow = null, page: ?pg.Page = null, dead: bool = false, rnds: u32 = 0,
pub fn avail(self: *Rndr) bool { return self.exez.len > 0 and !self.dead; }
pub fn reset(self: *Rndr) void { if (self.page) |*pgz| pgz.conn.close(); self.page = null; if (self.brow) |*brw| brw.stop(); self.brow = null; }
pub fn pageGet(self: *Rndr) !*pg.Page { return self.ensure(); }
fn ensure(self: *Rndr) !*pg.Page { if (self.page) |*pgz| return pgz; var brw = try chro.launch(self.gpaz, self.iozz, self.exez, self.prof, !self.conf.brow_head_mode, CF.lnch); errdefer brw.stop(); const wsp = try chro.pageWs(self.gpaz, self.iozz, brw.port, CF.lnch); defer self.gpaz.free(wsp); const pgz = try pg.pageOpen(self.gpaz, self.iozz, brw.port, wsp, CF.lnch); self.brow = brw; self.page = pgz; return &self.page.?; }
pub fn render(self: *Rndr, aren: std.mem.Allocator, urlz: []const u8, wait: u32, sele: []const u8, act: acts.Acts) !pg.Rend { if (!self.avail()) return error.NoBrowser; const pgz = self.ensure() catch |err| { self.reset(); self.dead = true; return err; }; self.rnds += 1; const res = self.rendOne(pgz, aren, urlz, wait, sele, act) catch |err| { self.reset(); return err; }; return res; }
fn rendOne(self: *Rndr, pgz: *pg.Page, aren: std.mem.Allocator, urlz: []const u8, wait: u32, sele: []const u8, act: acts.Acts) !pg.Rend { try pgz.navigate(aren, urlz, .{ .time_mill = self.conf.brow_time_seco * 1000, .wait = wait, .sele = sele, .blok = self.conf.brow_blok_resz }); var extra: std.ArrayList(u8) = .empty; if (act.any()) try acts.run(pgz, aren, act, self.conf.cons_sele_list, self.conf.brow_scrl_maxz, &extra); var rnd = try pgz.grab(aren); if (extra.items.len > 0) { const tail = std.mem.findLast(u8, rnd.html, "</body>") orelse rnd.html.len; rnd.html = try std.fmt.allocPrint(aren, "{s}{s}{s}", .{ rnd.html[0..tail], extra.items, rnd.html[tail..] }); } return rnd; }
pub fn deinit(self: *Rndr) void { self.reset(); self.gpaz.free(self.exez); } };
pub fn rndrInit(gpaz: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, prof: []const u8) !Rndr { const exe = (try chro.exeFind(gpaz, iozz, conf.brow_path_exec)) orelse try gpaz.dupe(u8, ""); return .{ .gpaz = gpaz, .iozz = iozz, .conf = conf, .exez = exe, .prof = prof }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
