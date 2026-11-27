// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for hash, snapshot copy and atomic write
// Flo: known SHA-256 > snapshot bytes equal > atomic write replaces, leaves no temp file > missing parent errors
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const snap = @import("bk-snap-take.zig");
const fk = @import("te-fake-repo.zig");
test "hashHex of abc matches the SHA-256 vector" {
const hex = snap.hashHex("abc");
try std.testing.expectEqualStrings("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", &hex);
}
test "putz copies bytes exactly, atom replaces a file and leaves no temp" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const base = try fk.tmpPath(allo, &tmp.sub_path);
try snap.putz(allo, std.testing.io, try std.fs.path.join(allo, &.{ base, "s", "1" }), "0.bak", "old\x00bytes\r\n");
try std.testing.expectEqualStrings("old\x00bytes\r\n", try fk.get(allo, std.testing.io, base, "s/1/0.bak"));
try fk.put(allo, std.testing.io, base, "f.txt", "before");
try snap.atom(allo, std.testing.io, try std.fs.path.join(allo, &.{ base, "f.txt" }), "after");
try std.testing.expectEqualStrings("after", try fk.get(allo, std.testing.io, base, "f.txt"));
try std.testing.expect(!fk.has(allo, std.testing.io, base, "f.txt.ie-tmp"));
}
test "atom into a missing folder fails and writes nothing" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const base = try fk.tmpPath(allo, &tmp.sub_path);
try std.testing.expect(std.meta.isError(snap.atom(allo, std.testing.io, try std.fs.path.join(allo, &.{ base, "nope", "f.txt" }), "x")));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
