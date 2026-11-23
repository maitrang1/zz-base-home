// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build every text form a path can take inside files
// Flo: normalized abs path > url, double-slash, native, forward forms > or relative forms from a file dir
// I/O: normalized path (+ file dir) > list of Vari {kind, text}; same shape for old and new
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
pub const Kind = enum { nati, fwds, dbls, urlz, rela, bare, u16l };
pub const Vari = struct { kind: Kind, text: []const u8 };
fn sepSwap(allo: std.mem.Allocator, text: []const u8, with: []const u8) ![]u8 {
var outz: std.ArrayList(u8) = .empty;
errdefer outz.deinit(allo);
for (text) |byte| { if (byte == '/') try outz.appendSlice(allo, with) else try outz.append(allo, byte); }
return outz.toOwnedSlice(allo);
}
pub fn u16Vari(allo: std.mem.Allocator, list: []const Vari) ![]Vari {
var outz: std.ArrayList(Vari) = .empty;
errdefer outz.deinit(allo);
for (list) |item| {
if (item.kind != .nati and item.kind != .fwds) continue;
const wide = try std.unicode.utf8ToUtf16LeAlloc(allo, item.text);
try outz.append(allo, .{ .kind = .u16l, .text = std.mem.sliceAsBytes(wide) });
}
return outz.toOwnedSlice(allo);
}
pub fn absVari(allo: std.mem.Allocator, osy: osys.Osys, norm: []const u8) ![]Vari {
var list: std.ArrayList(Vari) = .empty;
errdefer list.deinit(allo);
var urlz: std.ArrayList(u8) = .empty;
try urlz.appendSlice(allo, if (osy.wind) "file:///" else "file://");
for (norm) |byte| { if (byte == ' ') try urlz.appendSlice(allo, "%20") else try urlz.append(allo, byte); }
try list.append(allo, .{ .kind = .urlz, .text = try urlz.toOwnedSlice(allo) });
if (osy.wind) {
try list.append(allo, .{ .kind = .dbls, .text = try sepSwap(allo, norm, "\\\\") });
try list.append(allo, .{ .kind = .nati, .text = try sepSwap(allo, norm, "\\") });
}
try list.append(allo, .{ .kind = .fwds, .text = try allo.dupe(u8, norm) });
return list.toOwnedSlice(allo);
}
fn comps(allo: std.mem.Allocator, norm: []const u8) ![][]const u8 {
var list: std.ArrayList([]const u8) = .empty;
errdefer list.deinit(allo);
var iter = std.mem.splitScalar(u8, norm[osys.rootOf(norm).len..], '/');
while (iter.next()) |part| { if (part.len > 0) try list.append(allo, part); }
return list.toOwnedSlice(allo);
}
pub fn relaVari(allo: std.mem.Allocator, osy: osys.Osys, dirz: []const u8, norm: []const u8) ![]Vari {
if (!osys.eqlz(osy, osys.rootOf(dirz), osys.rootOf(norm))) return &.{};
const dirc = try comps(allo, dirz);
defer allo.free(dirc);
const tgtc = try comps(allo, norm);
defer allo.free(tgtc);
var comn: usize = 0;
while (comn < dirc.len and comn < tgtc.len and osys.eqlz(osy, dirc[comn], tgtc[comn])) : (comn += 1) {}
const upsz = dirc.len - comn;
const rest = tgtc[comn..];
if (rest.len == 0) return &.{};
var body: std.ArrayList(u8) = .empty;
defer body.deinit(allo);
for (0..upsz) |_| try body.appendSlice(allo, "../");
for (rest, 0..) |part, indx| { if (indx > 0) try body.append(allo, '/'); try body.appendSlice(allo, part); }
var list: std.ArrayList(Vari) = .empty;
errdefer list.deinit(allo);
const fwdz = body.items;
if (upsz == 0) {
try list.append(allo, .{ .kind = .rela, .text = try std.fmt.allocPrint(allo, "./{s}", .{fwdz}) });
if (osy.wind) try list.append(allo, .{ .kind = .rela, .text = try std.fmt.allocPrint(allo, ".\\{s}", .{try sepSwap(allo, fwdz, "\\")}) });
const plan: Kind = if (rest.len > 1) .rela else .bare;
try list.append(allo, .{ .kind = plan, .text = try allo.dupe(u8, fwdz) });
if (osy.wind and rest.len > 1) try list.append(allo, .{ .kind = .rela, .text = try sepSwap(allo, fwdz, "\\") });
} else {
try list.append(allo, .{ .kind = .rela, .text = try allo.dupe(u8, fwdz) });
if (osy.wind) try list.append(allo, .{ .kind = .rela, .text = try sepSwap(allo, fwdz, "\\") });
}
return list.toOwnedSlice(allo);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
