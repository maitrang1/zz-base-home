// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: NDJSON event lines, flushed the moment written
// Flo: kind + data > JSON-escape > write line + newline > flush
// I/O: child output chunks, exit code (spawn, serve) > NDJSON lines (HTTP response, js-runz-comm.js)
// ===================================================================
const std = @import("std");
const CF = .{ .head = "HTTP/1.1 200 OK\r\nContent-Type: application/x-ndjson; charset=utf-8\r\nCache-Control: no-cache\r\nConnection: close\r\n\r\n" };
pub const HEAD = CF.head;
pub fn chunWrit(wrtr: *std.Io.Writer, kind: []const u8, data: []const u8) !void { try wrtr.writeAll("{\"t\":\""); try wrtr.writeAll(kind); try wrtr.writeAll("\",\"d\":"); try std.json.Stringify.encodeJsonString(data, .{}, wrtr); try wrtr.writeAll("}\n"); try wrtr.flush(); }
pub fn outpWrit(wrtr: *std.Io.Writer, data: []const u8) !void { return chunWrit(wrtr, "out", data); }
pub fn erroWrit(wrtr: *std.Io.Writer, data: []const u8) !void { return chunWrit(wrtr, "err", data); }
pub fn exitWrit(wrtr: *std.Io.Writer, code: i32, elap_msec: i64, cwdz: []const u8) !void { try wrtr.print("{{\"t\":\"exit\",\"code\":{d},\"elapsed\":{d},\"cwd\":", .{ code, elap_msec }); try std.json.Stringify.encodeJsonString(cwdz, .{}, wrtr); try wrtr.writeAll("}\n"); try wrtr.flush(); }
pub fn beatWrit(wrtr: *std.Io.Writer) !void { try wrtr.writeAll("{\"t\":\"hb\"}\n"); try wrtr.flush(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
