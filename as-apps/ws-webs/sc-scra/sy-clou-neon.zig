// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Neon (Postgres) adapter: HTTP request for SQL statements
// Flo: statements > JSON body + auth headers > one Http value; read reply text for errors
// I/O: Endp + key + statements (cloud sql client) > base.Http; reply body > ok or error.CloudSql
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig"); const cfgz = @import("cf-conf-load.zig");
const Bodz = struct { query: []const u8 };
pub fn requBuil(aren: std.mem.Allocator, end2: cfgz.Endp, key2: []const u8, stmt: []const u8) !base.Http { if (end2.hos4.len == 0) return error.BadConfig; const ext2 = try aren.alloc(base.Hdrz, 1); ext2[0] = .{ .name = "Neon-Connection-String", .valu = key2 }; return .{ .post = true, .urlz = try std.fmt.allocPrint(aren, "https://{s}/sql", .{end2.hos4}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, Bodz{ .query = stmt }, .{}), .ext2 = ext2 }; }
pub fn respChek(back: base.Back) !void { if (back.code < 200 or back.code >= 300) return error.CloudSql; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
