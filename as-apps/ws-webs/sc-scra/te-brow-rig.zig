// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared test rig: mock site, mock vendor, ladder, browser
// Flo: temp dir + absolute profile dir > start mock > open index > Rndr > ladder with session
// I/O: Conf (test) > Rig with go(path) and reco(path); skipNo() skips when no Chrome
// ===================================================================
const std = @import("std"); const ladd = @import("ru-tier-ladd.zig"); const inde = @import("st-page-inde.zig"); const pipe = @import("ru-page-fetc.zig"); const vmoc = @import("nt-vend-mock.zig"); const mock = @import("te-mock-serv.zig"); const sqli = @import("st-stor-sqli.zig"); const cfgz = @import("cf-conf-load.zig"); const rend = @import("nt-brow-rend.zig");
const allo = std.testing.allocator;
pub const Rigg = struct { tmpz: std.testing.TmpDir, srv2: mock.Mock, vmkz: vmoc.Mock, dirz: []u8, pro2: []u8, dbzz: sqli.Dbzz, aren: std.heap.ArenaAllocator, rndz: rend.Rndr, ladz: ladd.Ladd,
pub fn upzz(self: *Rigg, con3: cfgz.Conf) !void { var conf = con3; conf.brow_enab = true; conf.vend_free_cred = .{ .deco = 100, .zenr = 100, .brig = 100 }; self.tmpz = std.testing.tmpDir(.{}); self.dirz = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{self.tmpz.sub_path}); const absd = try std.Io.Dir.cwd().realPathFileAlloc(std.testing.io, self.dirz, allo); defer allo.free(absd); self.pro2 = try std.fs.path.join(allo, &.{ absd, "prof" }); try self.srv2.sta2(std.testing.io); self.dbzz = try inde.pageOpen(allo, std.testing.io, self.dirz); self.aren = std.heap.ArenaAllocator.init(allo); self.vmkz = vmoc.Mock.init(allo); self.rndz = try rend.rndrInit(allo, std.testing.io, conf, self.pro2); self.ladz = .{ .gpaz = allo, .iozz = std.testing.io, .conf = conf, .dbzz = &self.dbzz, .dirz = self.dirz, .back = self.vmkz.bac2(), .priv = true, .sess = &self.rndz }; }
pub fn down(self: *Rigg) void { self.rndz.deinit(); std.Io.sleep(std.testing.io, .fromMilliseconds(300), .awake) catch {}; self.vmkz.deinit(); self.aren.deinit(); self.dbzz.close(); self.srv2.halt(); allo.free(self.dirz); allo.free(self.pro2); self.tmpz.cleanup(); }
pub fn skipNozz(self: *Rigg) !void { if (!self.rndz.avai()) { std.debug.print("skipped: no browser\n", .{}); return error.SkipZigTest; } }
pub fn gozz(self: *Rigg, path: []const u8) !pipe.Outc { var buf4: [64]u8 = undefined; return ladd.laddFetc(&self.ladz, self.aren.allocator(), self.srv2.urlzOfzz(&buf4, path)); }
pub fn reco(self: *Rigg, path: []const u8) !?inde.Reco { var buf4: [64]u8 = undefined; return inde.recoGetz(&self.dbzz, self.aren.allocator(), self.srv2.urlzOfzz(&buf4, path)); } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
