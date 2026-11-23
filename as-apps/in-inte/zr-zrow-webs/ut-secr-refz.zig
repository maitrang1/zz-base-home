// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read the saved login (email + password) from the secret folder
// Flo: join secret dir + zr-login.json > read file > parse user and pass > error NoSecret if missing or empty
// I/O: secret dir path (caller) > Cred (arena owned); values are never printed or logged
// ===================================================================
const std = @import("std");
const CF = .{ .file = "zr-login.json", .maxz = 4096 };
pub const Cred = struct { user: []const u8 = "", pass: []const u8 = "" };
pub fn credLoad(allo: std.mem.Allocator, iozz: std.Io, dir: []const u8) !Cred { const path = try std.fs.path.join(allo, &.{ dir, CF.file }); const byte = std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(CF.maxz)) catch return error.NoSecret; const cred = std.json.parseFromSliceLeaky(Cred, allo, byte, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch return error.NoSecret; if (cred.user.len == 0 or cred.pass.len == 0) return error.NoSecret; return cred; }
pub fn credSave(iozz: std.Io, allo: std.mem.Allocator, dir: []const u8, user: []const u8, pass: []const u8) !void { try std.Io.Dir.cwd().createDirPath(iozz, dir); const path = try std.fs.path.join(allo, &.{ dir, CF.file }); const body = try std.json.Stringify.valueAlloc(allo, Cred{ .user = user, .pass = pass }, .{}); try std.Io.Dir.cwd().writeFile(iozz, .{ .sub_path = path, .data = body }); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
