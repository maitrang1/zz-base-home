// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests the engine runner on harmless shell commands only
// Flo: parse entries > run exit 0, exit 3, missing exe, bad entry > assert counts
// I/O: strings and child processes > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const spaw = @import("ru-soci-spaw.zig");
const WIND = @import("builtin").os.tag == .windows;
const OKAY: []const u8 = if (WIND) "fbtt|cmd.exe|/d|/c|exit 0" else "fbtt|sh|-c|exit 0"; const FAIL: []const u8 = if (WIND) "zatt|cmd.exe|/d|/c|exit 4" else "zatt|sh|-c|exit 4"; const NOTH: []const u8 = if (WIND) "nott|cmd.exe|/d|/c|exit 3" else "nott|sh|-c|exit 3";
test "entry parse: name, exe, args; bad entries are errors" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const engi = try spaw.engiPars(aren.allocator(), " fb | C:/x/fb.exe | read | --live "); try std.testing.expectEqualStrings("fb", engi.name); try std.testing.expectEqual(@as(usize, 3), engi.argv.len); try std.testing.expectEqualStrings("C:/x/fb.exe", engi.argv[0]); try std.testing.expectEqualStrings("--live", engi.argv[2]); try std.testing.expectError(error.BadConfig, spaw.engiPars(aren.allocator(), "fb")); try std.testing.expectError(error.BadConfig, spaw.engiPars(aren.allocator(), "|x")); try std.testing.expectError(error.BadConfig, spaw.engiPars(aren.allocator(), "fb||x")); }
test "run: exit 0 and 3 (nothing to do) are okay, exit 4 is a failure, missing exe and bad entry are failures, empty list is nothing" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const none = try spaw.spawRunz(aren.allocator(), std.testing.io, &.{}, 30); try std.testing.expectEqual(@as(u32, 0), none.engi + none.fail); const rslt = try spaw.spawRunz(aren.allocator(), std.testing.io, &.{ OKAY, FAIL, NOTH, "gone|no-such-exe-zz9", "bad" }, 30); try std.testing.expectEqual(@as(u32, 4), rslt.engi); try std.testing.expectEqual(@as(u32, 2), rslt.okay); try std.testing.expectEqual(@as(u32, 3), rslt.fail); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
