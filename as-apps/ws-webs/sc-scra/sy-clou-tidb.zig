// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: TiDB Starter (MySQL) adapter: HTTP request for SQL statements
// Flo: statements > JSON body + auth headers > one Http value; read reply text for errors
// I/O: Endp + key + statements (cloud sql client) > base.Http; reply body > ok or error.CloudSql
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig"); const cfgz = @import("cf-conf-load.zig");
const Bodz = struct { query: []const u8 };
pub fn requBuil(aren: std.mem.Allocator, end2: cfgz.Endp, key2: []const u8, stmt: []const u8) !base.Http { if (end2.hos4.len == 0 or end2.dbnm.len == 0) return error.BadConfig; const ext2 = try aren.alloc(base.Hdrz, 1); ext2[0] = .{ .name = "TiDB-Database", .valu = end2.dbnm }; return .{ .post = true, .urlz = try std.fmt.allocPrint(aren, "https://{s}/v1beta/sql", .{end2.hos4}), .auth = try std.fmt.allocPrint(aren, "Basic {s}", .{try base.b64z(aren, key2)}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, Bodz{ .query = stmt }, .{}), .ext2 = ext2 }; }
pub fn respChek(back: base.Back) !void { if (back.code < 200 or back.code >= 300) return error.CloudSql; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
