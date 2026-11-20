// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for st-page-inde: upsert, read back, log, reopen
// Flo: temp dir > open > set twice > get > log > reopen > assert
// I/O: rows > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const inde = @import("st-page-inde.zig");
test "page upsert keeps one row, values updated, survives reopen" { const allo = std.testing.allocator; var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [160]u8 = undefined; const dirz = try std.fmt.bufPrint(&buff, ".zig-cache/tmp/{s}", .{tmpz.sub_path}); var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); { var dbzz = try inde.pageOpen(allo, std.testing.io, dirz); defer dbzz.close(); try std.testing.expect(try inde.pageGet(&dbzz, aren.allocator(), "http://a/x") == null); const rowz: inde.Row = .{ .hexz = "aa", .etag = "\"e1\"", .lmod = "", .code = 200, .tier = 1, .vend = "", .fetc = 10, .next = 20 }; try inde.pageSet(&dbzz, "http://a/x", rowz); var two = rowz; two.hexz = "bb"; two.fetc = 11; try inde.pageSet(&dbzz, "http://a/x", two); } var dbzz = try inde.pageOpen(allo, std.testing.io, dirz); defer dbzz.close(); const got = (try inde.pageGet(&dbzz, aren.allocator(), "http://a/x")).?; try std.testing.expectEqualStrings("bb", got.hexz); try std.testing.expectEqualStrings("\"e1\"", got.etag); try std.testing.expectEqual(@as(i64, 11), got.fetc); }
test "log rows append" { const allo = std.testing.allocator; var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [160]u8 = undefined; const dirz = try std.fmt.bufPrint(&buff, ".zig-cache/tmp/{s}", .{tmpz.sub_path}); var dbzz = try inde.pageOpen(allo, std.testing.io, dirz); defer dbzz.close(); const rowz: inde.Logz = .{ .urlz = "http://a/x", .code = 200, .tier = 1, .vend = "", .cred = 0, .micr = 0, .robo = "allow", .timz = 1, .note = "" }; try inde.logzAdd(&dbzz, rowz); try inde.logzAdd(&dbzz, rowz); try std.testing.expectEqual(@as(i64, 2), try inde.logzCont(&dbzz)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
