// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for config load and checks
// Flo: defaults > override keys > reject bad values > expand ~
// I/O: JSON text > Conf or BadConfig (no leaks)
// Run: zig build test -Dfile=cf-conf-load-test.zig
// ===================================================================
const std = @import("std"); const cfgz = @import("cf-conf-load.zig");
fn arenNew() std.heap.ArenaAllocator { return std.heap.ArenaAllocator.init(std.testing.allocator); }
test "empty object gives safe defaults" { var aren = arenNew(); defer aren.deinit(); const conf = try cfgz.confParse(aren.allocator(), "{}"); try std.testing.expectEqual(@as(u32, 3), conf.capz_post_dayz); try std.testing.expect(!conf.smar_mode_enab); try std.testing.expectEqual(@as(u32, 14), conf.warm_dayz_coun); }
test "keys override and unknown keys are ignored" { var aren = arenNew(); defer aren.deinit(); const conf = try cfgz.confParse(aren.allocator(), "{\"capz_post_dayz\":1,\"zzzz\":5,\"type_dely_msec\":[10,20]}"); try std.testing.expectEqual(@as(u32, 1), conf.capz_post_dayz); try std.testing.expectEqual(@as(u32, 20), conf.type_dely_msec[1]); }
test "bad values are rejected" { var aren = arenNew(); defer aren.deinit(); const bads = [_][]const u8{ "{\"type_dely_msec\":[300,100]}", "{\"quie_hour_rang\":[25,1]}", "{\"retr_coun_maxz\":0}", "{\"base_urlz_main\":\"ftp://x\"}", "{\"smar_chai_orde\":[\"gpt\"]}", "not json" }; for (bads) |txt| try std.testing.expectError(error.BadConfig, cfgz.confParse(aren.allocator(), txt)); }
test "tilde expands with home, empty home refused" { const allo = std.testing.allocator; const out = try cfgz.pathExpa(allo, "/home/u", "~/.fb-prof"); defer allo.free(out); try std.testing.expectEqualStrings("/home/u/.fb-prof", out); try std.testing.expectError(error.BadConfig, cfgz.pathExpa(allo, "", "~/x")); const abs = try cfgz.pathExpa(allo, "", "/abs/p"); defer allo.free(abs); try std.testing.expectEqualStrings("/abs/p", abs); }
test "data folder mirrors the app path under the tena root, per OS" { const allo = std.testing.allocator; const conf: cfgz.Conf = .{}; try std.testing.expectEqualStrings("E:\\.zz-base-home-tena\\as-apps\\ch-chat\\fb-face-webs", conf.data_loca_wind); try std.testing.expectEqualStrings("~/.zz-base-home-tena/as-apps/ch-chat/fb-face-webs", conf.data_loca_unix); const dir = try cfgz.dataDir(allo, "/home/u", conf); defer allo.free(dir); try std.testing.expect(std.mem.find(u8, dir, "as-apps") != null); const sub = try cfgz.subDir(allo, "/home/u", conf, "stat"); defer allo.free(sub); try std.testing.expect(std.mem.endsWith(u8, sub, "stat")); try std.testing.expect(std.mem.find(u8, sub, ".fb-") == null); }
test "missing config file returns defaults" { var aren = arenNew(); defer aren.deinit(); const conf = try cfgz.confLoad(aren.allocator(), std.testing.io, "no-such-file-zz.json"); try std.testing.expectEqual(@as(u32, 30), conf.capz_comm_dayz); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
