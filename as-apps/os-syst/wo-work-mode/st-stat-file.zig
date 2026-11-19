// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Small state files (last wipz, backup, drill)
// Flo: build path under HOME > read + parse JSON > or write .part then rename
// I/O: name > Stam {when, secs, okay, note} in ~/<apps_data_loca>/<name>.json
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 64 * 1024 };
pub const Stam = struct { when: i64 = 0, secs: i64 = 0, okay: bool = false, note: []const u8 = "" };
pub fn dirzOf(allo: std.mem.Allocator, home: []const u8, loca: []const u8) ![]u8 { return std.fs.path.join(allo, &.{ home, loca }); }
pub fn pathOf(allo: std.mem.Allocator, dirz: []const u8, name: []const u8) ![]u8 { return std.fmt.allocPrint(allo, "{s}{c}{s}.json", .{ dirz, std.fs.path.sep, name }); }
pub fn stamRead(allo: std.mem.Allocator, iozz: std.Io, path: []const u8) ?Stam {
const data = std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(CF.maxz)) catch return null;
return std.json.parseFromSliceLeaky(Stam, allo, data, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch null;
}
pub fn stamWrit(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8, path: []const u8, stam: Stam) !void {
try std.Io.Dir.cwd().createDirPath(iozz, dirz);
const part = try std.fmt.allocPrint(allo, "{s}.part", .{path});
const body = try std.json.Stringify.valueAlloc(allo, stam, .{});
var file = try std.Io.Dir.cwd().createFile(iozz, part, .{ .truncate = true });
{
errdefer file.close(iozz);
try file.writePositionalAll(iozz, body, 0);
}
file.close(iozz);
try std.Io.Dir.rename(.cwd(), part, .cwd(), path, iozz);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
