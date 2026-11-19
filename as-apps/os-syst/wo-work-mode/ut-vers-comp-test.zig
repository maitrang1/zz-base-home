// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ut-vers-comp: order, missing parts, junk, first token
// Flo: compare pairs > check order
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const vers = @import("ut-vers-comp.zig");
test "numeric order, not text order" {
try std.testing.expectEqual(std.math.Order.lt, vers.versComp("1.9.0", "1.10.0").?);
try std.testing.expectEqual(std.math.Order.gt, vers.versComp("1.104.5", "1.102.1").?);
try std.testing.expectEqual(std.math.Order.eq, vers.versComp("2.1.302", "2.1.302").?);
try std.testing.expectEqual(std.math.Order.lt, vers.versComp("2.1.285", "2.1.302").?);
}
test "missing parts count as zero" {
try std.testing.expectEqual(std.math.Order.eq, vers.versComp("1.2", "1.2.0").?);
try std.testing.expectEqual(std.math.Order.gt, vers.versComp("1.2.1", "1.2").?);
}
test "junk gives null" {
try std.testing.expect(vers.versComp("1.x.0", "1.0.0") == null);
try std.testing.expect(vers.versComp("", "1.0.0") == null);
try std.testing.expect(vers.versComp("1.0.0-rc1", "1.0.0") == null);
}
test "first token of a version line" {
try std.testing.expectEqualStrings("2.1.285", vers.firstTok("2.1.285 (Claude Code)\n"));
try std.testing.expectEqualStrings("1.104.5", vers.firstTok("1.104.5\n  tailscale commit: x"));
try std.testing.expectEqualStrings("", vers.firstTok("  \n"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
