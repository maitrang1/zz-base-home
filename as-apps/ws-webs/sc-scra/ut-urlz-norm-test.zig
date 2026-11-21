// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ut-urlz-norm: split, canonical form, bad input
// Flo: normalize sample URLs > compare > feed hostile URLs > expect BadUrl
// I/O: URL strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const urlz = @import("ut-urlz-norm.zig");
fn chek(raws: []const u8, want: []const u8) !void { const gotz = try urlz.urlzNorm(std.testing.allocator, raws); defer std.testing.allocator.free(gotz); try std.testing.expectEqualStrings(want, gotz); }
test "lowercase host, default port, empty path" { try chek("HTTP://Example.COM:80", "http://example.com/"); try chek("https://Example.com:443/a", "https://example.com/a"); try chek("https://example.com:8443/a", "https://example.com:8443/a"); }
test "fragment and tracking params dropped, query sorted" { try chek("https://a.com/p?b=2&utm_source=x&a=1&fbclid=z#top", "https://a.com/p?a=1&b=2"); try chek("https://a.com/p?utm_a=1", "https://a.com/p"); try chek(" https://a.com/x \n", "https://a.com/x"); }
test "same page, different spelling, same key" { const one2 = try urlz.urlzNorm(std.testing.allocator, "https://a.com/p?y=1&x=2"); defer std.testing.allocator.free(one2); const two2 = try urlz.urlzNorm(std.testing.allocator, "HTTPS://A.com:443/p?x=2&y=1&gclid=9#f"); defer std.testing.allocator.free(two2); try std.testing.expectEqualStrings(one2, two2); }
test "ipv6 literal host" { const part = try urlz.urlzSpli("http://[::1]:8080/x"); try std.testing.expectEqualStrings("[::1]", part.host); try std.testing.expectEqual(@as(u16, 8080), part.port); }
test "hostile urls refused" { const bads = [_][]const u8{ "", "ftp://a.com/", "file:///etc/passwd", "javascript:alert(1)", "http://", "http://user:pw@a.com/", "http://a.com:0/", "http://a.com:99999/", "http://a .com/", "//a.com/x", "a.com/x", "http://[::1/x", "http://:80/x" }; for (bads) |badz| try std.testing.expectError(error.BadUrl, urlz.urlzSpli(badz)); const lon2 = "http://a.com/" ++ @as([2100]u8, @splat('x')); try std.testing.expectError(error.BadUrl, urlz.urlzSpli(lon2)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
