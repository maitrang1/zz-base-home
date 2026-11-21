// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for st-lock-main: second run is Busy, stale lock is replaced, release frees it
// Flo: tmp dir > acquire with fake pids > assert
// I/O: lock file > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const lck = @import("st-lock-main.zig"); const file = @import("st-stor-file.zig"); const T = std.testing;
fn pathOf(tmpz: *std.testing.TmpDir, buff: []u8) ![]const u8 { return std.fmt.bufPrint(buff, ".zig-cache/tmp/{s}/sub/za.lock", .{tmpz.sub_path}); }
test "own pid is alive, a huge pid and zero are not" { try T.expect(lck.pidAlive(lck.pidSelf())); try T.expect(!lck.pidAlive(4000000)); try T.expect(!lck.pidAlive(0)); }
test "first acquire works, another live run is Busy, release frees it" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [200]u8 = undefined; const path = try pathOf(&tmpz, &buff); const me = lck.pidSelf(); try lck.acquire(T.allocator, T.io, path, me, 1); try T.expectError(error.Busy, lck.acquire(T.allocator, T.io, path, me + 1, 2)); try T.expect(file.fileHas(T.io, path)); lck.release(T.io, path); try T.expect(!file.fileHas(T.io, path)); try lck.acquire(T.allocator, T.io, path, me + 1, 3); }
test "a lock held by a dead pid is stale and replaced; garbage lock is replaced" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [200]u8 = undefined; const path = try pathOf(&tmpz, &buff); try file.fileAtom(T.allocator, T.io, path, "4000000 5\n"); try lck.acquire(T.allocator, T.io, path, lck.pidSelf(), 9); const txt = try file.fileRead(T.allocator, T.io, path, 64); defer T.allocator.free(txt); try T.expect(std.mem.startsWith(u8, txt, "")); try T.expect(std.mem.find(u8, txt, " 9") != null); try file.fileAtom(T.allocator, T.io, path, "not a pid at all"); try lck.acquire(T.allocator, T.io, path, lck.pidSelf() + 2, 10); }
test "the owner re-acquiring its own lock is allowed" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [200]u8 = undefined; const path = try pathOf(&tmpz, &buff); const me = lck.pidSelf(); try lck.acquire(T.allocator, T.io, path, me, 1); try lck.acquire(T.allocator, T.io, path, me, 2); lck.release(T.io, path); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
