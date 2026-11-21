// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for pa-shel-dete: shell versus real pages
// Flo: HTML samples > shelChek > assert bool
// I/O: inline HTML > pass or fail (no leaks)
// Run: zig build test
// ===================================================================
const std = @import("std"); const shel = @import("pa-shel-dete.zig");
const allo = std.testing.allocator;
fn chek(page: []const u8) !bool { var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); return shel.shelChek(aren.allocator(), page, 500, &.{}); }
test "empty root div is a shell" { try std.testing.expect(try chek("<html><head><title>x</title></head><body><div id=\"root\"></div><script src=\"/a.js\"></script></body></html>")); }
test "noscript enable javascript hint is a shell" { try std.testing.expect(try chek("<html><body><noscript>You need to enable JavaScript to run this app.</noscript></body></html>")); }
test "iframe-only page is a shell" { try std.testing.expect(try chek("<html><body><iframe src=\"/f\"></iframe></body></html>")); }
test "small plain page without markers is not a shell" { try std.testing.expect(!try chek("<html><body>hello</body></html>")); }
test "long article that still has a root div is not a shell" { var list: std.ArrayList(u8) = .empty; defer list.deinit(allo); try list.appendSlice(allo, "<html><body><div id=\"root\"><p>"); var con2: usize = 0; while (con2 < 30) : (con2 += 1) try list.appendSlice(allo, "Real server rendered words here. "); try list.appendSlice(allo, "</p></div></body></html>"); try std.testing.expect(!try chek(list.items)); }
test "root div with a big embedded data block is not a shell" { var list: std.ArrayList(u8) = .empty; defer list.deinit(allo); try list.appendSlice(allo, "<html><body><div id=\"__next\"></div><script id=\"__NEXT_DATA__\" type=\"application/json\">{\"props\":\""); var con2: usize = 0; while (con2 < 30) : (con2 += 1) try list.appendSlice(allo, "0123456789"); try list.appendSlice(allo, "\"}</script></body></html>"); try std.testing.expect(!try chek(list.items)); }
test "min length is honored" { var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); const page = "<html><body><div id=\"root\">twelve words</div></body></html>"; try std.testing.expect(try shel.shelChek(aren.allocator(), page, 500, &.{})); try std.testing.expect(!try shel.shelChek(aren.allocator(), page, 5, &.{})); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
