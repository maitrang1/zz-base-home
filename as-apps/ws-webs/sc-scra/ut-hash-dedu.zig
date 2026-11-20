// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: SHA-256 content hash and hashed file path
// Flo: hash bytes > hex text > split into ab/cd/<hash> path
// I/O: body bytes (caller) > 64-char hex, relative path text
// ===================================================================
const std = @import("std"); const Sha = std.crypto.hash.sha2.Sha256;
pub const Hexz = [64]u8;
pub fn hashHex(body: []const u8) Hexz { var outp: [Sha.digest_length]u8 = undefined; Sha.hash(body, &outp, .{}); return std.fmt.bytesToHex(outp, .lower); }
pub fn hashPath(buff: []u8, hexz: Hexz) ![]u8 { return std.fmt.bufPrint(buff, "{s}/{s}/{s}.gz", .{ hexz[0..2], hexz[2..4], hexz[0..] }); }
pub fn hashOkay(text: []const u8) bool { if (text.len != 64) return false; for (text) |byte| if (!std.ascii.isDigit(byte) and !(byte >= 'a' and byte <= 'f')) return false; return true; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
