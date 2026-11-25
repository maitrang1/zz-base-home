// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Turns one neutral SQL statement into MySQL form
// Flo: copy text > inside quotes double each backslash > the upsert tail ON CONFLICT becomes ON DUPLICATE KEY UPDATE with VALUES(col)
// I/O: neutral statement (SQLite or Postgres form) > text for the given dialect; other dialects pass through unchanged
// ===================================================================
const std = @import("std"); const sqlz = @import("sy-clou-sqlz.zig");
const CF = .{ .conf = " ON CONFLICT(", .upda = ") DO UPDATE SET ", .excl = "excluded.", .dupl = " ON DUPLICATE KEY UPDATE " };
fn tailMysq(aren: std.mem.Allocator, outp: *std.ArrayList(u8), tail: []const u8) !void { const body = tail[CF.conf.len..]; const cutz = std.mem.indexOf(u8, body, CF.upda) orelse return error.BadStmt; try outp.appendSlice(aren, CF.dupl); var iter = std.mem.splitScalar(u8, body[cutz + CF.upda.len ..], ','); var firs = true; while (iter.next()) |item| { const eqzz = std.mem.indexOfScalar(u8, item, '=') orelse return error.BadStmt; if (!std.mem.startsWith(u8, item[eqzz + 1 ..], CF.excl)) return error.BadStmt; if (!firs) try outp.append(aren, ','); firs = false; try outp.print(aren, "{s}=VALUES({s})", .{ item[0..eqzz], item[0..eqzz] }); } }
pub fn mysqOfzz(aren: std.mem.Allocator, text: []const u8) ![]u8 { var outp: std.ArrayList(u8) = .empty; var inzz = false; var indx: usize = 0; while (indx < text.len) { const byte = text[indx]; if (inzz) { if (byte == '\'') { if (indx + 1 < text.len and text[indx + 1] == '\'') { try outp.appendSlice(aren, "''"); indx += 2; continue; } inzz = false; try outp.append(aren, byte); } else if (byte == '\\') { try outp.appendSlice(aren, "\\\\"); } else try outp.append(aren, byte); indx += 1; continue; } if (byte == '\'') { inzz = true; try outp.append(aren, byte); indx += 1; continue; } if (std.mem.startsWith(u8, text[indx..], CF.conf)) { try tailMysq(aren, &outp, text[indx..]); return outp.toOwnedSlice(aren); } try outp.append(aren, byte); indx += 1; } return outp.toOwnedSlice(aren); }
pub fn forzDial(aren: std.mem.Allocator, dial: sqlz.Dial, text: []const u8) ![]const u8 { if (dial != .mysq) return text; return mysqOfzz(aren, text); }
pub fn listDial(aren: std.mem.Allocator, dial: sqlz.Dial, list: []const []const u8) ![]const []const u8 { if (dial != .mysq) return list; const outp = try aren.alloc([]const u8, list.len); for (list, 0..) |item, indx| outp[indx] = try mysqOfzz(aren, item); return outp; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
