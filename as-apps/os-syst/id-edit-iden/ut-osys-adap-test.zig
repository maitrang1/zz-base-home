// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the OS adapter
// Flo: native form > ~ expansion > absolute check
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
test "nati turns / into the host separator" {
const outz = try osys.nati(std.testing.allocator, "a/b/c.txt");
defer std.testing.allocator.free(outz);
try std.testing.expectEqualStrings(if (osys.wind) "a\\b\\c.txt" else "a/b/c.txt", outz);
}
test "home expands ~ and ~/x, leaves everything else" {
const allo = std.testing.allocator;
const one = try osys.home(allo, "~", "/h");
defer allo.free(one);
try std.testing.expectEqualStrings("/h", one);
const two = try osys.home(allo, "~/.t/x", "/h");
defer allo.free(two);
try std.testing.expect(std.mem.startsWith(u8, two, "/h") and std.mem.endsWith(u8, two, "x"));
const thr = try osys.home(allo, "~user/x", "/h");
defer allo.free(thr);
try std.testing.expectEqualStrings("~user/x", thr);
const fou = try osys.home(allo, "rel/x", "/h");
defer allo.free(fou);
try std.testing.expectEqualStrings("rel/x", fou);
}
test "absz: posix root, relative, empty, drive letter only on Windows" {
try std.testing.expect(osys.absz("/x"));
try std.testing.expect(!osys.absz("x/y"));
try std.testing.expect(!osys.absz(""));
try std.testing.expectEqual(osys.wind, osys.absz("C:\\x"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
