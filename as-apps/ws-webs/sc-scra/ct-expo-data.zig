// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Export parsed records as JSONL or CSV
// Flo: select records joined with page rows > write one line per row (JSON-escaped or CSV-quoted) > return row count
// I/O: Db + format + writer (caller) > text lines; CSV neutralizes formula starts
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
pub const Fmt = enum { jso2, csv };
const Linz = struct { urlz: []const u8, kind: []const u8, hexz: []const u8, tier: i64, vend: []const u8, fetc: i64, body: []const u8 };
fn csvzCell(outp: *std.Io.Writer, text: []const u8) !void { try outp.writeByte('"'); if (text.len > 0 and (text[0] == '=' or text[0] == '+' or text[0] == '-' or text[0] == '@')) try outp.writeByte('\''); for (text) |byte| { if (byte == '"') try outp.writeByte('"'); try outp.writeByte(byte); } try outp.writeByte('"'); }
pub fn expoRunz(dbzz: *sqli.Dbzz, outp: *std.Io.Writer, fmt: Fmt, aren: std.mem.Allocator) !u64 { var stmt = try dbzz.prep("SELECT r.urlz,r.kind,r.hexz,p.tier,p.vend,p.fetc,r.body FROM reco r JOIN page p ON p.urlz=r.urlz ORDER BY r.urlz;"); defer stmt.fini(); var con2: u64 = 0; if (fmt == .csv) try outp.writeAll("urlz,kind,hexz,tier,vend,fetc,body\n"); while (try stmt.step()) { const linz: Linz = .{ .urlz = stmt.colzText(0), .kind = stmt.colzText(1), .hexz = stmt.colzText(2), .tier = stmt.colzIntz(3), .vend = stmt.colzText(4), .fetc = stmt.colzIntz(5), .body = stmt.colzText(6) }; if (fmt == .jso2) { const jsn2 = try std.json.Stringify.valueAlloc(aren, linz, .{}); defer aren.free(jsn2); try outp.writeAll(jsn2); try outp.writeByte('\n'); } else { try csvzCell(outp, linz.urlz); try outp.writeByte(','); try csvzCell(outp, linz.kind); try outp.writeByte(','); try csvzCell(outp, linz.hexz); try outp.print(",{d},", .{linz.tier}); try csvzCell(outp, linz.vend); try outp.print(",{d},", .{linz.fetc}); try csvzCell(outp, linz.body); try outp.writeByte('\n'); } con2 += 1; } try outp.flush(); return con2; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
