// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Export parsed records as JSONL or CSV
// Flo: select records joined with page rows > write one line per row (JSON-escaped or CSV-quoted) > return row count
// I/O: Db + format + writer (caller) > text lines; CSV neutralizes formula starts
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
pub const Fmt = enum { jsonl, csv };
const Lin = struct { urlz: []const u8, kind: []const u8, hexz: []const u8, tier: i64, vend: []const u8, fetc: i64, body: []const u8 };
fn csvCell(outp: *std.Io.Writer, text: []const u8) !void { try outp.writeByte('"'); if (text.len > 0 and (text[0] == '=' or text[0] == '+' or text[0] == '-' or text[0] == '@')) try outp.writeByte('\''); for (text) |byte| { if (byte == '"') try outp.writeByte('"'); try outp.writeByte(byte); } try outp.writeByte('"'); }
pub fn expoRun(dbzz: *sqli.Db, outp: *std.Io.Writer, fmt: Fmt, aren: std.mem.Allocator) !u64 { var stmt = try dbzz.prep("SELECT r.urlz,r.kind,r.hexz,p.tier,p.vend,p.fetc,r.body FROM reco r JOIN page p ON p.urlz=r.urlz ORDER BY r.urlz;"); defer stmt.fini(); var cnt: u64 = 0; if (fmt == .csv) try outp.writeAll("urlz,kind,hexz,tier,vend,fetc,body\n"); while (try stmt.step()) { const lin: Lin = .{ .urlz = stmt.colText(0), .kind = stmt.colText(1), .hexz = stmt.colText(2), .tier = stmt.colInt(3), .vend = stmt.colText(4), .fetc = stmt.colInt(5), .body = stmt.colText(6) }; if (fmt == .jsonl) { const jsn = try std.json.Stringify.valueAlloc(aren, lin, .{}); defer aren.free(jsn); try outp.writeAll(jsn); try outp.writeByte('\n'); } else { try csvCell(outp, lin.urlz); try outp.writeByte(','); try csvCell(outp, lin.kind); try outp.writeByte(','); try csvCell(outp, lin.hexz); try outp.print(",{d},", .{lin.tier}); try csvCell(outp, lin.vend); try outp.print(",{d},", .{lin.fetc}); try csvCell(outp, lin.body); try outp.writeByte('\n'); } cnt += 1; } try outp.flush(); return cnt; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
