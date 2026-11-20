// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Turso (libSQL) adapter: HTTP request for SQL statements
// Flo: statements > JSON body + auth headers > one Http value; read reply text for errors
// I/O: Endp + key + statements (cloud sql client) > base.Http; reply body > ok or error.CloudSql
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig"); const cfgz = @import("cf-conf-load.zig");
const Stmt = struct { sql: []const u8 };
const Reqq = struct { type: []const u8, stmt: ?Stmt = null };
const Pipe = struct { requests: []const Reqq };
pub fn reqBuild(aren: std.mem.Allocator, ep: cfgz.Endp, key: []const u8, stmts: []const []const u8) !base.Http { if (ep.hostz.len == 0) return error.BadConfig; const reqs = try aren.alloc(Reqq, stmts.len + 1); for (stmts, 0..) |sqlz, ix| reqs[ix] = .{ .type = "execute", .stmt = .{ .sql = sqlz } }; reqs[stmts.len] = .{ .type = "close" }; return .{ .post = true, .urlz = try std.fmt.allocPrint(aren, "https://{s}/v2/pipeline", .{ep.hostz}), .auth = try std.fmt.allocPrint(aren, "Bearer {s}", .{key}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, Pipe{ .requests = reqs }, .{ .emit_null_optional_fields = false }) }; }
pub fn rspChek(aren: std.mem.Allocator, back: base.Back) !void { if (back.code < 200 or back.code >= 300) return error.CloudSql; const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, back.body, .{}) catch return error.CloudSql; if (valu != .object) return error.CloudSql; const list = valu.object.get("results") orelse return error.CloudSql; if (list != .array) return error.CloudSql; for (list.array.items) |item| { if (item != .object) return error.CloudSql; const typz = item.object.get("type") orelse return error.CloudSql; if (typz != .string or !std.mem.eql(u8, typz.string, "ok")) return error.CloudSql; } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
