// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: The one thin OS file: path style, case rules
// Flo: pick host rules > compare text by case rule > normalize abs path to forward slashes > back to native form
// I/O: path text + Osys rules > normalized path (E:/a/b or /a/b), native text, case-aware compare
// ===================================================================
const std = @import("std");
const builtin = @import("builtin");
pub const Osys = struct { wind: bool, caze: bool };
pub const host: Osys = .{ .wind = builtin.os.tag == .windows, .caze = builtin.os.tag == .windows or builtin.os.tag == .macos };
pub const Erro = error{NotAbsolute};
pub const privz: std.Io.File.Permissions = if (builtin.os.tag == .windows) .default_file else @fromBackingInt(0o600);
const kern = if (builtin.os.tag == .windows) struct { extern "kernel32" fn GetDriveTypeW(root: [*:0]const u16) callconv(.winapi) u32; } else struct {};
pub fn drivesFixed(allo: std.mem.Allocator) ![][]u8 {
var list: std.ArrayList([]u8) = .empty;
errdefer list.deinit(allo);
if (builtin.os.tag != .windows) return list.toOwnedSlice(allo);
var letr: u8 = 'A';
while (letr <= 'Z') : (letr += 1) {
const wide: [4:0]u16 = .{ letr, ':', '\\', 0 };
if (kern.GetDriveTypeW(&wide) == 3) try list.append(allo, try std.fmt.allocPrint(allo, "{c}:/", .{letr}));
}
return list.toOwnedSlice(allo);
}
pub fn lowr(osy: Osys, byte: u8) u8 { return if (osy.caze) std.ascii.toLower(byte) else byte; }
pub fn eqlz(osy: Osys, left: []const u8, righ: []const u8) bool {
if (left.len != righ.len) return false;
for (left, righ) |lbyt, rbyt| if (lowr(osy, lbyt) != lowr(osy, rbyt)) return false;
return true;
}
pub fn hasPre(osy: Osys, text: []const u8, pref: []const u8) bool { return text.len >= pref.len and eqlz(osy, text[0..pref.len], pref); }
pub fn hasSuf(osy: Osys, text: []const u8, suff: []const u8) bool { return text.len >= suff.len and eqlz(osy, text[text.len - suff.len ..], suff); }
pub fn findz(osy: Osys, text: []const u8, patt: []const u8, from: usize) ?usize {
if (patt.len == 0 or text.len < patt.len or from > text.len - patt.len) return null;
if (!osy.caze) return std.mem.indexOfPos(u8, text, from, patt);
const lastz = text.len - patt.len;
const head = lowr(osy, patt[0]);
var indx = from;
while (indx <= lastz) : (indx += 1) {
if (lowr(osy, text[indx]) != head) continue;
if (eqlz(osy, text[indx .. indx + patt.len], patt)) return indx;
}
return null;
}
fn driveOf(osy: Osys, path: []const u8) bool { return osy.wind and path.len >= 2 and std.ascii.isAlphabetic(path[0]) and path[1] == ':'; }
pub fn isAbso(osy: Osys, path: []const u8) bool { return driveOf(osy, path) and (path.len == 2 or path[2] == '/' or path[2] == '\\') or (path.len > 0 and (path[0] == '/' or (osy.wind and path[0] == '\\'))); }
pub fn normPath(allo: std.mem.Allocator, osy: Osys, path: []const u8) ![]u8 {
const raww = try allo.dupe(u8, path);
defer allo.free(raww);
if (osy.wind) std.mem.replaceScalar(u8, raww, '\\', '/');
var root: []const u8 = undefined;
var rest: []const u8 = undefined;
var drvz: [3]u8 = undefined;
if (driveOf(osy, raww) and (raww.len == 2 or raww[2] == '/')) { drvz = .{ std.ascii.toUpper(raww[0]), ':', '/' }; root = &drvz; rest = raww[@min(3, raww.len)..]; }
else if (osy.wind and std.mem.startsWith(u8, raww, "//")) { root = "//"; rest = raww[2..]; }
else if (raww.len > 0 and raww[0] == '/') { root = "/"; rest = raww[1..]; }
else return Erro.NotAbsolute;
var comp: std.ArrayList([]const u8) = .empty;
defer comp.deinit(allo);
var iter = std.mem.splitScalar(u8, rest, '/');
while (iter.next()) |part| {
if (part.len == 0 or std.mem.eql(u8, part, ".")) continue;
if (std.mem.eql(u8, part, "..")) { _ = comp.pop(); continue; }
try comp.append(allo, part);
}
var outz: std.ArrayList(u8) = .empty;
errdefer outz.deinit(allo);
try outz.appendSlice(allo, root);
for (comp.items, 0..) |part, indx| {
if (indx > 0) try outz.append(allo, '/');
try outz.appendSlice(allo, part);
}
return outz.toOwnedSlice(allo);
}
pub fn natiForm(allo: std.mem.Allocator, osy: Osys, norm: []const u8) ![]u8 {
const outz = try allo.dupe(u8, norm);
if (osy.wind) std.mem.replaceScalar(u8, outz, '/', '\\');
return outz;
}
pub fn dirOf(norm: []const u8) []const u8 {
const slsh = std.mem.lastIndexOfScalar(u8, norm, '/') orelse return norm;
if (slsh == 0) return norm[0..1];
if (slsh == 2 and norm[1] == ':') return norm[0..3];
return norm[0..slsh];
}
pub fn baseOf(norm: []const u8) []const u8 { return norm[(std.mem.lastIndexOfScalar(u8, norm, '/') orelse return norm) + 1 ..]; }
pub fn rootOf(norm: []const u8) []const u8 {
if (norm.len >= 3 and norm[1] == ':' and norm[2] == '/') return norm[0..3];
if (std.mem.startsWith(u8, norm, "//")) return norm[0..2];
return norm[0..1];
}
pub fn insid(osy: Osys, norm: []const u8, base: []const u8) bool { return eqlz(osy, norm, base) or (norm.len > base.len and hasPre(osy, norm, base) and (norm[base.len] == '/' or base[base.len - 1] == '/')); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
