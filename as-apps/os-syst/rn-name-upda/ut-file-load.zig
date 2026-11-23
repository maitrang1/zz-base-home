// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tell text from binary and read UTF-16 files as UTF-8 text
// Flo: look at the first bytes > BOM means UTF-16 > NUL means binary > else UTF-8 > encode back the same way
// I/O: raw bytes > Load {enc, text}; text + enc > raw bytes (BOM kept)
// ===================================================================
const std = @import("std");
const CF = .{ .binz = 8192 };
pub const Enc = enum { utf8, u16le, u16be, binz };
pub const Load = struct { enc: Enc, text: []const u8 };
fn units(allo: std.mem.Allocator, body: []const u8, big: bool) ![]u16 {
const outz = try allo.alloc(u16, body.len / 2);
for (outz, 0..) |*unit, indx| unit.* = std.mem.readInt(u16, body[indx * 2 ..][0..2], if (big) .big else .little);
return outz;
}
pub fn loadz(allo: std.mem.Allocator, raww: []const u8) !Load {
if (raww.len >= 2 and (raww[0] == 0xFF and raww[1] == 0xFE or raww[0] == 0xFE and raww[1] == 0xFF)) {
const big = raww[0] == 0xFE;
const body = raww[2..];
if (body.len % 2 == 0) {
const wide = try units(allo, body, big);
defer allo.free(wide);
if (std.unicode.utf16LeToUtf8Alloc(allo, wide)) |text| return .{ .enc = if (big) .u16be else .u16le, .text = text } else |_| {}
}
return .{ .enc = .binz, .text = raww };
}
if (std.mem.indexOfScalar(u8, raww[0..@min(raww.len, CF.binz)], 0) != null) return .{ .enc = .binz, .text = raww };
return .{ .enc = .utf8, .text = raww };
}
pub fn encode(allo: std.mem.Allocator, enc: Enc, text: []const u8) ![]u8 {
if (enc == .utf8 or enc == .binz) return allo.dupe(u8, text);
const wide = try std.unicode.utf8ToUtf16LeAlloc(allo, text);
defer allo.free(wide);
const big = enc == .u16be;
const outz = try allo.alloc(u8, 2 + wide.len * 2);
outz[0] = if (big) 0xFE else 0xFF;
outz[1] = if (big) 0xFF else 0xFE;
for (wide, 0..) |unit, indx| std.mem.writeInt(u16, outz[2 + indx * 2 ..][0..2], unit, if (big) .big else .little);
return outz;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
