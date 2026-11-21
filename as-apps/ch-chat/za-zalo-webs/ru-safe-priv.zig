// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Privacy helpers: owner-only folder permissions, log body redaction
// Flo: Windows icacls (remove inherited, grant owner) or chmod 700 > redact text unless bodies are enabled
// I/O: folder path + user name (caller) > permissions changed; text + flag > text or hash token
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const prob = @import("ru-page-prob.zig");
const CF = .{ .maxo = 8192 };
pub fn ownerOnly(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, user: []const u8) !void { if (builtin.os.tag == .windows) { if (user.len == 0) return error.Fail; const grant = try std.fmt.allocPrint(allo, "{s}:(OI)(CI)F", .{user}); defer allo.free(grant); const res = std.process.run(allo, iozz, .{ .argv = &.{ "icacls", path, "/inheritance:r", "/grant:r", grant }, .stdout_limit = .limited(CF.maxo), .stderr_limit = .limited(CF.maxo) }) catch return error.Fail; defer allo.free(res.stdout); defer allo.free(res.stderr); switch (res.term) { .exited => |code| { if (code != 0) return error.Fail; }, else => return error.Fail } return; } const res = std.process.run(allo, iozz, .{ .argv = &.{ "chmod", "700", path }, .stdout_limit = .limited(CF.maxo), .stderr_limit = .limited(CF.maxo) }) catch return error.Fail; defer allo.free(res.stdout); defer allo.free(res.stderr); switch (res.term) { .exited => |code| { if (code != 0) return error.Fail; }, else => return error.Fail } }
pub fn bodyLog(aren: std.mem.Allocator, text: []const u8, enab: bool) []const u8 { if (enab) return text; return prob.token(aren, text) catch "«h»"; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
