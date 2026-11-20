// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for posting on timeline, group and page
// Flo: Vietnamese post > group post uses the group cap > page post needs a url > empty text refused > utf8 cut is safe
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// Run: zig build test -Dfile=ru-post-main-test.zig
// ===================================================================
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const task = @import("ru-task-runn.zig"); const post = @import("ru-post-main.zig"); const dm = @import("ru-dmsg-main.zig");
test "timeline post with Vietnamese text lands exactly" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); var cx = rig.ctx(.live); try std.testing.expectEqual(task.Out.done, try post.postRun(&cx, .{ .text = "Bán xe đạp Thống Nhất, giá 2 triệu" })); try std.testing.expectEqualStrings("Bán xe đạp Thống Nhất, giá 2 triệu", rig.waitRec("post", 3000).?); }
test "group post counts on the group cap, not the post cap" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); var cx = rig.ctx(.live); try std.testing.expectEqual(task.Out.done, try post.postRun(&cx, .{ .text = "Hello group", .url = "/groups/77/" })); _ = rig.waitRec("post", 3000).?; try std.testing.expectEqual(@as(i64, 1), try rig.store.actCnt("grou", 0)); try std.testing.expectEqual(@as(i64, 0), try rig.store.actCnt("post", 0)); }
test "page post goes to the page url on the post cap" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); var cx = rig.ctx(.live); try std.testing.expectError(error.BadUsage, dm.pageRun(&cx, .{ .text = "x" })); try std.testing.expectEqual(task.Out.done, try dm.pageRun(&cx, .{ .text = "Page news", .url = "/" })); try std.testing.expectEqualStrings("Page news", rig.waitRec("post", 3000).?); try std.testing.expectEqual(@as(i64, 1), try rig.store.actCnt("post", 0)); }
test "empty text is refused before anything runs" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); var cx = rig.ctx(.live); try std.testing.expectError(error.BadUsage, post.postRun(&cx, .{})); try std.testing.expectEqual(@as(usize, 0), rig.mock.recCnt()); }
test "utf8 cut never splits a character" { try std.testing.expectEqualStrings("abc", post.cutUtf8("abc", 30)); const cut = post.cutUtf8("đđđđđđ", 5); try std.testing.expect(std.unicode.utf8ValidateSlice(cut)); try std.testing.expectEqual(@as(usize, 4), cut.len); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
