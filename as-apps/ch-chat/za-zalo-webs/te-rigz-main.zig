// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Test rig: simulator in headless Chrome, memory store
// Flo: up (tmp profile, sim html, store) > ses (fast, fake noon) > js (page eval) > down (stop all)
// I/O: scratch dir (test) > Rig with live CDP link and Sess factory
// ===================================================================
const std = @import("std"); const mock = @import("te-mock-page.zig"); const zsim = @import("te-zsim-page.zig"); const sess = @import("ru-sess-ctxz.zig"); const data = @import("st-stat-data.zig"); const conf = @import("cf-conf-load.zig"); const lab = @import("cf-labl-load.zig"); const snap = @import("ru-page-snap.zig");
pub const NOON: i64 = 100 * 86400000 + 12 * 3600000;
pub const SIM_EXT: lab.Ext = .{ .msg_sel = "#thread [role=article]", .id_atr = "data-id", .dir_atr = "data-dir", .kind_atr = "data-kind", .time_atr = "data-time", .quot_atr = "data-quote", .scrl_sel = "#thread", .list_sel = "#list", .chat_sel = "#list [role=listitem]", .chat_nam_atr = "data-name", .chat_unr_atr = "data-unread", .chat_fri_atr = "data-friend", .chat_grp_atr = "data-group", .comp_sel = "#box", .fail_atr = "data-failed" };
pub fn cfgOf() conf.Conf { var cfg: conf.Conf = .{}; cfg.type_dely_msec = .{ 1, 2 }; cfg.warm_dayz_coun = 0; cfg.retr_coun_maxz = 3; cfg.read_dely_msec = .{ 1, 2 }; return cfg; }
pub const Rig = struct { tmpz: std.testing.TmpDir, mok: mock.Mock, aren: std.heap.ArenaAllocator, sto: data.Stor,
pub fn up(self: *Rig, buff: []u8) !void { self.tmpz = std.testing.tmpDir(.{}); self.aren = std.heap.ArenaAllocator.init(std.testing.allocator); const page = try zsim.html(self.aren.allocator()); self.mok = try mock.start(std.testing.allocator, std.testing.io, try std.fmt.bufPrint(buff, ".zig-cache/tmp/{s}/prof", .{self.tmpz.sub_path}), page); self.sto = try data.Stor.open(std.testing.allocator, ":memory:"); }
pub fn down(self: *Rig) void { self.sto.close(); self.mok.stop(); self.aren.deinit(); self.tmpz.cleanup(); }
pub fn ses(self: *Rig, cfg: conf.Conf, mode: sess.Mode) sess.Sess { var out = sess.Sess.init(std.testing.allocator, std.testing.io, self.aren.allocator(), cfg, &self.sto, self.mok.conn, mode); out.fast = true; out.fake_ms = NOON; out.job = "test"; out.reg.ext = SIM_EXT; return out; }
pub fn js(self: *Rig, code: []const u8) ![]const u8 { return snap.evalStr(self.aren.allocator(), self.mok.conn, code); }
pub fn num(self: *Rig, code: []const u8) !i64 { return std.fmt.parseInt(i64, try self.js(code), 10) catch -1; } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
