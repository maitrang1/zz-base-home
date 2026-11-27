// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the sc-scra run lock
// Flo: temp dir > take twice > stale and garbage files > assert refusal or takeover
// I/O: temp dirs only
// Run: zig build test -Dfile=ru-lock-main-test.zig
// ===================================================================
const std = @import("std"); const lock = @import("ru-lock-main.zig");
const allo = std.testing.allocator;
fn dirOf(tmpz: *std.testing.TmpDir) ![]u8 { return std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{tmpz.sub_path}); }
test "second take is refused while the first is held; release frees it" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try dirOf(&tmpz); defer allo.free(dir); var one = try lock.take(allo, std.testing.io, dir); try std.testing.expectError(error.Locked, lock.take(allo, std.testing.io, dir)); one.release(); var two = try lock.take(allo, std.testing.io, dir); two.release(); }
test "a stale lock from a dead pid is replaced" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try dirOf(&tmpz); defer allo.free(dir); const pth = try std.fmt.allocPrint(allo, "{s}/scra.lock", .{dir}); defer allo.free(pth); try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = pth, .data = "3999999" }); var got = try lock.take(allo, std.testing.io, dir); got.release(); }
test "a garbage lock file counts as stale" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try dirOf(&tmpz); defer allo.free(dir); const pth = try std.fmt.allocPrint(allo, "{s}/scra.lock", .{dir}); defer allo.free(pth); try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = pth, .data = "not a pid" }); var got = try lock.take(allo, std.testing.io, dir); got.release(); }
test "our own pid is alive, pid 0 is not" { try std.testing.expect(lock.pidAlive(lock.pidSelf())); try std.testing.expect(!lock.pidAlive(0)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
