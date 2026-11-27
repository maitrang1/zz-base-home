// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for text/binary detection and UTF-16 round trips
// Flo: plain > BOM LE/BE > NUL > bad UTF-16 > encode back byte-identical
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const ldz = @import("ut-file-load.zig");
fn rtrip(allo: std.mem.Allocator, raww: []const u8, enc: ldz.Enc, text: []const u8) !void {
const load = try ldz.loadz(allo, raww);
try std.testing.expectEqual(enc, load.enc);
try std.testing.expectEqualStrings(text, load.text);
if (enc == .u16le or enc == .u16be) try std.testing.expectEqualSlices(u8, raww, try ldz.encode(allo, enc, load.text));
}
test "plain text and the empty file are utf8" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), "hello\r\nworld", .utf8, "hello\r\nworld");
try rtrip(arna.allocator(), "", .utf8, "");
try rtrip(arna.allocator(), "tệp ✓", .utf8, "tệp ✓");
}
test "UTF-16 LE with BOM decodes and encodes back byte-identical" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), &.{ 0xFF, 0xFE, 'h', 0, 'i', 0, 0x0A, 0 }, .u16le, "hi\n");
}
test "UTF-16 BE with BOM decodes and encodes back byte-identical" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), &.{ 0xFE, 0xFF, 0, 'h', 0, 'i' }, .u16be, "hi");
}
test "BOM only is an empty UTF-16 text" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), &.{ 0xFF, 0xFE }, .u16le, "");
}
test "non-BMP characters survive as surrogate pairs" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const body = try ldz.encode(allo, .u16le, "a😀b");
try std.testing.expectEqual(@as(usize, 2 + 8), body.len);
try rtrip(allo, body, .u16le, "a😀b");
}
test "a NUL in the first bytes means binary, text returned as is" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), "MZ\x00\x01abc", .binz, "MZ\x00\x01abc");
}
test "odd length UTF-16, a lone surrogate, or a lone high byte fall back to binary" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), &.{ 0xFF, 0xFE, 'h', 0, 'i' }, .binz, &.{ 0xFF, 0xFE, 'h', 0, 'i' });
try rtrip(arna.allocator(), &.{ 0xFF, 0xFE, 0x00, 0xD8 }, .binz, &.{ 0xFF, 0xFE, 0x00, 0xD8 });
}
test "a single 0xFF byte alone is plain utf8 text, not a BOM" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try rtrip(arna.allocator(), &.{0xFF}, .utf8, &.{0xFF});
}
test "a NUL after the first 8 KB is not noticed (cap)" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const big = try allo.alloc(u8, 9000);
@memset(big, 'a');
big[8500] = 0;
try std.testing.expectEqual(ldz.Enc.utf8, (try ldz.loadz(allo, big)).enc);
big[8000] = 0;
try std.testing.expectEqual(ldz.Enc.binz, (try ldz.loadz(allo, big)).enc);
}
test "encode of utf8 and binary is a plain copy" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectEqualStrings("abc", try ldz.encode(arna.allocator(), .utf8, "abc"));
try std.testing.expectEqualStrings("a\x00c", try ldz.encode(arna.allocator(), .binz, "a\x00c"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
