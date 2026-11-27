// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Hash bytes, take a private snapshot copy, write a file atomically
// Flo: hash > copy bytes into the snapshot dir (private, synced) > atomic write = temp file then rename over
// I/O: bytes + dir + name > .bak file, SHA-256 hex; bytes + path > file replaced in one step
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
pub fn hashHex(bytes: []const u8) [64]u8 {
var dige: [32]u8 = undefined;
std.crypto.hash.sha2.Sha256.hash(bytes, &dige, .{});
return std.fmt.bytesToHex(dige, .lower);
}
pub fn putz(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8, name: []const u8, bytes: []const u8) !void {
try std.Io.Dir.cwd().createDirPath(iozz, dirz);
const path = try std.fs.path.join(allo, &.{ dirz, name });
defer allo.free(path);
var file = try std.Io.Dir.cwd().createFile(iozz, path, .{ .truncate = true, .permissions = osys.privz });
defer file.close(iozz);
try file.writePositionalAll(iozz, bytes, 0);
try file.sync(iozz);
}
pub fn atom(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, bytes: []const u8) !void {
const temp = try std.fmt.allocPrint(allo, "{s}.ie-tmp", .{path});
defer allo.free(temp);
{
const perm: std.Io.File.Permissions = if (std.Io.Dir.cwd().statFile(iozz, path, .{})) |stz| stz.permissions else |_| .default_file;
var file = try std.Io.Dir.cwd().createFile(iozz, temp, .{ .truncate = true, .permissions = perm });
defer file.close(iozz);
try file.writePositionalAll(iozz, bytes, 0);
try file.sync(iozz);
}
const cwdz = std.Io.Dir.cwd();
try std.Io.Dir.rename(cwdz, temp, cwdz, path, iozz);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
