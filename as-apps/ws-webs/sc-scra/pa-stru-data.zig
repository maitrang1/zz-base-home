// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Find JSON-LD and embedded JSON blocks in HTML
// Flo: scan script tags > match ld+json or __NEXT_DATA__ > slice content > list types from @type and @graph
// I/O: HTML text (caller) > Blok list (slices into the HTML) and type names
// ===================================================================
const std = @import("std"); const mem2 = std.mem;
const CF = .{ .depz = 3, .maxz = 64 };
pub const Kind = enum { ldjs, next };
pub const Blok = struct { kind: Kind, json: []const u8 };
pub fn blokFind(allo: std.mem.Allocator, html: []const u8) ![]Blok { var list: std.ArrayList(Blok) = .empty; errdefer list.deinit(allo); var indx: usize = 0; while (list.items.len < CF.maxz) { const begz = std.ascii.findIgnoreCasePos(html, indx, "<script") orelse break; const tend = mem2.findScalarPos(u8, html, begz, '>') orelse break; const attr = html[begz..tend]; const endz = std.ascii.findIgnoreCasePos(html, tend, "</script") orelse break; indx = endz + 8; const kind: ?Kind = if (std.ascii.findIgnoreCase(attr, "application/ld+json") != null) .ldjs else if (mem2.find(u8, attr, "__NEXT_DATA__") != null) .next else null; if (kind) |kdzz| try list.append(allo, .{ .kind = kdzz, .json = mem2.trim(u8, html[tend + 1 .. endz], " \t\r\n") }); } return list.toOwnedSlice(allo); }
fn walk(aren: std.mem.Allocator, valu: std.json.Value, list: *std.ArrayList([]const u8), depz: u8) !void { if (depz > CF.depz) return; switch (valu) { .array => |lis2| for (lis2.items) |each| try walk(aren, each, list, depz + 1), .object => |obj2| { if (obj2.get("@type")) |typz| { switch (typz) { .string => |tex2| try list.append(aren, tex2), .array => |lis2| for (lis2.items) |each| { if (each == .string) try list.append(aren, each.string); }, else => {} } } if (obj2.get("@graph")) |grap| try walk(aren, grap, list, depz + 1); }, else => {} } }
pub fn ldjsTyps(aren: std.mem.Allocator, json: []const u8) ![]const []const u8 { const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, json, .{}) catch return error.BadJson; var list: std.ArrayList([]const u8) = .empty; try walk(aren, valu, &list, 0); return list.toOwnedSlice(aren); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
