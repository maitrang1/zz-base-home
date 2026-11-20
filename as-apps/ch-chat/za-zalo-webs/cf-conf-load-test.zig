// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for cf-conf-load: defaults, overrides, bad values
// Flo: parse json text > assert fields and errors
// I/O: json text > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const conf = @import("cf-conf-load.zig");
fn arna() std.heap.ArenaAllocator { return std.heap.ArenaAllocator.init(std.testing.allocator); }
test "empty object gives conservative defaults" { var aren = arna(); defer aren.deinit(); const cfg = try conf.confParse(aren.allocator(), "{}"); try std.testing.expectEqual(@as(u32, 20), cfg.capz_send_hour); try std.testing.expectEqual(@as(u32, 120), cfg.capz_send_dayz); try std.testing.expectEqual(@as(u32, 5), cfg.capz_newc_dayz); try std.testing.expectEqual(@as(u32, 7), cfg.warm_dayz_coun); try std.testing.expect(!cfg.smar_mode_enab); try std.testing.expectEqual(@as(u8, 23), cfg.quie_hour_rang[0]); }
test "values override and unknown keys are ignored" { var aren = arna(); defer aren.deinit(); const cfg = try conf.confParse(aren.allocator(), "{\"capz_send_hour\":10,\"capz_send_dayz\":50,\"nope\":1,\"type_dely_msec\":[100,200]}"); try std.testing.expectEqual(@as(u32, 10), cfg.capz_send_hour); try std.testing.expectEqual(@as(u32, 200), cfg.type_dely_msec[1]); }
test "bad json is BadConfig" { var aren = arna(); defer aren.deinit(); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{oops")); }
test "reversed delay range is BadConfig" { var aren = arna(); defer aren.deinit(); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"type_dely_msec\":[300,100]}")); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"acti_dely_secs\":[0,5]}")); }
test "hour cap above day cap is BadConfig" { var aren = arna(); defer aren.deinit(); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"capz_send_hour\":50,\"capz_send_dayz\":10}")); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"capz_send_hour\":0}")); }
test "quiet hour out of range and send gap below 1s are BadConfig" { var aren = arna(); defer aren.deinit(); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"quie_hour_rang\":[24,6]}")); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"gapz_send_msec\":999}")); }
test "ai chain only accepts clau and llam" { var aren = arna(); defer aren.deinit(); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"smar_chai_orde\":[\"gpt\"]}")); try std.testing.expectError(error.BadConfig, conf.confParse(aren.allocator(), "{\"smar_chai_orde\":[]}")); const cfg = try conf.confParse(aren.allocator(), "{\"smar_chai_orde\":[\"llam\"]}"); try std.testing.expectEqual(@as(usize, 1), cfg.smar_chai_orde.len); }
test "missing file gives defaults" { var aren = arna(); defer aren.deinit(); const cfg = try conf.confLoad(aren.allocator(), std.testing.io, "no-such-za-conf-file.json"); try std.testing.expectEqual(@as(u32, 20), cfg.capz_send_hour); }
test "pathHome expands tilde only at the start" { const allo = std.testing.allocator; const one = try conf.pathHome(allo, "H", "~/x/y"); defer allo.free(one); try std.testing.expectEqualStrings("H" ++ std.fs.path.sep_str ++ "x/y", one); const two = try conf.pathHome(allo, "H", "a/~/b"); defer allo.free(two); try std.testing.expectEqualStrings("a/~/b", two); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
