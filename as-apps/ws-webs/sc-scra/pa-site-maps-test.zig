// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for pa-site-maps: urlset, index, entities, caps
// Flo: parse fixtures > compare URL lists
// I/O: XML strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const smap = @import("pa-site-maps.zig"); const fixt = @import("te-fixt-html.zig");
test "urlset gives trimmed, decoded, CDATA-free URLs" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const rslt = try smap.smapPars(aren.allocator(), fixt.smap, 100); try std.testing.expect(!rslt.indx); try std.testing.expectEqual(@as(usize, 3), rslt.urls.len); try std.testing.expectEqualStrings("https://example.com/a", rslt.urls[0]); try std.testing.expectEqualStrings("https://example.com/b?x=1&y=2", rslt.urls[1]); try std.testing.expectEqualStrings("https://example.com/c", rslt.urls[2]); }
test "sitemap index is flagged" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const rslt = try smap.smapPars(aren.allocator(), fixt.smix, 100); try std.testing.expect(rslt.indx); try std.testing.expectEqual(@as(usize, 2), rslt.urls.len); }
test "count cap, bad schemes dropped, truncated xml safe" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const cap2 = try smap.smapPars(aren.allocator(), fixt.smap, 2); try std.testing.expectEqual(@as(usize, 2), cap2.urls.len); const bad = try smap.smapPars(aren.allocator(), "<urlset><url><loc>javascript:x</loc></url><url><loc>file:///etc/passwd</loc></url><url><loc>http://ok.com/</loc></url><url><loc>http://cut", 100); try std.testing.expectEqual(@as(usize, 1), bad.urls.len); const none = try smap.smapPars(aren.allocator(), "", 100); try std.testing.expectEqual(@as(usize, 0), none.urls.len); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
