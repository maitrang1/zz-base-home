// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Seal and open bytes with XChaCha20-Poly1305, hex key
// Flo: key file missing > make 32 random bytes and write 64 hex chars > seal = magic + nonce + cipher + tag > open checks magic, length and tag
// I/O: bytes + key + associated text (caller) > sealed bytes or the plain bytes; a wrong key, a changed byte or a short blob gives error.BadSeal
// ===================================================================
const std = @import("std");
const Aead = std.crypto.aead.chacha_poly.XChaCha20Poly1305;
pub const CF = .{ .magi = "SCRACT1\n", .keyb = 32, .nonb = 24, .tagb = 16 };
pub fn keyzLoad(aren: std.mem.Allocator, iozz: std.Io, path: []const u8) ![CF.keyb]u8 { const cwdz = std.Io.Dir.cwd(); if (cwdz.readFileAlloc(iozz, path, aren, .limited(256))) |text| { const trim = std.mem.trim(u8, text, " \t\r\n"); if (trim.len != CF.keyb * 2) return error.BadSeal; var keyz: [CF.keyb]u8 = undefined; _ = std.fmt.hexToBytes(&keyz, trim) catch return error.BadSeal; return keyz; } else |_| {} var keyz: [CF.keyb]u8 = undefined; iozz.random(&keyz); if (std.fs.path.dirname(path)) |dirz| try cwdz.createDirPath(iozz, dirz); const hexz = std.fmt.bytesToHex(keyz, .lower); var filz = try cwdz.createFile(iozz, path, .{}); defer filz.close(iozz); try filz.writeStreamingAll(iozz, &hexz); try filz.writeStreamingAll(iozz, "\n"); return keyz; }
pub fn sealPack(aren: std.mem.Allocator, iozz: std.Io, keyz: [CF.keyb]u8, plai: []const u8, adzz: []const u8) ![]u8 { var nonz: [CF.nonb]u8 = undefined; iozz.random(&nonz); const outp = try aren.alloc(u8, CF.magi.len + CF.nonb + plai.len + CF.tagb); @memcpy(outp[0..CF.magi.len], CF.magi); @memcpy(outp[CF.magi.len .. CF.magi.len + CF.nonb], &nonz); const cipz = outp[CF.magi.len + CF.nonb .. CF.magi.len + CF.nonb + plai.len]; var tagz: [CF.tagb]u8 = undefined; Aead.encrypt(cipz, &tagz, plai, adzz, nonz, keyz); @memcpy(outp[outp.len - CF.tagb ..], &tagz); return outp; }
pub fn sealOpen(aren: std.mem.Allocator, keyz: [CF.keyb]u8, blob: []const u8, adzz: []const u8) ![]u8 { if (blob.len < CF.magi.len + CF.nonb + CF.tagb or !std.mem.eql(u8, blob[0..CF.magi.len], CF.magi)) return error.BadSeal; const nonz: [CF.nonb]u8 = blob[CF.magi.len .. CF.magi.len + CF.nonb][0..CF.nonb].*; const cipz = blob[CF.magi.len + CF.nonb .. blob.len - CF.tagb]; const tagz: [CF.tagb]u8 = blob[blob.len - CF.tagb ..][0..CF.tagb].*; const plai = try aren.alloc(u8, cipz.len); Aead.decrypt(plai, cipz, tagz, adzz, nonz, keyz) catch return error.BadSeal; return plai; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
