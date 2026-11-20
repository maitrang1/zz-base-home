// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared vendor types, credit costs, URL encoding, key redaction
// Flo: define Vend/Mode/Req/Rsp/Http/Send > cost table > percent-encode > base64 > redact keys from any text
// I/O: plain values (adapters, ladder) > plain values; no network here
// ===================================================================
const std = @import("std");
pub const Vend = enum { deco, zenr, brig, mock };
pub const Mode = enum(u8) { plain = 2, rend = 3, prem = 4 };
pub const Req = struct { urlz: []const u8, mode: Mode, geoz: []const u8 = "", wait: u32 = 0, sele: []const u8 = "" };
pub const Hdr = struct { name: []const u8, valu: []const u8 };
pub const Http = struct { post: bool, urlz: []const u8, auth: []const u8 = "", ctyp: []const u8 = "", body: []const u8 = "", meth: []const u8 = "", extra: []const Hdr = &.{} };
pub const Back = struct { code: u16, body: []u8 };
pub const Rsp = struct { code: u16, ctyp: []const u8, body: []const u8, cred: u32, errz: []const u8 };
pub const Send = struct { ctx: *anyopaque, call: *const fn (ctx: *anyopaque, gpaz: std.mem.Allocator, iozz: std.Io, http: Http) anyerror!Back };
pub const Backend = struct { ctx: *anyopaque, call: *const fn (ctx: *anyopaque, aren: std.mem.Allocator, iozz: std.Io, vend: Vend, req: Req) anyerror!Rsp };
pub fn credCost(vend: Vend, mode: Mode) u32 { return switch (vend) { .zenr, .mock => switch (mode) { .plain => 1, .rend => 5, .prem => 25 }, .deco => switch (mode) { .plain => 1, .rend => 2, .prem => 3 }, .brig => 1 }; }
pub fn credReq(vend: Vend, req: Req) u32 { if (req.geoz.len > 0 and vend == .zenr) return switch (req.mode) { .plain => 10, .rend, .prem => 25 }; return credCost(vend, req.mode); }
const GEON = [_][2][]const u8{ .{ "us", "United States" }, .{ "gb", "United Kingdom" }, .{ "de", "Germany" }, .{ "fr", "France" }, .{ "jp", "Japan" }, .{ "vn", "Vietnam" }, .{ "ca", "Canada" }, .{ "au", "Australia" }, .{ "in", "India" }, .{ "br", "Brazil" }, .{ "sg", "Singapore" }, .{ "es", "Spain" }, .{ "it", "Italy" }, .{ "nl", "Netherlands" }, .{ "kr", "South Korea" } };
pub fn geoName(code: []const u8) ?[]const u8 { for (GEON) |row| if (std.ascii.eqlIgnoreCase(row[0], code)) return row[1]; return null; }
pub fn geoOk(code: []const u8) bool { return code.len == 2 and std.ascii.isAlphabetic(code[0]) and std.ascii.isAlphabetic(code[1]); }
pub fn vendName(vend: Vend) []const u8 { return @tagName(vend); }
pub fn vendFind(name: []const u8) ?Vend { return std.meta.stringToEnum(Vend, name); }
pub fn pctEnc(aren: std.mem.Allocator, text: []const u8) ![]u8 { var outp: std.ArrayList(u8) = .empty; for (text) |byte| { if (std.ascii.isAlphanumeric(byte) or byte == '-' or byte == '_' or byte == '.' or byte == '~') { try outp.append(aren, byte); } else { try outp.print(aren, "%{X:0>2}", .{byte}); } } return outp.toOwnedSlice(aren); }
pub fn b64(aren: std.mem.Allocator, text: []const u8) ![]u8 { const enc = std.base64.standard.Encoder; const buf = try aren.alloc(u8, enc.calcSize(text.len)); return @constCast(enc.encode(buf, text)); }
pub fn redact(aren: std.mem.Allocator, text: []const u8, key: []const u8) ![]u8 { if (key.len < 4) return aren.dupe(u8, text); const enc = try pctEnc(aren, key); var cur = try aren.dupe(u8, text); for ([_][]const u8{ key, enc }) |needle| { const size = std.mem.replacementSize(u8, cur, needle, "***"); const nxt = try aren.alloc(u8, size); _ = std.mem.replace(u8, cur, needle, "***", nxt); cur = nxt; } return cur; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
