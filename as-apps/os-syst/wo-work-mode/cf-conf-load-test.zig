// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for config parsing and defaults
// Flo: empty JSON = defaults > overrides > unknown keys > bad input > explicit path
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
test "empty object gives every default" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const cfgv = try cfgz.confParse(arna.allocator(), "{}");
try std.testing.expectEqualStrings("as-apps/os-syst/wo-work-mode", cfgv.apps_data_loca);
try std.testing.expectEqualStrings("ci-flow-sync", cfgv.hook_path_main);
try std.testing.expectEqual(@as(i64, 1800), cfgv.wipz_ager_maxz);
try std.testing.expectEqual(@as(i64, 3024000), cfgv.dril_ager_maxz);
try std.testing.expectEqual(@as(i64, 900), cfgv.dril_rtoz_maxz);
try std.testing.expectEqual(@as(usize, 10), cfgv.chek_t0_list.len);
try std.testing.expectEqual(@as(usize, 3), cfgv.chek_ci_list.len);
try std.testing.expectEqual(@as(usize, 0), cfgv.wipz_remo_list.len);
try std.testing.expectEqual(@as(usize, 2), cfgv.kill_step_list.len);
}
test "overrides win, other keys keep defaults, unknown keys are ignored" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const cfgv = try cfgz.confParse(arna.allocator(), "{\"dril_rtoz_maxz\": 60, \"wipz_remo_list\": [\"origin\", \"mirr\"], \"nope\": 1}");
try std.testing.expectEqual(@as(i64, 60), cfgv.dril_rtoz_maxz);
try std.testing.expectEqual(@as(usize, 2), cfgv.wipz_remo_list.len);
try std.testing.expectEqualStrings("mirr", cfgv.wipz_remo_list[1]);
try std.testing.expectEqual(@as(i64, 1800), cfgv.wipz_ager_maxz);
}
test "nested step list parses to argv arrays" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const cfgv = try cfgz.confParse(arna.allocator(), "{\"kill_step_list\": [[\"a\", \"b\"], [\"c\"]]}");
try std.testing.expectEqual(@as(usize, 2), cfgv.kill_step_list.len);
try std.testing.expectEqualStrings("b", cfgv.kill_step_list[0][1]);
try std.testing.expectEqualStrings("c", cfgv.kill_step_list[1][0]);
}
test "bad JSON and wrong types are errors, never silent defaults" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(error.SyntaxError, cfgz.confParse(arna.allocator(), "{not json"));
try std.testing.expectError(error.InvalidCharacter, cfgz.confParse(arna.allocator(), "{\"dril_rtoz_maxz\": \"soon\"}"));
try std.testing.expectError(error.UnexpectedToken, cfgz.confParse(arna.allocator(), "{\"chek_ci_list\": 5}"));
}
test "an explicit missing path is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(error.FileNotFound, cfgz.confLoad(arna.allocator(), std.testing.io, ".zig-cache/no-such-conf.json"));
}
test "the shipped aa-conf-main.json equals the built-in defaults" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const file = cfgz.confLoad(arna.allocator(), std.testing.io, "aa-conf-main.json") catch try cfgz.confLoad(arna.allocator(), std.testing.io, "as-apps/os-syst/wo-work-mode/aa-conf-main.json");
const defa: cfgz.Conf = .{};
try std.testing.expectEqualStrings(defa.apps_data_loca, file.apps_data_loca);
try std.testing.expectEqualStrings(defa.secr_home_loca, file.secr_home_loca);
try std.testing.expectEqualStrings(defa.hook_path_main, file.hook_path_main);
try std.testing.expectEqualStrings(defa.zigz_vers_pinz, file.zigz_vers_pinz);
try std.testing.expectEqual(defa.wipz_ager_maxz, file.wipz_ager_maxz);
try std.testing.expectEqual(defa.bkup_ager_maxz, file.bkup_ager_maxz);
try std.testing.expectEqual(defa.dril_ager_maxz, file.dril_ager_maxz);
try std.testing.expectEqual(defa.dril_rtoz_maxz, file.dril_rtoz_maxz);
try std.testing.expectEqual(defa.tail_days_minz, file.tail_days_minz);
try std.testing.expectEqual(defa.chek_t0_list.len, file.chek_t0_list.len);
try std.testing.expectEqual(defa.chek_ci_list.len, file.chek_ci_list.len);
try std.testing.expectEqual(defa.kill_step_list.len, file.kill_step_list.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
