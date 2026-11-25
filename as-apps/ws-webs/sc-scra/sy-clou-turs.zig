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
pub fn requBuil(aren: std.mem.Allocator, end2: cfgz.Endp, key2: []const u8, stm2: []const []const u8) !base.Http { if (end2.host.len == 0) return error.BadConfig; const reqs = try aren.alloc(Reqq, stm2.len + 1); for (stm2, 0..) |sqlz, ind3| reqs[ind3] = .{ .type = "execute", .stmt = .{ .sql = sqlz } }; reqs[stm2.len] = .{ .type = "close" }; return .{ .post = true, .urlz = try std.fmt.allocPrint(aren, "https://{s}/v2/pipeline", .{end2.host}), .auth = try std.fmt.allocPrint(aren, "Bearer {s}", .{key2}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, Pipe{ .requests = reqs }, .{ .emit_null_optional_fields = false }) }; }
pub fn respChek(aren: std.mem.Allocator, back: base.Back) !void { if (back.code == 401 or back.code == 402 or back.code == 403) return error.CloudDeny; if (back.code < 200 or back.code >= 300) return error.CloudSql; const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, back.body, .{}) catch return error.CloudSql; if (valu != .object) return error.CloudSql; const list = valu.object.get("results") orelse return error.CloudSql; if (list != .array) return error.CloudSql; for (list.array.items) |item| { if (item != .object) return error.CloudSql; const typz = item.object.get("type") orelse return error.CloudSql; if (typz != .string or !std.mem.eql(u8, typz.string, "ok")) return error.CloudSql; } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
