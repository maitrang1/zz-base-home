// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for M10 end to end: PDF over HTTP into the index
// Flo: mock server PDFs > ladder fetch > assert record kind, text, flags, refusal when off
// I/O: mock responses > pass or fail (no leaks)
// Run: zig build test
// ===================================================================
const std = @import("std"); const ladd = @import("ru-tier-ladd.zig"); const inde = @import("st-page-inde.zig"); const pipe = @import("ru-page-fetc.zig"); const vmoc = @import("nt-vend-mock.zig"); const mock = @import("te-mock-serv.zig"); const sqli = @import("st-stor-sqli.zig"); const cfgz = @import("cf-conf-load.zig");
const allo = std.testing.allocator;
const Rigg = struct { tmpz: std.testing.TmpDir, srv2: mock.Mock, vmkz: vmoc.Mock, dirz: []u8, dbzz: sqli.Dbzz, aren: std.heap.ArenaAllocator, ladz: ladd.Ladd,
pub fn upzz(self: *Rigg, conf: cfgz.Conf) !void { self.tmpz = std.testing.tmpDir(.{}); self.dirz = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{self.tmpz.sub_path}); try self.srv2.start(std.testing.io); self.dbzz = try inde.pageOpen(allo, std.testing.io, self.dirz); self.aren = std.heap.ArenaAllocator.init(allo); self.vmkz = vmoc.Mock.init(allo); self.ladz = .{ .gpaz = allo, .iozz = std.testing.io, .conf = conf, .dbzz = &self.dbzz, .dirz = self.dirz, .back = self.vmkz.backend(), .priv = true }; }
pub fn down(self: *Rigg) void { self.vmkz.deinit(); self.aren.deinit(); self.dbzz.close(); self.srv2.halt(); allo.free(self.dirz); self.tmpz.cleanup(); }
pub fn gozz(self: *Rigg, path: []const u8) !pipe.Outc { var buf4: [64]u8 = undefined; return ladd.laddFetc(&self.ladz, self.aren.allocator(), self.srv2.urlzOfzz(&buf4, path)); }
pub fn reco(self: *Rigg, path: []const u8) !?inde.Reco { var buf4: [64]u8 = undefined; return inde.recoGetz(&self.dbzz, self.aren.allocator(), self.srv2.urlzOfzz(&buf4, path)); } };
test "pdf over HTTP: stored once, record kind pdft with the text, free tier" { var rig3: Rigg = undefined; try rig3.upzz(.{}); defer rig3.down(); const out2 = try rig3.gozz("/pdf"); try std.testing.expectEqualStrings("new", out2.stat); try std.testing.expectEqualStrings("pdft", out2.kind); try std.testing.expectEqual(@as(i64, 1), out2.tier); const recz = (try rig3.reco("/pdf")).?; try std.testing.expectEqualStrings("Quarterly report text", recz.body); const again = try rig3.gozz("/pdf"); try std.testing.expectEqualStrings("same", again.stat); try std.testing.expectEqual(@as(usize, 0), rig3.vmkz.calls.items.len); }
test "scanned pdf is stored with kind pdfo (needs OCR)" { var rig3: Rigg = undefined; try rig3.upzz(.{}); defer rig3.down(); const out2 = try rig3.gozz("/pdfscan"); try std.testing.expectEqualStrings("pdfo", out2.kind); }
test "encrypted pdf is rejected with a typed status, nothing stored" { var rig3: Rigg = undefined; try rig3.upzz(.{}); defer rig3.down(); const out2 = try rig3.gozz("/pdfenc"); try std.testing.expectEqualStrings("encr", out2.stat); try std.testing.expect((try rig3.reco("/pdfenc")) == null); }
test "pdfz_size_maxz = 0 refuses PDFs like any non-text type" { var conf: cfgz.Conf = .{}; conf.pdfz_size_maxz = 0; var rig3: Rigg = undefined; try rig3.upzz(conf); defer rig3.down(); try std.testing.expectError(error.NotText, rig3.gozz("/pdf")); }
test "pdf larger than pdfz_size_maxz is refused as TooBig" { var conf: cfgz.Conf = .{}; conf.pdfz_size_maxz = 100; var rig3: Rigg = undefined; try rig3.upzz(conf); defer rig3.down(); try std.testing.expectError(error.TooBig, rig3.gozz("/pdf")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
