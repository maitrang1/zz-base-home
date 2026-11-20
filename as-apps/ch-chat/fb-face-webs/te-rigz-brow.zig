// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Test rig: fake Facebook site + real headless Chrome + one tab
// Flo: find Chrome (skip when absent) > start mock site > launch Chrome on a scratch profile > connect first tab > enable CDP domains
// I/O: none > Rig with mock, page, env helpers (tests only; never touches a real profile or real Facebook)
// ===================================================================
const std = @import("std"); const mockm = @import("te-mock-page.zig"); const chro = @import("nt-brow-chro.zig"); const pg = @import("ru-page-snap.zig"); const pace = @import("ru-huma-pace.zig"); const inpu = @import("ru-huma-inpu.zig"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .boot = 30000, .wsmx = 15000, .conn = 8000, .step = 40000 };
pub const Rig = struct { allo: std.mem.Allocator, iozz: std.Io, tmpz: std.testing.TmpDir, mock: mockm.Mock, brow: chro.Brow, page: pg.Page, aren: std.heap.ArenaAllocator, rng: pace.Rng, conf: cfgz.Conf, bseu: [64]u8 = undefined, bsel: usize = 0,
pub fn up(self: *Rig) !void { self.allo = std.testing.allocator; self.iozz = std.testing.io; const exe = (try chro.exeFind(self.allo, self.iozz, "")) orelse return error.SkipZigTest; defer self.allo.free(exe); self.tmpz = std.testing.tmpDir(.{}); errdefer self.tmpz.cleanup(); try self.mock.start(self.iozz); errdefer self.mock.halt(); var prof: [128]u8 = undefined; const proz = try std.fmt.bufPrint(&prof, ".zig-cache/tmp/{s}/prof", .{self.tmpz.sub_path}); self.brow = try chro.launch(self.allo, self.iozz, exe, proz, true, CF.boot); errdefer self.brow.stop(); const wsp = try chro.pageWs(self.allo, self.iozz, self.brow.port, CF.wsmx); defer self.allo.free(wsp); self.page = try pg.pageOpen(self.allo, self.iozz, self.brow.port, wsp, CF.conn); errdefer self.page.closeConn(); self.aren = std.heap.ArenaAllocator.init(self.allo); errdefer self.aren.deinit(); self.rng = pace.Rng.init(11); self.conf = .{}; self.conf.time_scal_perc = 0; self.conf.mous_step_coun = 4; self.page.arm(CF.step); try self.page.enable(self.aren.allocator()); const bse = self.mock.urlOf(&self.bseu, ""); self.bsel = bse.len; }
pub fn down(self: *Rig) void { self.aren.deinit(); self.page.closeConn(); self.brow.stop(); self.mock.halt(); self.tmpz.cleanup(); }
pub fn base(self: *Rig) []const u8 { return self.bseu[0..self.bsel]; }
pub fn env(self: *Rig) inpu.Env { return .{ .page = &self.page, .rng = &self.rng, .conf = self.conf, .aren = self.aren.allocator() }; }
pub fn go(self: *Rig, path: []const u8) !void { self.page.arm(CF.step); var buf: [160]u8 = undefined; const urlz = try std.fmt.bufPrint(&buf, "{s}{s}", .{ self.base(), path }); try self.page.navigate(self.aren.allocator(), urlz); }
pub fn waitRec(self: *Rig, kind: []const u8, mill: u32) ?[]const u8 { var tries: u32 = 0; while (tries < mill / 50) : (tries += 1) { if (self.mock.recFind(kind)) |rec| return rec; std.Io.sleep(self.iozz, .fromMilliseconds(50), .awake) catch {}; } return null; } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
