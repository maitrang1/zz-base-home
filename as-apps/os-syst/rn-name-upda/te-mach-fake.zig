// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Fake machine in a tmp dir for tests
// Flo: tmp dir > absolute normalized root > put files with parents > read them back
// I/O: TmpDir > root path, files on disk (never the live machine)
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
pub fn rootOf(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir) ![]u8 {
const cwdz = try std.process.currentPathAlloc(std.testing.io, allo);
return osys.normPath(allo, osys.host, try std.fmt.allocPrint(allo, "{s}/.zig-cache/tmp/{s}", .{ cwdz, tmp.sub_path[0..] }));
}
pub fn putz(tmp: *std.testing.TmpDir, sub: []const u8, data: []const u8) !void {
if (std.fs.path.dirname(sub)) |dirn| try tmp.dir.createDirPath(std.testing.io, dirn);
try tmp.dir.writeFile(std.testing.io, .{ .sub_path = sub, .data = data });
}
pub fn dirz(tmp: *std.testing.TmpDir, sub: []const u8) !void { try tmp.dir.createDirPath(std.testing.io, sub); }
pub fn readz(allo: std.mem.Allocator, tmp: *std.testing.TmpDir, sub: []const u8) ![]u8 { return tmp.dir.readFileAlloc(std.testing.io, sub, allo, .limited(1024 * 1024)); }
pub fn dumpz(allo: std.mem.Allocator, tmp: *std.testing.TmpDir, rels: []const []const u8) ![]u8 {
var outz: std.ArrayList(u8) = .empty;
for (rels) |rel| {
try outz.appendSlice(allo, rel);
try outz.append(allo, 0);
const data = readz(allo, tmp, rel) catch { try outz.appendSlice(allo, "<none>"); try outz.append(allo, 0); continue; };
try outz.appendSlice(allo, data);
try outz.append(allo, 0);
}
return outz.toOwnedSlice(allo);
}
pub fn hasz(tmp: *std.testing.TmpDir, rel: []const u8) bool { return if (tmp.dir.statFile(std.testing.io, rel, .{})) |_| true else |_| false; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
