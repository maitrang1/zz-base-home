// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Atomic write and bounded read for small state files
// Flo: write p.part > rename over p; read with size cap
// I/O: path + bytes (caller) > file on disk, or bytes read
// ===================================================================
const std = @import("std");
const CF = .{ .part = ".part" };
pub fn fileAtom(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, data: []const u8) !void { const cwdz = std.Io.Dir.cwd(); if (std.fs.path.dirname(path)) |dirz| try cwdz.createDirPath(iozz, dirz); const temp = try std.fmt.allocPrint(allo, "{s}{s}", .{ path, CF.part }); defer allo.free(temp); try cwdz.writeFile(iozz, .{ .sub_path = temp, .data = data }); try cwdz.rename(temp, cwdz, path, iozz); }
pub fn fileRead(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, maxz: usize) ![]u8 { return std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(maxz)); }
pub fn fileHas(iozz: std.Io, path: []const u8) bool { _ = std.Io.Dir.cwd().statFile(iozz, path, .{}) catch return false; return true; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
