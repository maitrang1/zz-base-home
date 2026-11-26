// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Write a file whole or not at all
// Flo: write path.part > rename over path > a kill at any line leaves the old file or the new one
// I/O: path + bytes (caller) > file on disk
// ===================================================================
const std = @import("std");
pub fn put(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, data: []const u8) !void { const temp = try std.fmt.allocPrint(allo, "{s}.part", .{path}); defer allo.free(temp); const cwdz = std.Io.Dir.cwd(); try cwdz.writeFile(iozz, .{ .sub_path = temp, .data = data }); try cwdz.rename(temp, cwdz, path, iozz); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
