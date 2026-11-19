// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for state-file read/write
// Flo: roundtrip > missing > garbage > atomic write leaves no .part > overwrite
// I/O: scratch dir under .zig-cache/tmp > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const stat = @import("st-stat-file.zig");
const make = @import("te-ctxz-make.zig");
test "path building joins home + dir + name.json" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const dirz = try stat.dirzOf(arna.allocator(), "h", ".wo");
const path = try stat.pathOf(arna.allocator(), dirz, "dril");
try std.testing.expect(std.mem.startsWith(u8, path, "h"));
try std.testing.expect(std.mem.endsWith(u8, path, "dril.json"));
try std.testing.expect(std.mem.indexOf(u8, path, ".wo") != null);
}
test "write then read returns the same values" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try make.homeOf(allo, &tmp);
const path = try stat.pathOf(allo, dirz, "dril");
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = 1234, .secs = 77, .okay = true, .note = "n" });
const got = stat.stamRead(allo, std.testing.io, path).?;
try std.testing.expectEqual(@as(i64, 1234), got.when);
try std.testing.expectEqual(@as(i64, 77), got.secs);
try std.testing.expect(got.okay);
try std.testing.expectEqualStrings("n", got.note);
}
test "missing file and garbage file both read as null" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try make.homeOf(allo, &tmp);
const path = try stat.pathOf(allo, dirz, "bad");
try std.testing.expect(stat.stamRead(allo, std.testing.io, path) == null);
try tmp.dir.writeFile(std.testing.io, .{ .sub_path = "bad.json", .data = "{oops" });
try std.testing.expect(stat.stamRead(allo, std.testing.io, path) == null);
}
test "write is atomic: no .part left, second write replaces the first" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try make.homeOf(allo, &tmp);
const path = try stat.pathOf(allo, dirz, "wipz");
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = 1 });
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = 2 });
try std.testing.expectEqual(@as(i64, 2), stat.stamRead(allo, std.testing.io, path).?.when);
const part = try std.fmt.allocPrint(allo, "{s}.part", .{path});
try std.testing.expectError(error.FileNotFound, std.Io.Dir.cwd().statFile(std.testing.io, part, .{}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
