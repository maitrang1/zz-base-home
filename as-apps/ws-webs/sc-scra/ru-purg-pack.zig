// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Pack helpers: read entries, build, name, date, verify one
// Flo: SCRAPK1 magic > per entry: 64 hex hash + u32 length + gzip bytes; runs/ = daily packs (gen 0), keep/ = latest-only packs (gen 1)
// I/O: pack bytes or parts (caller) > entries, new pack bytes, key name, date in ms; entries point into the given bytes
// ===================================================================
const std = @import("std"); const civi = @import("ut-date-civi.zig"); const hash = @import("ut-hash-dedu.zig"); const file = @import("st-stor-file.zig"); const s3v4 = @import("sy-clou-s3v4.zig");
pub const CF = .{ .magi = "SCRAPK1\n", .maxp = 64 << 20, .runs = "runs/", .keep = "keep/", .head = 68 };
pub const Entr = struct { hexz: []const u8, offs: u64, lenz: u64 };
pub const Part = struct { hexz: []const u8, gzzz: []const u8 };
pub fn packPars(aren: std.mem.Allocator, byts: []const u8) ![]Entr { if (byts.len < CF.magi.len or !std.mem.eql(u8, byts[0..CF.magi.len], CF.magi)) return error.BadPack; var list: std.ArrayList(Entr) = .empty; var posi: usize = CF.magi.len; while (posi < byts.len) { if (posi + CF.head > byts.len) return error.BadPack; const hexz = byts[posi .. posi + 64]; if (!hash.hashOkay(hexz)) return error.BadPack; const lenz: usize = std.mem.readInt(u32, byts[posi + 64 ..][0..4], .little); const offs = posi + CF.head; if (offs + lenz > byts.len) return error.BadPack; try list.append(aren, .{ .hexz = hexz, .offs = offs, .lenz = lenz }); posi = offs + lenz; } return list.toOwnedSlice(aren); }
pub fn packBuil(aren: std.mem.Allocator, pars: []const Part) ![]u8 { var outp: std.ArrayList(u8) = .empty; try outp.appendSlice(aren, CF.magi); for (pars) |part| { if (!hash.hashOkay(part.hexz)) return error.BadPack; try outp.appendSlice(aren, part.hexz); var lenb: [4]u8 = undefined; std.mem.writeInt(u32, &lenb, @intCast(part.gzzz.len), .little); try outp.appendSlice(aren, &lenb); try outp.appendSlice(aren, part.gzzz); } return outp.toOwnedSlice(aren); }
pub fn packName(aren: std.mem.Allocator, pref: []const u8, nowz: i64, byts: []const u8) ![]u8 { var dbuf: [16]u8 = undefined; return std.fmt.allocPrint(aren, "{s}{s}-{x}.pack", .{ pref, s3v4.dateNowz(&dbuf, nowz), std.hash.Wyhash.hash(0, byts) & 0xffff }); }
pub fn packDate(key2: []const u8) ?i64 { const slaz = std.mem.lastIndexOfScalar(u8, key2, '/') orelse return null; return civi.civiPars(key2[slaz + 1 ..]); }
pub fn packGenz(key2: []const u8) u8 { return if (std.mem.startsWith(u8, key2, CF.keep)) 1 else 0; }
pub fn partOkay(aren: std.mem.Allocator, hexz: []const u8, gzzz: []const u8) bool { if (!hash.hashOkay(hexz)) return false; const body = file.gzipOpen(aren, gzzz, CF.maxp) catch return false; const back = hash.hashHexz(body); return std.mem.eql(u8, &back, hexz); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
