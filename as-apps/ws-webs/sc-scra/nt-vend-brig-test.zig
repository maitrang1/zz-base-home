// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for nt-vend-brig: POST shape, zone required, credits
// Flo: build request > canned replies > assert Rsp
// I/O: canned bodies > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig"); const brig = @import("nt-vend-brig.zig");
const Fake = struct { code: u16, body: []const u8, pub fn send(self: *Fake) base.Send { return .{ .ctx2 = self, .call = cal2 }; } fn cal2(ctx2: *anyopaque, gpaz: std.mem.Allocator, _: std.Io, _: base.Http) anyerror!base.Back { const self: *Fake = @ptrCast(@alignCast(ctx2)); return .{ .code = self.code, .body = try gpaz.dupe(u8, self.body) }; } };
test "request is Bearer + zone/url/raw JSON, zone is required" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const http = try brig.requBuil(aren.allocator(), "TOK", "zone1", .{ .urlz = "https://a.com/", .mode = .plain }); try std.testing.expect(http.post); try std.testing.expectEqualStrings("Bearer TOK", http.auth); try std.testing.expectEqualStrings("{\"zone\":\"zone1\",\"url\":\"https://a.com/\",\"format\":\"raw\"}", http.body); try std.testing.expectError(error.BadConfig, brig.requBuil(aren.allocator(), "TOK", "", .{ .urlz = "https://a.com/", .mode = .plain })); }
test "page body passes with 1 credit in any mode; 4xx and 5xx are free" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); var okzz: Fake = .{ .code = 200, .body = "<html>x</html>" }; const one2 = try brig.call(aren.allocator(), std.testing.allocator, std.testing.io, okzz.send(), "TOK", "z", .{ .urlz = "https://a.com/", .mode = .prem }); try std.testing.expectEqual(@as(u32, 1), one2.cred); var bad: Fake = .{ .code = 502, .body = "bad gateway" }; const two2 = try brig.call(aren.allocator(), std.testing.allocator, std.testing.io, bad.send(), "TOK", "z", .{ .urlz = "https://a.com/", .mode = .plain }); try std.testing.expectEqual(@as(u32, 0), two2.cred); try std.testing.expectEqual(@as(u16, 502), two2.code); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
