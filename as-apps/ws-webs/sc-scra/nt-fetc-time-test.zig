// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for nt-fetc-time: normal fetch and hard timeout
// Flo: mock server > fetch fast path > fetch /hang with short deadline > wait for worker cleanup
// I/O: mock responses > pass or fail (no leaks)
// Run: zig build test
// ===================================================================
const std = @import("std"); const tmfx = @import("nt-fetc-time.zig"); const fetc = @import("nt-fetc-owns.zig"); const mock = @import("te-mock-serv.zig");
const allo = std.testing.allocator;
test "fast fetch returns the result" { var srv2: mock.Mock = undefined; try srv2.start(std.testing.io); defer srv2.halt(); var buf4: [64]u8 = undefined; var rslt = try tmfx.fetcTime(allo, std.testing.io, srv2.urlzOfzz(&buf4, "/ok"), .{ .priv_allo = true, .time_mill = 5000 }, .{}); defer rslt.free(allo); try std.testing.expectEqual(@as(u16, 200), rslt.code); }
test "typed error crosses the thread" { var srv2: mock.Mock = undefined; try srv2.start(std.testing.io); defer srv2.halt(); var buf4: [64]u8 = undefined; try std.testing.expectError(error.NotText, tmfx.fetcTime(allo, std.testing.io, srv2.urlzOfzz(&buf4, "/img"), .{ .priv_allo = true, .time_mill = 5000 }, .{})); }
test "hanging host times out, worker cleans up after itself" { var srv2: mock.Mock = undefined; try srv2.start(std.testing.io); defer srv2.halt(); var buf4: [64]u8 = undefined; const t0zz = std.Io.Clock.awake.now(std.testing.io).toMilliseconds(); try std.testing.expectError(error.Timeout, tmfx.fetcTime(allo, std.testing.io, srv2.urlzOfzz(&buf4, "/hang"), .{ .priv_allo = true, .time_mill = 600 }, .{})); const used = std.Io.Clock.awake.now(std.testing.io).toMilliseconds() - t0zz; try std.testing.expect(used < 2000); std.Io.sleep(std.testing.io, .fromMilliseconds(3600), .awake) catch {}; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
