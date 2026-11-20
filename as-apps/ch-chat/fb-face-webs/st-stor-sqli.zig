// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Thin SQLite wrapper: open, exec, statements, migrations
// Flo: open (WAL, busy timeout) > exec or prepare > bind > step > read columns > finalize > close
// I/O: SQL text + bound values (caller) > rows, counts, user_version (SQLite file)
// ===================================================================
const std = @import("std");
const c = struct { pub const sqlite3 = opaque {}; pub const sqlite3_stmt = opaque {}; pub const SQLITE_OK: c_int = 0; pub const SQLITE_ROW: c_int = 100; pub const SQLITE_DONE: c_int = 101; pub extern fn sqlite3_open(path: [*:0]const u8, out: *?*sqlite3) c_int; pub extern fn sqlite3_close(hnd: ?*sqlite3) c_int; pub extern fn sqlite3_busy_timeout(hnd: ?*sqlite3, mill: c_int) c_int; pub extern fn sqlite3_exec(hnd: ?*sqlite3, sqlz: [*:0]const u8, back: ?*const anyopaque, arg: ?*anyopaque, errz: ?*?[*:0]u8) c_int; pub extern fn sqlite3_prepare_v2(hnd: ?*sqlite3, sqlz: [*:0]const u8, lenz: c_int, out: *?*sqlite3_stmt, tail: ?*?[*:0]const u8) c_int; pub extern fn sqlite3_bind_text(stm: ?*sqlite3_stmt, indx: c_int, text: [*]const u8, lenz: c_int, dest: ?*const anyopaque) c_int; pub extern fn sqlite3_bind_int64(stm: ?*sqlite3_stmt, indx: c_int, valu: i64) c_int; pub extern fn sqlite3_bind_null(stm: ?*sqlite3_stmt, indx: c_int) c_int; pub extern fn sqlite3_step(stm: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_column_text(stm: ?*sqlite3_stmt, indx: c_int) ?[*]const u8; pub extern fn sqlite3_column_bytes(stm: ?*sqlite3_stmt, indx: c_int) c_int; pub extern fn sqlite3_column_int64(stm: ?*sqlite3_stmt, indx: c_int) i64; pub extern fn sqlite3_reset(stm: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_clear_bindings(stm: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_finalize(stm: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_changes(hnd: ?*sqlite3) c_int; pub extern fn sqlite3_last_insert_rowid(hnd: ?*sqlite3) i64; };
const CF = .{ .busy = 5000, .walz = "PRAGMA journal_mode=WAL;PRAGMA synchronous=NORMAL;PRAGMA foreign_keys=ON;" };
const TRAN: ?*const anyopaque = @ptrFromInt(std.math.maxInt(usize));
pub const Stmt = struct { hand: ?*c.sqlite3_stmt = null,
pub fn bindText(self: *Stmt, indx: c_int, text: []const u8) !void { if (c.sqlite3_bind_text(self.hand, indx, text.ptr, @intCast(text.len), TRAN) != c.SQLITE_OK) return error.SqliBind; }
pub fn bindInt(self: *Stmt, indx: c_int, valu: i64) !void { if (c.sqlite3_bind_int64(self.hand, indx, valu) != c.SQLITE_OK) return error.SqliBind; }
pub fn bindNull(self: *Stmt, indx: c_int) !void { if (c.sqlite3_bind_null(self.hand, indx) != c.SQLITE_OK) return error.SqliBind; }
pub fn step(self: *Stmt) !bool { const retn = c.sqlite3_step(self.hand); if (retn == c.SQLITE_ROW) return true; if (retn == c.SQLITE_DONE) return false; return error.SqliStep; }
pub fn colText(self: *Stmt, indx: c_int) []const u8 { const ptrz = c.sqlite3_column_text(self.hand, indx) orelse return ""; const lenz: usize = @intCast(c.sqlite3_column_bytes(self.hand, indx)); return ptrz[0..lenz]; }
pub fn colInt(self: *Stmt, indx: c_int) i64 { return c.sqlite3_column_int64(self.hand, indx); }
pub fn reset(self: *Stmt) void { _ = c.sqlite3_reset(self.hand); _ = c.sqlite3_clear_bindings(self.hand); }
pub fn fini(self: *Stmt) void { if (self.hand != null) _ = c.sqlite3_finalize(self.hand); self.hand = null; } };
pub const Db = struct { hand: ?*c.sqlite3 = null,
pub fn open(path: [:0]const u8) !Db { var hand: ?*c.sqlite3 = null; if (c.sqlite3_open(path.ptr, &hand) != c.SQLITE_OK) { _ = c.sqlite3_close(hand); return error.SqliOpen; } var self: Db = .{ .hand = hand }; errdefer self.close(); _ = c.sqlite3_busy_timeout(hand, CF.busy); try self.exec(CF.walz); return self; }
pub fn close(self: *Db) void { if (self.hand != null) _ = c.sqlite3_close(self.hand); self.hand = null; }
pub fn exec(self: *Db, sqlz: [:0]const u8) !void { if (c.sqlite3_exec(self.hand, sqlz.ptr, null, null, null) != c.SQLITE_OK) return error.SqliExec; }
pub fn prep(self: *Db, sqlz: [:0]const u8) !Stmt { var hand: ?*c.sqlite3_stmt = null; if (c.sqlite3_prepare_v2(self.hand, sqlz.ptr, -1, &hand, null) != c.SQLITE_OK) return error.SqliPrep; return .{ .hand = hand }; }
pub fn changes(self: *Db) i64 { return c.sqlite3_changes(self.hand); }
pub fn lastRow(self: *Db) i64 { return c.sqlite3_last_insert_rowid(self.hand); }
pub fn verGet(self: *Db) !i64 { var stmt = try self.prep("PRAGMA user_version;"); defer stmt.fini(); if (!try stmt.step()) return 0; return stmt.colInt(0); }
pub fn migr(self: *Db, allo: std.mem.Allocator, steps: []const [:0]const u8) !void { const done = try self.verGet(); var indx: usize = @intCast(done); while (indx < steps.len) : (indx += 1) { try self.exec("BEGIN IMMEDIATE;"); errdefer self.exec("ROLLBACK;") catch {}; try self.exec(steps[indx]); const sqlz = try std.fmt.allocPrintSentinel(allo, "PRAGMA user_version={d};", .{indx + 1}, 0); defer allo.free(sqlz); try self.exec(sqlz); try self.exec("COMMIT;"); } } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
