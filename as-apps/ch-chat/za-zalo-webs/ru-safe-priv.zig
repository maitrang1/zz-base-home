// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Privacy helpers: owner-only folder permissions, log body redaction
// Flo: Windows: owner SID > grant owner first > then drop inherited rights; other OS: chmod 700 > redact text unless bodies are enabled
// I/O: folder path + owner id (caller) > permissions changed; text + flag > text or hash token
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const prob = @import("ru-page-prob.zig");
const CF = .{ .maxo = 8192 };
fn runOk(allo: std.mem.Allocator, iozz: std.Io, argv: []const []const u8) !void { const res = std.process.run(allo, iozz, .{ .argv = argv, .stdout_limit = .limited(CF.maxo), .stderr_limit = .limited(CF.maxo) }) catch return error.Fail; defer allo.free(res.stdout); defer allo.free(res.stderr); switch (res.term) { .exited => |code| { if (code != 0) return error.Fail; }, else => return error.Fail } }
pub fn ownerId(allo: std.mem.Allocator, iozz: std.Io, sysroot: []const u8) ![]u8 { if (builtin.os.tag != .windows) return allo.dupe(u8, ""); const exe = if (sysroot.len > 0) try std.fs.path.join(allo, &.{ sysroot, "System32", "whoami.exe" }) else try allo.dupe(u8, "whoami.exe"); defer allo.free(exe); const res = std.process.run(allo, iozz, .{ .argv = &.{ exe, "/user", "/fo", "csv", "/nh" }, .stdout_limit = .limited(CF.maxo), .stderr_limit = .limited(CF.maxo) }) catch return error.Fail; defer allo.free(res.stdout); defer allo.free(res.stderr); const line = std.mem.trim(u8, res.stdout, " \r\n"); const idx = std.mem.lastIndexOf(u8, line, "S-1-") orelse return error.Fail; var end = idx; while (end < line.len and (std.ascii.isDigit(line[end]) or line[end] == '-' or line[end] == 'S')) end += 1; return std.fmt.allocPrint(allo, "*{s}", .{line[idx..end]}); }
pub fn ownerOnly(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, owner: []const u8) !void { if (builtin.os.tag == .windows) { if (owner.len < 4 or owner[0] != '*') return error.Fail; const grant = try std.fmt.allocPrint(allo, "{s}:(OI)(CI)F", .{owner}); defer allo.free(grant); try runOk(allo, iozz, &.{ "icacls", path, "/grant:r", grant }); try runOk(allo, iozz, &.{ "icacls", path, "/inheritance:r" }); return; } try runOk(allo, iozz, &.{ "chmod", "700", path }); }
pub fn bodyLog(aren: std.mem.Allocator, text: []const u8, enab: bool) []const u8 { if (enab) return text; return prob.token(aren, text) catch "«h»"; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
