// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared test rig: mock site, mock vendor, ladder and local browser
// Flo: temp dir + absolute profile dir > start mock > open index > Rndr > ladder with session
// I/O: Conf (test) > Rig with go(path) and reco(path); skipNo() skips when no Chrome
// ===================================================================
const std = @import("std"); const ladd = @import("ru-tier-ladd.zig"); const inde = @import("st-page-inde.zig"); const pipe = @import("ru-page-fetc.zig"); const vmock = @import("nt-vend-mock.zig"); const mock = @import("te-mock-serv.zig"); const sqli = @import("st-stor-sqli.zig"); const cfgz = @import("cf-conf-load.zig"); const rend = @import("nt-brow-rend.zig");
const allo = std.testing.allocator;
pub const Rig = struct { tmpz: std.testing.TmpDir, srv: mock.Mock, vmk: vmock.Mock, dirz: []u8, profd: []u8, dbzz: sqli.Db, aren: std.heap.ArenaAllocator, rnd: rend.Rndr, lad: ladd.Ladd,
pub fn up(self: *Rig, conf0: cfgz.Conf) !void { var conf = conf0; conf.brow_enab = true; conf.vend_free_cred = .{ .deco = 100, .zenr = 100, .brig = 100 }; self.tmpz = std.testing.tmpDir(.{}); self.dirz = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{self.tmpz.sub_path}); const absd = try std.Io.Dir.cwd().realPathFileAlloc(std.testing.io, self.dirz, allo); defer allo.free(absd); self.profd = try std.fs.path.join(allo, &.{ absd, "prof" }); try self.srv.start(std.testing.io); self.dbzz = try inde.pageOpen(allo, std.testing.io, self.dirz); self.aren = std.heap.ArenaAllocator.init(allo); self.vmk = vmock.Mock.init(allo); self.rnd = try rend.rndrInit(allo, std.testing.io, conf, self.profd); self.lad = .{ .gpaz = allo, .iozz = std.testing.io, .conf = conf, .dbzz = &self.dbzz, .dirz = self.dirz, .back = self.vmk.backend(), .priv = true, .sess = &self.rnd }; }
pub fn down(self: *Rig) void { self.rnd.deinit(); std.Io.sleep(std.testing.io, .fromMilliseconds(300), .awake) catch {}; self.vmk.deinit(); self.aren.deinit(); self.dbzz.close(); self.srv.halt(); allo.free(self.dirz); allo.free(self.profd); self.tmpz.cleanup(); }
pub fn skipNo(self: *Rig) !void { if (!self.rnd.avail()) { std.debug.print("skipped: no browser\n", .{}); return error.SkipZigTest; } }
pub fn go(self: *Rig, path: []const u8) !pipe.Outc { var buf: [64]u8 = undefined; return ladd.laddFetc(&self.lad, self.aren.allocator(), self.srv.urlOf(&buf, path)); }
pub fn reco(self: *Rig, path: []const u8) !?inde.Reco { var buf: [64]u8 = undefined; return inde.recoGet(&self.dbzz, self.aren.allocator(), self.srv.urlOf(&buf, path)); } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
