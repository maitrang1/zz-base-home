// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: The one thin OS file: host rules and native path form
// Flo: pick host rules > turn / into the native separator > expand a leading ~ to home
// I/O: path text > native path text
// ===================================================================
const std = @import("std");
const builtin = @import("builtin");
pub const wind = builtin.os.tag == .windows;
pub const privz: std.Io.File.Permissions = if (wind) .default_file else @fromBackingInt(0o600);
pub fn nati(allo: std.mem.Allocator, path: []const u8) ![]u8 {
const outz = try allo.dupe(u8, path);
if (wind) std.mem.replaceScalar(u8, outz, '/', '\\');
return outz;
}
pub fn home(allo: std.mem.Allocator, path: []const u8, homz: []const u8) ![]u8 {
if (std.mem.eql(u8, path, "~")) return allo.dupe(u8, homz);
if (std.mem.startsWith(u8, path, "~/") or std.mem.startsWith(u8, path, "~\\")) return std.fs.path.join(allo, &.{ homz, path[2..] });
return allo.dupe(u8, path);
}
pub fn absz(path: []const u8) bool {
if (path.len == 0) return false;
if (path[0] == '/' or path[0] == '\\') return true;
return wind and path.len >= 2 and std.ascii.isAlphabetic(path[0]) and path[1] == ':';
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
