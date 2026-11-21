// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Thin SQLite wrapper: open, exec, statements, migrations
// Flo: open (WAL, busy timeout) > exec or prepare > bind > step > read columns > finalize > close
// I/O: SQL text + bound values (caller) > rows, counts, user_version (SQLite file)
// ===================================================================
const std = @import("std");
const chrz = struct { pub const sqlite3 = opaque {}; pub const sqlite3_stmt = opaque {}; pub const SQLITE_OK: c_int = 0; pub const SQLITE_ROW: c_int = 100; pub const SQLITE_DONE: c_int = 101; pub extern fn sqlite3_open(path: [*:0]const u8, out2: *?*sqlite3) c_int; pub extern fn sqlite3_close(hndz: ?*sqlite3) c_int; pub extern fn sqlite3_busy_timeout(hndz: ?*sqlite3, mill: c_int) c_int; pub extern fn sqlite3_exec(hndz: ?*sqlite3, sqlz: [*:0]const u8, back: ?*const anyopaque, argz: ?*anyopaque, errz: ?*?[*:0]u8) c_int; pub extern fn sqlite3_prepare_v2(hndz: ?*sqlite3, sqlz: [*:0]const u8, lenz: c_int, out2: *?*sqlite3_stmt, tail: ?*?[*:0]const u8) c_int; pub extern fn sqlite3_bind_text(stmz: ?*sqlite3_stmt, indx: c_int, text: [*]const u8, lenz: c_int, dest: ?*const anyopaque) c_int; pub extern fn sqlite3_bind_int64(stmz: ?*sqlite3_stmt, indx: c_int, valu: i64) c_int; pub extern fn sqlite3_bind_null(stmz: ?*sqlite3_stmt, indx: c_int) c_int; pub extern fn sqlite3_step(stmz: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_column_text(stmz: ?*sqlite3_stmt, indx: c_int) ?[*]const u8; pub extern fn sqlite3_column_bytes(stmz: ?*sqlite3_stmt, indx: c_int) c_int; pub extern fn sqlite3_column_int64(stmz: ?*sqlite3_stmt, indx: c_int) i64; pub extern fn sqlite3_reset(stmz: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_clear_bindings(stmz: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_finalize(stmz: ?*sqlite3_stmt) c_int; pub extern fn sqlite3_changes(hndz: ?*sqlite3) c_int; pub extern fn sqlite3_last_insert_rowid(hndz: ?*sqlite3) i64; };
const CF = .{ .busy = 5000, .walz = "PRAGMA journal_mode=WAL;PRAGMA synchronous=NORMAL;PRAGMA foreign_keys=ON;" };
const TRAN: ?*const anyopaque = @ptrFromInt(std.math.maxInt(usize));
pub const Stmt = struct { hand: ?*chrz.sqlite3_stmt = null,
pub fn bindText(self: *Stmt, indx: c_int, text: []const u8) !void { if (chrz.sqlite3_bind_text(self.hand, indx, text.ptr, @intCast(text.len), TRAN) != chrz.SQLITE_OK) return error.SqliBind; }
pub fn bindIntz(self: *Stmt, indx: c_int, valu: i64) !void { if (chrz.sqlite3_bind_int64(self.hand, indx, valu) != chrz.SQLITE_OK) return error.SqliBind; }
pub fn bindNull(self: *Stmt, indx: c_int) !void { if (chrz.sqlite3_bind_null(self.hand, indx) != chrz.SQLITE_OK) return error.SqliBind; }
pub fn step(self: *Stmt) !bool { const retn = chrz.sqlite3_step(self.hand); if (retn == chrz.SQLITE_ROW) return true; if (retn == chrz.SQLITE_DONE) return false; return error.SqliStep; }
pub fn colzText(self: *Stmt, indx: c_int) []const u8 { const ptrz = chrz.sqlite3_column_text(self.hand, indx) orelse return ""; const lenz: usize = @intCast(chrz.sqlite3_column_bytes(self.hand, indx)); return ptrz[0..lenz]; }
pub fn colzIntz(self: *Stmt, indx: c_int) i64 { return chrz.sqlite3_column_int64(self.hand, indx); }
pub fn reset(self: *Stmt) void { _ = chrz.sqlite3_reset(self.hand); _ = chrz.sqlite3_clear_bindings(self.hand); }
pub fn fini(self: *Stmt) void { if (self.hand != null) _ = chrz.sqlite3_finalize(self.hand); self.hand = null; } };
pub const Dbzz = struct { hand: ?*chrz.sqlite3 = null,
pub fn open(path: [:0]const u8) !Dbzz { var hand: ?*chrz.sqlite3 = null; if (chrz.sqlite3_open(path.ptr, &hand) != chrz.SQLITE_OK) { _ = chrz.sqlite3_close(hand); return error.SqliOpen; } var self: Dbzz = .{ .hand = hand }; errdefer self.close(); _ = chrz.sqlite3_busy_timeout(hand, CF.busy); try self.exec(CF.walz); return self; }
pub fn close(self: *Dbzz) void { if (self.hand != null) _ = chrz.sqlite3_close(self.hand); self.hand = null; }
pub fn exec(self: *Dbzz, sqlz: [:0]const u8) !void { if (chrz.sqlite3_exec(self.hand, sqlz.ptr, null, null, null) != chrz.SQLITE_OK) return error.SqliExec; }
pub fn prep(self: *Dbzz, sqlz: [:0]const u8) !Stmt { var hand: ?*chrz.sqlite3_stmt = null; if (chrz.sqlite3_prepare_v2(self.hand, sqlz.ptr, -1, &hand, null) != chrz.SQLITE_OK) return error.SqliPrep; return .{ .hand = hand }; }
pub fn changes(self: *Dbzz) i64 { return chrz.sqlite3_changes(self.hand); }
pub fn lastRowz(self: *Dbzz) i64 { return chrz.sqlite3_last_insert_rowid(self.hand); }
pub fn verzGetz(self: *Dbzz) !i64 { var stmt = try self.prep("PRAGMA user_version;"); defer stmt.fini(); if (!try stmt.step()) return 0; return stmt.colzIntz(0); }
pub fn migr(self: *Dbzz, allo: std.mem.Allocator, ste2: []const [:0]const u8) !void { const done = try self.verzGetz(); var indx: usize = @intCast(done); while (indx < ste2.len) : (indx += 1) { try self.exec("BEGIN IMMEDIATE;"); errdefer self.exec("ROLLBACK;") catch {}; try self.exec(ste2[indx]); const sqlz = try std.fmt.allocPrintSentinel(allo, "PRAGMA user_version={d};", .{indx + 1}, 0); defer allo.free(sqlz); try self.exec(sqlz); try self.exec("COMMIT;"); } } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
