// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for pa-stru-data: block finding and type listing
// Flo: scan fixtures > assert kinds > parse types > feed bad JSON
// I/O: HTML strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const stru = @import("pa-stru-data.zig"); const fixt = @import("te-fixt-html.zig");
const allo = std.testing.allocator;
test "shop fixture has one JSON-LD Product" { const list = try stru.blokFind(allo, fixt.shop); defer allo.free(list); try std.testing.expectEqual(@as(usize, 1), list.len); try std.testing.expectEqual(stru.Kind.ldjs, list[0].kind); var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); const typs = try stru.ldjsTyps(aren.allocator(), list[0].json); try std.testing.expectEqual(@as(usize, 1), typs.len); try std.testing.expectEqualStrings("Product", typs[0]); }
test "next data block is found" { const list = try stru.blokFind(allo, fixt.next); defer allo.free(list); try std.testing.expectEqual(@as(usize, 1), list.len); try std.testing.expectEqual(stru.Kind.next, list[0].kind); try std.testing.expect(std.mem.startsWith(u8, list[0].json, "{\"props\"")); }
test "plain scripts and no scripts give nothing" { const none = try stru.blokFind(allo, "<script>var a=1</script><p>x</p>"); defer allo.free(none); try std.testing.expectEqual(@as(usize, 0), none.len); const open = try stru.blokFind(allo, "<script type=\"application/ld+json\">{\"@type\":\"X\"}"); defer allo.free(open); try std.testing.expectEqual(@as(usize, 0), open.len); }
test "graph, arrays and nested types" { var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); const typs = try stru.ldjsTyps(aren.allocator(), "{\"@graph\":[{\"@type\":\"Article\"},{\"@type\":[\"Person\",\"Thing\"]}]}"); try std.testing.expectEqual(@as(usize, 3), typs.len); try std.testing.expectEqualStrings("Article", typs[0]); const arrz = try stru.ldjsTyps(aren.allocator(), "[{\"@type\":\"A\"},{\"@type\":\"B\"}]"); try std.testing.expectEqual(@as(usize, 2), arrz.len); }
test "bad JSON refused, deep nesting capped" { var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); try std.testing.expectError(error.BadJson, stru.ldjsTyps(aren.allocator(), "{not json")); const deep = try stru.ldjsTyps(aren.allocator(), "[[[[[[{\"@type\":\"Deep\"}]]]]]]"); try std.testing.expectEqual(@as(usize, 0), deep.len); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
