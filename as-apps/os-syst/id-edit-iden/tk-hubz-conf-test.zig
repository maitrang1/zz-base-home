// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the hub config reader
// Flo: port + data dir + lanes parse > longest prefix wins > no lane = empty name > missing keys default
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const hub = @import("tk-hubz-conf.zig");
const osys = @import("ut-osys-adap.zig");
const SAMP = "{\"port\":4001,\"lock_list\":{\"scra\":[\"scra-\"],\"cicd\":[\"cicd-\",\"home-doct\"],\"deep\":[\"cicd-ni\"]},\"apps_data_loca_wind\":\"D:\\\\x\\\\y\",\"apps_data_loca_unix\":\"~/.t/ac\"}";
test "port, data dir and lane list" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const hubz = try hub.parse(arena.allocator(), SAMP, "/home/u");
try std.testing.expectEqual(@as(u16, 4001), hubz.port);
try std.testing.expectEqual(@as(usize, 3), hubz.lanes.len);
if (osys.wind) try std.testing.expectEqualStrings("D:\\x\\y", hubz.data) else try std.testing.expectEqualStrings("/home/u/.t/ac", hubz.data);
}
test "laneOf: exact key, prefix, longest wins, none" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const hubz = try hub.parse(arena.allocator(), SAMP, "/h");
try std.testing.expectEqualStrings("scra", hubz.laneOf("scra-raws"));
try std.testing.expectEqualStrings("cicd", hubz.laneOf("cicd-stat"));
try std.testing.expectEqualStrings("cicd", hubz.laneOf("home-doct"));
try std.testing.expectEqualStrings("deep", hubz.laneOf("cicd-nigh"));
try std.testing.expectEqualStrings("", hubz.laneOf("fb-watc"));
try std.testing.expectEqualStrings("", hubz.laneOf("home-doc"));
}
test "missing keys: default port, empty lanes, empty data" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const hubz = try hub.parse(arena.allocator(), "{}", "/h");
try std.testing.expectEqual(@as(u16, 4000), hubz.port);
try std.testing.expectEqual(@as(usize, 0), hubz.lanes.len);
try std.testing.expectEqualStrings("", hubz.data);
try std.testing.expectEqualStrings("", hubz.laneOf("a"));
}
test "bad json is an error" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
try std.testing.expect(std.meta.isError(hub.parse(arena.allocator(), "[", "/h")));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
