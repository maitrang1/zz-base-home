// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for M10 end to end: PDF over HTTP into the index
// Flo: mock server PDFs > ladder fetch > assert record kind, text, flags, refusal when off
// I/O: mock responses > pass or fail (no leaks)
// Run: zig build test
// ===================================================================
const std = @import("std"); const ladd = @import("ru-tier-ladd.zig"); const inde = @import("st-page-inde.zig"); const pipe = @import("ru-page-fetc.zig"); const vmock = @import("nt-vend-mock.zig"); const mock = @import("te-mock-serv.zig"); const sqli = @import("st-stor-sqli.zig"); const cfgz = @import("cf-conf-load.zig");
const allo = std.testing.allocator;
const Rig = struct { tmpz: std.testing.TmpDir, srv: mock.Mock, vmk: vmock.Mock, dirz: []u8, dbzz: sqli.Db, aren: std.heap.ArenaAllocator, lad: ladd.Ladd,
pub fn up(self: *Rig, conf: cfgz.Conf) !void { self.tmpz = std.testing.tmpDir(.{}); self.dirz = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{self.tmpz.sub_path}); try self.srv.start(std.testing.io); self.dbzz = try inde.pageOpen(allo, std.testing.io, self.dirz); self.aren = std.heap.ArenaAllocator.init(allo); self.vmk = vmock.Mock.init(allo); self.lad = .{ .gpaz = allo, .iozz = std.testing.io, .conf = conf, .dbzz = &self.dbzz, .dirz = self.dirz, .back = self.vmk.backend(), .priv = true }; }
pub fn down(self: *Rig) void { self.vmk.deinit(); self.aren.deinit(); self.dbzz.close(); self.srv.halt(); allo.free(self.dirz); self.tmpz.cleanup(); }
pub fn go(self: *Rig, path: []const u8) !pipe.Outc { var buf: [64]u8 = undefined; return ladd.laddFetc(&self.lad, self.aren.allocator(), self.srv.urlOf(&buf, path)); }
pub fn reco(self: *Rig, path: []const u8) !?inde.Reco { var buf: [64]u8 = undefined; return inde.recoGet(&self.dbzz, self.aren.allocator(), self.srv.urlOf(&buf, path)); } };
test "pdf over HTTP: stored once, record kind pdft with the text, free tier" { var rig: Rig = undefined; try rig.up(.{}); defer rig.down(); const out = try rig.go("/pdf"); try std.testing.expectEqualStrings("new", out.stat); try std.testing.expectEqualStrings("pdft", out.kind); try std.testing.expectEqual(@as(i64, 1), out.tier); const rec = (try rig.reco("/pdf")).?; try std.testing.expectEqualStrings("Quarterly report text", rec.body); const again = try rig.go("/pdf"); try std.testing.expectEqualStrings("same", again.stat); try std.testing.expectEqual(@as(usize, 0), rig.vmk.calls.items.len); }
test "scanned pdf is stored with kind pdfo (needs OCR)" { var rig: Rig = undefined; try rig.up(.{}); defer rig.down(); const out = try rig.go("/pdfscan"); try std.testing.expectEqualStrings("pdfo", out.kind); }
test "encrypted pdf is rejected with a typed status, nothing stored" { var rig: Rig = undefined; try rig.up(.{}); defer rig.down(); const out = try rig.go("/pdfenc"); try std.testing.expectEqualStrings("encr", out.stat); try std.testing.expect((try rig.reco("/pdfenc")) == null); }
test "pdfz_size_maxz = 0 refuses PDFs like any non-text type" { var conf: cfgz.Conf = .{}; conf.pdfz_size_maxz = 0; var rig: Rig = undefined; try rig.up(conf); defer rig.down(); try std.testing.expectError(error.NotText, rig.go("/pdf")); }
test "pdf larger than pdfz_size_maxz is refused as TooBig" { var conf: cfgz.Conf = .{}; conf.pdfz_size_maxz = 100; var rig: Rig = undefined; try rig.up(conf); defer rig.down(); try std.testing.expectError(error.TooBig, rig.go("/pdf")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
