// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared vendor types, credit costs, URL encoding, key redaction
// Flo: define Vend/Mode/Req/Rsp/Http/Send > cost table > percent-encode > base64 > redact keys from any text
// I/O: plain values (adapters, ladder) > plain values; no network here
// ===================================================================
const std = @import("std");
pub const Vend = enum { deco, zenr, brig, mock };
pub const Mode = enum(u8) { plain = 2, rend = 3, prem = 4 };
pub const Requ = struct { urlz: []const u8, mode: Mode, geoz: []const u8 = "", wait: u32 = 0, sele: []const u8 = "" };
pub const Hdrz = struct { name: []const u8, valu: []const u8 };
pub const Http = struct { post: bool, urlz: []const u8, auth: []const u8 = "", ctyp: []const u8 = "", body: []const u8 = "", meth: []const u8 = "", ext2: []const Hdrz = &.{} };
pub const Back = struct { code: u16, body: []u8 };
pub const Res2 = struct { code: u16, ctyp: []const u8, body: []const u8, cred: u32, errz: []const u8 };
pub const Send = struct { ctx2: *anyopaque, call: *const fn (ctx2: *anyopaque, gpaz: std.mem.Allocator, iozz: std.Io, http: Http) anyerror!Back };
pub const Backend = struct { ctx2: *anyopaque, call: *const fn (ctx2: *anyopaque, aren: std.mem.Allocator, iozz: std.Io, vend: Vend, req2: Requ) anyerror!Res2 };
pub fn credCost(vend: Vend, mode: Mode) u32 { return switch (vend) { .zenr, .mock => switch (mode) { .plain => 1, .rend => 5, .prem => 25 }, .deco => switch (mode) { .plain => 1, .rend => 2, .prem => 3 }, .brig => 1 }; }
pub fn credRequ(vend: Vend, req2: Requ) u32 { if (req2.geoz.len > 0 and vend == .zenr) return switch (req2.mode) { .plain => 10, .rend, .prem => 25 }; return credCost(vend, req2.mode); }
const GEON = [_][2][]const u8{ .{ "us", "United States" }, .{ "gb", "United Kingdom" }, .{ "de", "Germany" }, .{ "fr", "France" }, .{ "jp", "Japan" }, .{ "vn", "Vietnam" }, .{ "ca", "Canada" }, .{ "au", "Australia" }, .{ "in", "India" }, .{ "br", "Brazil" }, .{ "sg", "Singapore" }, .{ "es", "Spain" }, .{ "it", "Italy" }, .{ "nl", "Netherlands" }, .{ "kr", "South Korea" } };
pub fn geozName(code: []const u8) ?[]const u8 { for (GEON) |row2| if (std.ascii.eqlIgnoreCase(row2[0], code)) return row2[1]; return null; }
pub fn geozOkay(code: []const u8) bool { return code.len == 2 and std.ascii.isAlphabetic(code[0]) and std.ascii.isAlphabetic(code[1]); }
pub fn vendName(vend: Vend) []const u8 { return @tagName(vend); }
pub fn vendFind(name: []const u8) ?Vend { return std.meta.stringToEnum(Vend, name); }
pub fn pctzEncz(aren: std.mem.Allocator, text: []const u8) ![]u8 { var outp: std.ArrayList(u8) = .empty; for (text) |byte| { if (std.ascii.isAlphanumeric(byte) or byte == '-' or byte == '_' or byte == '.' or byte == '~') { try outp.append(aren, byte); } else { try outp.print(aren, "%{X:0>2}", .{byte}); } } return outp.toOwnedSlice(aren); }
pub fn b64z(aren: std.mem.Allocator, text: []const u8) ![]u8 { const enc2 = std.base64.standard.Encoder; const buf4 = try aren.alloc(u8, enc2.calcSize(text.len)); return @constCast(enc2.encode(buf4, text)); }
pub fn reda(aren: std.mem.Allocator, text: []const u8, key2: []const u8) ![]u8 { if (key2.len < 4) return aren.dupe(u8, text); const enc2 = try pctzEncz(aren, key2); var curr = try aren.dupe(u8, text); for ([_][]const u8{ key2, enc2 }) |nee2| { const size = std.mem.replacementSize(u8, curr, nee2, "***"); const nxtz = try aren.alloc(u8, size); _ = std.mem.replace(u8, curr, nee2, "***", nxtz); curr = nxtz; } return curr; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
