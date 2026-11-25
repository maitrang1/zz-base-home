// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: In-memory fake cloud (object store, SQL) for tests only
// Flo: put/get/del/list on a map > exec records statements > switches simulate an offline cloud
// I/O: same calls as the real clients > stored objects and statement log
// ===================================================================
const std = @import("std"); const stor = @import("sy-clou-stor.zig"); const sqlz = @import("sy-clou-sqlz.zig");
pub const Mock = struct { gpaz: std.mem.Allocator, map: std.StringHashMapUnmanaged([]u8) = .empty, stm2: std.ArrayList([]u8) = .empty, offl: bool = false, sqlo: bool = false, stoo: bool = false, badl: bool = false, deny: bool = false, dial: sqlz.Dial = .sqlt,
pub fn init(gpaz: std.mem.Allocator) Mock { return .{ .gpaz = gpaz }; }
pub fn deinit(self: *Mock) void { var iter = self.map.iterator(); while (iter.next()) |entr| { self.gpaz.free(entr.key_ptr.*); self.gpaz.free(entr.value_ptr.*); } self.map.deinit(self.gpaz); for (self.stm2.items) |item| self.gpaz.free(item); self.stm2.deinit(self.gpaz); }
pub fn store(self: *Mock) stor.Stor { return .{ .ctx2 = self, .put = putz, .get = getz, .del2 = delz, .list = lis3 }; }
pub fn sql2(self: *Mock) sqlz.Sqlz { return .{ .ctx2 = self, .dial = self.dial, .exec = exe3 }; }
pub fn used(self: *Mock) u64 { var tota: u64 = 0; var iter = self.map.valueIterator(); while (iter.next()) |val2| tota += val2.len; return tota; }
pub fn sawzStmt(self: *Mock, nee2: []const u8) usize { var con2: usize = 0; for (self.stm2.items) |item| if (std.mem.indexOf(u8, item, nee2) != null) { con2 += 1; }; return con2; }
fn putz(ctx2: *anyopaque, _: std.mem.Allocator, _: std.Io, key2: []const u8, byt3: []const u8) anyerror!void { const self: *Mock = @ptrCast(@alignCast(ctx2)); if (self.deny) return error.CloudDeny; if (self.offl or self.stoo) return error.CloudHttp; const val2 = try self.gpaz.dupe(u8, byt3); errdefer self.gpaz.free(val2); if (self.map.getPtr(key2)) |ptr| { self.gpaz.free(ptr.*); ptr.* = val2; return; } try self.map.put(self.gpaz, try self.gpaz.dupe(u8, key2), val2); }
fn getz(ctx2: *anyopaque, aren: std.mem.Allocator, _: std.Io, key2: []const u8) anyerror![]u8 { const self: *Mock = @ptrCast(@alignCast(ctx2)); if (self.deny) return error.CloudDeny; if (self.offl or self.stoo) return error.CloudHttp; return aren.dupe(u8, self.map.get(key2) orelse return error.CloudHttp); }
fn delz(ctx2: *anyopaque, _: std.mem.Allocator, _: std.Io, key2: []const u8) anyerror!void { const self: *Mock = @ptrCast(@alignCast(ctx2)); if (self.deny) return error.CloudDeny; if (self.offl or self.stoo) return error.CloudHttp; if (self.map.fetchRemove(key2)) |oldz| { self.gpaz.free(oldz.key); self.gpaz.free(oldz.value); } }
fn lis3(ctx2: *anyopaque, aren: std.mem.Allocator, _: std.Io, pre2: []const u8) anyerror![]stor.Objz { const self: *Mock = @ptrCast(@alignCast(ctx2)); if (self.deny) return error.CloudDeny; if (self.offl or self.stoo) return error.CloudHttp; var list: std.ArrayList(stor.Objz) = .empty; var iter = self.map.iterator(); while (iter.next()) |entr| if (std.mem.startsWith(u8, entr.key_ptr.*, pre2)) try list.append(aren, .{ .key2 = try aren.dupe(u8, entr.key_ptr.*), .size = if (self.badl) entr.value_ptr.len -| 1 else entr.value_ptr.len }); return list.toOwnedSlice(aren); }
fn exe3(ctx2: *anyopaque, _: std.mem.Allocator, _: std.Io, stm2: []const []const u8) anyerror!void { const self: *Mock = @ptrCast(@alignCast(ctx2)); if (self.deny) return error.CloudDeny; if (self.sqlo or self.offl) return error.CloudSql; for (stm2) |item| try self.stm2.append(self.gpaz, try self.gpaz.dupe(u8, item)); } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
