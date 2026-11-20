// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: In-memory fake cloud (object store + SQL) for tests only
// Flo: put/get/del/list on a map > exec records statements > switches simulate an offline cloud
// I/O: same calls as the real clients > stored objects and statement log
// ===================================================================
const std = @import("std"); const stor = @import("sy-clou-stor.zig"); const sqlz = @import("sy-clou-sqlz.zig");
pub const Mock = struct { gpaz: std.mem.Allocator, map: std.StringHashMapUnmanaged([]u8) = .empty, stmts: std.ArrayList([]u8) = .empty, offl: bool = false, sqlo: bool = false, dial: sqlz.Dial = .sqlt,
pub fn init(gpaz: std.mem.Allocator) Mock { return .{ .gpaz = gpaz }; }
pub fn deinit(self: *Mock) void { var iter = self.map.iterator(); while (iter.next()) |ent| { self.gpaz.free(ent.key_ptr.*); self.gpaz.free(ent.value_ptr.*); } self.map.deinit(self.gpaz); for (self.stmts.items) |item| self.gpaz.free(item); self.stmts.deinit(self.gpaz); }
pub fn store(self: *Mock) stor.Store { return .{ .ctx = self, .put = putz, .get = getz, .del = delz, .list = listz }; }
pub fn sql(self: *Mock) sqlz.Sql { return .{ .ctx = self, .dial = self.dial, .exec = execz }; }
pub fn used(self: *Mock) u64 { var tota: u64 = 0; var iter = self.map.valueIterator(); while (iter.next()) |val| tota += val.len; return tota; }
pub fn sawStmt(self: *Mock, needle: []const u8) usize { var cnt: usize = 0; for (self.stmts.items) |item| if (std.mem.indexOf(u8, item, needle) != null) { cnt += 1; }; return cnt; }
fn putz(ctx: *anyopaque, _: std.mem.Allocator, _: std.Io, key: []const u8, bytes: []const u8) anyerror!void { const self: *Mock = @ptrCast(@alignCast(ctx)); if (self.offl) return error.CloudHttp; const val = try self.gpaz.dupe(u8, bytes); errdefer self.gpaz.free(val); if (self.map.getPtr(key)) |ptr| { self.gpaz.free(ptr.*); ptr.* = val; return; } try self.map.put(self.gpaz, try self.gpaz.dupe(u8, key), val); }
fn getz(ctx: *anyopaque, aren: std.mem.Allocator, _: std.Io, key: []const u8) anyerror![]u8 { const self: *Mock = @ptrCast(@alignCast(ctx)); if (self.offl) return error.CloudHttp; return aren.dupe(u8, self.map.get(key) orelse return error.CloudHttp); }
fn delz(ctx: *anyopaque, _: std.mem.Allocator, _: std.Io, key: []const u8) anyerror!void { const self: *Mock = @ptrCast(@alignCast(ctx)); if (self.offl) return error.CloudHttp; if (self.map.fetchRemove(key)) |old| { self.gpaz.free(old.key); self.gpaz.free(old.value); } }
fn listz(ctx: *anyopaque, aren: std.mem.Allocator, _: std.Io, prefix: []const u8) anyerror![]stor.Obj { const self: *Mock = @ptrCast(@alignCast(ctx)); if (self.offl) return error.CloudHttp; var list: std.ArrayList(stor.Obj) = .empty; var iter = self.map.iterator(); while (iter.next()) |ent| if (std.mem.startsWith(u8, ent.key_ptr.*, prefix)) try list.append(aren, .{ .key = try aren.dupe(u8, ent.key_ptr.*), .size = ent.value_ptr.len }); return list.toOwnedSlice(aren); }
fn execz(ctx: *anyopaque, _: std.mem.Allocator, _: std.Io, stmts: []const []const u8) anyerror!void { const self: *Mock = @ptrCast(@alignCast(ctx)); if (self.sqlo or self.offl) return error.CloudSql; for (stmts) |item| try self.stmts.append(self.gpaz, try self.gpaz.dupe(u8, item)); } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
