// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for nt-safe-guar: private ips, odd hosts, redirect loops
// Flo: feed hostile hosts > expect BlockedHost > public ips pass > loops fail
// I/O: host strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const safe = @import("nt-safe-guar.zig");
test "ipv4 private, loopback, metadata blocked; public passes" { const bads = [_][4]u8{ .{ 127, 0, 0, 1 }, .{ 10, 1, 2, 3 }, .{ 172, 16, 0, 1 }, .{ 172, 31, 255, 255 }, .{ 192, 168, 1, 1 }, .{ 169, 254, 169, 254 }, .{ 0, 0, 0, 0 }, .{ 100, 64, 0, 1 }, .{ 224, 0, 0, 1 }, .{ 255, 255, 255, 255 } }; for (bads) |ipzz| try std.testing.expect(safe.ipv4Bloc(ipzz)); const goo2 = [_][4]u8{ .{ 8, 8, 8, 8 }, .{ 172, 15, 0, 1 }, .{ 172, 32, 0, 1 }, .{ 1, 1, 1, 1 }, .{ 100, 63, 0, 1 } }; for (goo2) |ipzz| try std.testing.expect(!safe.ipv4Bloc(ipzz)); }
test "ipv6 loopback, unique-local, link-local, mapped private blocked" { var addr = @as([16]u8, @splat(0)); addr[15] = 1; try std.testing.expect(safe.ipv6Bloc(addr)); addr[15] = 0; try std.testing.expect(safe.ipv6Bloc(addr)); var ulaz = @as([16]u8, @splat(0)); ulaz[0] = 0xfd; try std.testing.expect(safe.ipv6Bloc(ulaz)); var link = @as([16]u8, @splat(0)); link[0] = 0xfe; link[1] = 0x80; try std.testing.expect(safe.ipv6Bloc(link)); var mapd = @as([16]u8, @splat(0)); mapd[10] = 0xff; mapd[11] = 0xff; mapd[12] = 127; mapd[15] = 1; try std.testing.expect(safe.ipv6Bloc(mapd)); mapd[12] = 8; mapd[13] = 8; mapd[14] = 8; mapd[15] = 8; try std.testing.expect(!safe.ipv6Bloc(mapd)); var pubz = @as([16]u8, @splat(0)); pubz[0] = 0x26; pubz[1] = 0x06; pubz[2] = 0x47; try std.testing.expect(!safe.ipv6Bloc(pubz)); }
test "hostChek refuses literals, odd forms, local names" { const bads = [_][]const u8{ "127.0.0.1", "169.254.169.254", "[::1]", "::1", "localhost", "LOCALHOST", "foo.localhost", "printer.local", "metadata.google.internal", "intranet", "2130706433", "0x7f.0.0.1", "127.1", "10.0.0.1", "", "[fd00::1]" }; for (bads) |bad| try std.testing.expectError(error.BlockedHost, safe.hostChek(std.testing.io, bad, false)); }
test "private allowed only with the test flag" { try safe.hostChek(std.testing.io, "127.0.0.1", true); try safe.hostChek(std.testing.io, "8.8.8.8", false); }
test "redirect loop and hop cap refused" { var hops: safe.Hops = .{ .maxz = 3 }; try hops.visi("http://a/1"); try hops.visi("http://a/2"); try std.testing.expectError(error.RedirectLoop, hops.visi("http://a/1")); try hops.visi("http://a/3"); try std.testing.expectError(error.TooManyRedirects, hops.visi("http://a/4")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
