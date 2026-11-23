// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Lowercase text incl. Vietnamese letters, plain substring match
// Flo: decode UTF-8 > map A-Z, Latin-1, Vietnamese caps to lower > write into caller buffer > find needle
// I/O: text bytes (caller) > folded bytes (same length) or bool match
// ===================================================================
const std = @import("std");
pub fn lowCp(cpz: u21) u21 { if (cpz >= 'A' and cpz <= 'Z') return cpz + 32; if (cpz >= 0xC0 and cpz <= 0xDE and cpz != 0xD7) return cpz + 32; if ((cpz >= 0x100 and cpz <= 0x137) or (cpz >= 0x1A0 and cpz <= 0x1B0) or (cpz >= 0x1EA0 and cpz <= 0x1EF9)) { if (cpz == 0x1AF) return 0x1B0; if (cpz % 2 == 0) return cpz + 1; } return cpz; }
pub fn fold(dst: []u8, src: []const u8) []u8 { var pos: usize = 0; var idx: usize = 0; while (idx < src.len and pos < dst.len) { const lenz = std.unicode.utf8ByteSequenceLength(src[idx]) catch { dst[pos] = src[idx]; pos += 1; idx += 1; continue; }; if (idx + lenz > src.len or pos + lenz > dst.len) break; const cpz = std.unicode.utf8Decode(src[idx .. idx + lenz]) catch { dst[pos] = src[idx]; pos += 1; idx += 1; continue; }; const outn = std.unicode.utf8Encode(lowCp(cpz), dst[pos..]) catch break; pos += outn; idx += lenz; } return dst[0..pos]; }
pub fn hasAny(hay: []const u8, list: []const []const u8) bool { for (list) |ned| if (ned.len > 0 and std.mem.find(u8, hay, ned) != null) return true; return false; }
pub fn foldAlloc(allo: std.mem.Allocator, src: []const u8) ![]u8 { const buf = try allo.alloc(u8, src.len); return fold(buf, src); }
pub fn matchAny(allo: std.mem.Allocator, hay: []const u8, needs: []const []const u8) !bool { const lowh = try foldAlloc(allo, hay); defer allo.free(lowh); for (needs) |ned| { const lown = try foldAlloc(allo, ned); defer allo.free(lown); if (lown.len > 0 and std.mem.find(u8, lowh, lown) != null) return true; } return false; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
