// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Hand-rolled UUIDv7 ids, time sortable
// Flo: 48-bit ms + random bits > set version 7 + variant > hex text
// I/O: now ms + random bytes (caller) > 36-char uuid text
// ===================================================================
const std = @import("std");
pub fn uuidSeve(now_ms: i64, rand: [10]u8) [36]u8 { var raw: [16]u8 = undefined; const msec: u64 = @intCast(@max(0, now_ms)); raw[0] = @truncate(msec >> 40); raw[1] = @truncate(msec >> 32); raw[2] = @truncate(msec >> 24); raw[3] = @truncate(msec >> 16); raw[4] = @truncate(msec >> 8); raw[5] = @truncate(msec); @memcpy(raw[6..16], &rand); raw[6] = (raw[6] & 0x0f) | 0x70; raw[8] = (raw[8] & 0x3f) | 0x80; var out: [36]u8 = undefined; const hexz = "0123456789abcdef"; var pos: usize = 0; for (raw, 0..) |byt, idx| { if (idx == 4 or idx == 6 or idx == 8 or idx == 10) { out[pos] = '-'; pos += 1; } out[pos] = hexz[byt >> 4]; out[pos + 1] = hexz[byt & 15]; pos += 2; } return out; }
pub fn uuidNew(iozz: std.Io, now_ms: i64) [36]u8 { var rnd: [10]u8 = undefined; iozz.random(&rnd); return uuidSeve(now_ms, rnd); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
