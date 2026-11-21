// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for cf-conf-load: defaults, parse, bad values
// Flo: arena > parse json strings > assert values or BadConfig
// I/O: json text > Conf or error
// Run: zig build test
// ===================================================================
const std = @import("std"); const cfgz = @import("cf-conf-load.zig");
fn arenNewz() std.heap.ArenaAllocator { return std.heap.ArenaAllocator.init(std.testing.allocator); }
test "defaults are free-only" { const conf: cfgz.Conf = .{}; try std.testing.expectEqual(@as(u64, 0), cfgz.capzMicr(conf)); try std.testing.expectEqualStrings("purg", conf.clou_poli_mode); try std.testing.expect(!conf.logi_mode_enab); try cfgz.confChek(conf); }
test "parse keeps given keys and ignores unknown" { var aren = arenNewz(); defer aren.deinit(); const conf = try cfgz.confPars(aren.allocator(), "{\"capz_usdz_mont\": 1.5, \"vend_orde\": [\"zenr\"], \"unkn_keyz\": 1}"); try std.testing.expectEqual(@as(u64, 1500000), cfgz.capzMicr(conf)); try std.testing.expectEqual(@as(usize, 1), conf.vend_orde.len); try std.testing.expectEqual(@as(u32, 30), conf.fetc_time_seco); }
test "bad values are refused" { var aren = arenNewz(); defer aren.deinit(); const allo = aren.allocator(); const bads = [_][]const u8{ "{\"capz_usdz_mont\": -1}", "{\"clou_poli_mode\": \"drop\"}", "{\"vend_orde\": []}", "{\"vend_orde\": [\"nope\"]}", "{\"fetc_time_seco\": 0}", "{\"capz_disk_gbyt\": 0}", "not json", "{\"logi_mode_enab\": 7}" }; for (bads) |bad| try std.testing.expectError(error.BadConfig, cfgz.confPars(allo, bad)); }
test "missing file gives defaults" { var aren = arenNewz(); defer aren.deinit(); const conf = try cfgz.confLoad(aren.allocator(), std.testing.io, "no-such-dir/aa-conf-main.json"); try std.testing.expectEqual(@as(u32, 5), conf.capz_disk_gbyt); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
