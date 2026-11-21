// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for nt-vend-base: costs, encoding, base64, redaction
// Flo: call helpers with known values > compare
// I/O: strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
test "credit costs follow the vendor price tables" { try std.testing.expectEqual(@as(u32, 1), base.credCost(.zenr, .plain)); try std.testing.expectEqual(@as(u32, 5), base.credCost(.zenr, .rend)); try std.testing.expectEqual(@as(u32, 25), base.credCost(.zenr, .prem)); try std.testing.expectEqual(@as(u32, 1), base.credCost(.brig, .prem)); }
test "percent-encode keeps unreserved, escapes the rest" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); try std.testing.expectEqualStrings("https%3A%2F%2Fa.com%2Fp%3Fq%3D1%262%20x", try base.pctzEncz(aren.allocator(), "https://a.com/p?q=1&2 x")); try std.testing.expectEqualStrings("a-b_c.d~e", try base.pctzEncz(aren.allocator(), "a-b_c.d~e")); }
test "base64 matches a known value" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); try std.testing.expectEqualStrings("dXNlcjpwYXNz", try base.b64z(aren.allocator(), "user:pass")); }
test "redact removes the key and its encoded form everywhere" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const outp = try base.reda(aren.allocator(), "GET /v1/?apikey=SECRET key&x=1 failed: SECRET%20key", "SECRET key"); try std.testing.expect(std.mem.indexOf(u8, outp, "SECRET") == null); try std.testing.expect(std.mem.indexOf(u8, outp, "***") != null); try std.testing.expectEqualStrings("short", try base.reda(aren.allocator(), "short", "ab")); }
test "vendFind maps names" { try std.testing.expectEqual(base.Vend.zenr, base.vendFind("zenr").?); try std.testing.expect(base.vendFind("nope") == null); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
