// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the redacted page snapshot
// Flo: capture a mock page > check the JSON file, redaction, names, url redaction
// I/O: none (mock site on loopback, scratch profile) > pass or fail (browser test skips without Chrome)
// Run: cd E:\zz-base-home\as-apps\in-inte\or-orac-webs && zig build test -Dfile=ru-snap-main-test.zig
// ===================================================================
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const snap = @import("ru-snap-main.zig");
test "capture writes redacted JSON and clicks nothing" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); var cx = rig.ctx(.read); cx.statd = try std.fmt.allocPrint(cx.aren, ".zig-cache/tmp/{s}", .{rig.tmpz.sub_path}); const path = try snap.capture(&cx, "/billing/invoices", "Bill Page!"); try std.testing.expect(std.mem.endsWith(u8, path, "bill_page_.json")); const txt = try std.Io.Dir.cwd().readFileAlloc(rig.iozz, path, cx.aren, .limited(1 << 20)); const val = try std.json.parseFromSliceLeaky(std.json.Value, cx.aren, txt, .{}); try std.testing.expect(val.object.get("ax").?.array.items.len > 3); try std.testing.expect(std.mem.find(u8, val.object.get("text").?.string, "Payment history") != null); try std.testing.expectEqual(@as(usize, 0), rig.mock.recCnt()); }
test "safe names and url redaction" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); try std.testing.expectEqualStrings("my_page__1", try snap.safeName(aren.allocator(), "My Page! 1")); try std.testing.expectEqualStrings("x", try snap.safeName(aren.allocator(), "")); try std.testing.expectEqualStrings("https://cloud.oracle.com/keys/#/edit", try snap.redactUrl(aren.allocator(), "https://cloud.oracle.com/keys/1234567890/edit?ref=x&id=555")); try std.testing.expectEqualStrings("https://x/y/12345", try snap.redactUrl(aren.allocator(), "https://x/y/12345")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
