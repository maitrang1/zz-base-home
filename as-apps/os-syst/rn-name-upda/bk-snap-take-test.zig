// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for snapshot hashing and writing, and for reading it back
// Flo: known SHA-256 vectors > write/read roundtrip > overwrite > hash check on restore
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const take = @import("bk-snap-take.zig");
const rest = @import("bk-snap-rest.zig");
const fake = @import("te-mach-fake.zig");
test "sha256 known vectors" {
try std.testing.expectEqualStrings("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", &take.hashHex("abc"));
try std.testing.expectEqualStrings("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", &take.hashHex(""));
}
test "one changed byte changes the hash" {
try std.testing.expect(!std.mem.eql(u8, &take.hashHex("abc"), &take.hashHex("abd")));
}
fn dirOf(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir, sub: []const u8) ![]u8 {
const root = try fake.rootOf(allo, tmp);
return std.fmt.allocPrint(allo, "{s}/{s}", .{ root, sub });
}
test "put then get returns the same bytes, nested dir created" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try dirOf(allo, &tmp, "snap/run1");
try take.putz(allo, std.testing.io, dirz, "1.bak", "hello\r\nworld\x00bin");
const hash = take.hashHex("hello\r\nworld\x00bin");
const back = try rest.getz(allo, std.testing.io, dirz, "1.bak", &hash, 1024);
try std.testing.expectEqualStrings("hello\r\nworld\x00bin", back);
}
test "put overwrites a shorter or longer older file fully" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try dirOf(allo, &tmp, "s");
try take.putz(allo, std.testing.io, dirz, "a.bak", "long long long");
try take.putz(allo, std.testing.io, dirz, "a.bak", "short");
const hash = take.hashHex("short");
try std.testing.expectEqualStrings("short", try rest.getz(allo, std.testing.io, dirz, "a.bak", &hash, 1024));
}
test "restore refuses bytes that do not match the journal hash" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try dirOf(allo, &tmp, "s");
try take.putz(allo, std.testing.io, dirz, "a.bak", "tampered");
const hash = take.hashHex("original");
try std.testing.expectError(rest.Erro.HashMismatch, rest.getz(allo, std.testing.io, dirz, "a.bak", &hash, 1024));
}
test "restore of a missing or oversized snapshot is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const dirz = try dirOf(allo, &tmp, "s");
const hash = take.hashHex("x");
try std.testing.expectError(error.FileNotFound, rest.getz(allo, std.testing.io, dirz, "none.bak", &hash, 1024));
try take.putz(allo, std.testing.io, dirz, "big.bak", "0123456789");
try std.testing.expect(std.meta.isError(rest.getz(allo, std.testing.io, dirz, "big.bak", &hash, 5)));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
