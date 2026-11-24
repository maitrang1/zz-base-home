// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Take a snapshot copy of bytes before any write
// Flo: hash bytes > make snapshot dir > write the copy (private) > sync it to disk
// I/O: bytes + dir + name > .bak file on disk, SHA-256 hex
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
pub fn hashHex(bytes: []const u8) [64]u8 {
var dige: [32]u8 = undefined;
std.crypto.hash.sha2.Sha256.hash(bytes, &dige, .{});
return std.fmt.bytesToHex(dige, .lower);
}
pub fn joinz(allo: std.mem.Allocator, dirz: []const u8, name: []const u8) ![]u8 { return std.fmt.allocPrint(allo, "{s}{c}{s}", .{ dirz, std.fs.path.sep, name }); }
pub fn putz(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8, name: []const u8, bytes: []const u8) !void {
try std.Io.Dir.cwd().createDirPath(iozz, dirz);
const path = try joinz(allo, dirz, name);
defer allo.free(path);
var file = try std.Io.Dir.cwd().createFile(iozz, path, .{ .truncate = true, .permissions = osys.privz });
defer file.close(iozz);
try file.writePositionalAll(iozz, bytes, 0);
try file.sync(iozz);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
