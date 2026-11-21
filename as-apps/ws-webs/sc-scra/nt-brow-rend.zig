// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Local browser session: launch once, render pages, kill on error
// Flo: find exe > launch with own profile on first use > connect tab > navigate + actions > flatten DOM > on any error kill the browser so none is orphaned
// I/O: Conf + profile dir (caller) > Rndr; render(url, wait, selector, actions) > HTML + error count; avail() says if a browser exists
// ===================================================================
const std = @import("std"); const chro = @import("nt-brow-chro.zig"); const pgzz = @import("nt-brow-page.zig"); const acts = @import("nt-brow-acts.zig"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .lnch = 20000 };
pub const Rndr = struct { gpaz: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, exez: []u8, prof: []const u8, brow: ?chro.Brow = null, page: ?pgzz.Page = null, dead: bool = false, rnds: u32 = 0,
pub fn avai(self: *Rndr) bool { return self.exez.len > 0 and !self.dead; }
pub fn reset(self: *Rndr) void { if (self.page) |*pgz2| pgz2.conn.close(); self.page = null; if (self.brow) |*brwz| brwz.stop(); self.brow = null; }
pub fn pageGetz(self: *Rndr) !*pgzz.Page { return self.ensu(); }
fn ensu(self: *Rndr) !*pgzz.Page { if (self.page) |*pgz2| return pgz2; var brwz = try chro.launch(self.gpaz, self.iozz, self.exez, self.prof, !self.conf.brow_head_mode, CF.lnch); errdefer brwz.stop(); const wspz = try chro.pageWszz(self.gpaz, self.iozz, brwz.port, CF.lnch); defer self.gpaz.free(wspz); const pgz2 = try pgzz.pageOpen(self.gpaz, self.iozz, brwz.port, wspz, CF.lnch); self.brow = brwz; self.page = pgz2; return &self.page.?; }
pub fn render(self: *Rndr, aren: std.mem.Allocator, urlz: []const u8, wait: u32, sele: []const u8, act2: acts.Acts) !pgzz.Rend { if (!self.avai()) return error.NoBrowser; const pgz2 = self.ensu() catch |err3| { self.reset(); self.dead = true; return err3; }; self.rnds += 1; const rslt = self.rendOnez(pgz2, aren, urlz, wait, sele, act2) catch |err3| { self.reset(); return err3; }; return rslt; }
fn rendOnez(self: *Rndr, pgz2: *pgzz.Page, aren: std.mem.Allocator, urlz: []const u8, wait: u32, sele: []const u8, act2: acts.Acts) !pgzz.Rend { try pgz2.navigate(aren, urlz, .{ .time_mill = self.conf.brow_time_seco * 1000, .wait = wait, .sele = sele, .blok = self.conf.brow_blok_resz }); var ext2: std.ArrayList(u8) = .empty; if (act2.any()) try acts.run(pgz2, aren, act2, self.conf.cons_sele_list, self.conf.brow_scrl_maxz, &ext2); var rndz = try pgz2.grab(aren); if (ext2.items.len > 0) { const tail = std.mem.findLast(u8, rndz.html, "</body>") orelse rndz.html.len; rndz.html = try std.fmt.allocPrint(aren, "{s}{s}{s}", .{ rndz.html[0..tail], ext2.items, rndz.html[tail..] }); } return rndz; }
pub fn deinit(self: *Rndr) void { self.reset(); self.gpaz.free(self.exez); } };
pub fn rndrInit(gpaz: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, prof: []const u8) !Rndr { const exe2 = (try chro.exezFind(gpaz, iozz, conf.brow_path_exec)) orelse try gpaz.dupe(u8, ""); return .{ .gpaz = gpaz, .iozz = iozz, .conf = conf, .exez = exe2, .prof = prof }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
