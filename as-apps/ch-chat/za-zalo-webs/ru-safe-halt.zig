// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Halt guard: captcha, lock, warning, logout, login page stop all work
// Flo: stored halt flag > page text lowercased > match QR label or halt words > store halt + typed error
// I/O: page text + Conf words (caller) > Verd; error Halted or NeedLogin, halt flag in state db
// ===================================================================
const std = @import("std"); const conf = @import("cf-conf-load.zig"); const snap = @import("ru-page-snap.zig"); const cdp = @import("nt-cdpz-sock.zig"); const data = @import("st-stat-data.zig");
pub const Verd = struct { kind: enum { okay, login, halt }, word: []const u8 = "" };
fn lowCp(cpz: u21) u21 { if (cpz >= 'A' and cpz <= 'Z') return cpz + 32; if (cpz >= 0xC0 and cpz <= 0xDE and cpz != 0xD7) return cpz + 32; if (cpz == 0x110 or cpz == 0x128 or cpz == 0x168 or cpz == 0x1A0 or cpz == 0x1AF or cpz == 0x102) return cpz + 1; if (cpz >= 0x1EA0 and cpz <= 0x1EF8 and cpz % 2 == 0) return cpz + 1; return cpz; }
pub fn lowFold(aren: std.mem.Allocator, text: []const u8) ![]u8 { var out: std.ArrayList(u8) = .empty; var itr = (std.unicode.Utf8View.init(text) catch return aren.dupe(u8, text)).iterator(); while (itr.nextCodepoint()) |cpz| { var buf: [4]u8 = undefined; const lenz = std.unicode.utf8Encode(lowCp(cpz), &buf) catch continue; try out.appendSlice(aren, buf[0..lenz]); } return out.items; }
pub fn judge(aren: std.mem.Allocator, text: []const u8, words: []const []const u8, qrlb: []const u8) !Verd { const low = try lowFold(aren, text); if (qrlb.len > 0) { const qlo = try lowFold(aren, qrlb); if (std.mem.find(u8, low, qlo) != null) return .{ .kind = .login }; } for (words) |wrd| { if (wrd.len == 0) continue; const wlo = try lowFold(aren, wrd); if (std.mem.find(u8, low, wlo) != null) return .{ .kind = .halt, .word = wrd }; } return .{ .kind = .okay }; }
pub fn guardText(aren: std.mem.Allocator, cfg: conf.Conf, sto: *data.Stor, now_ms: i64, text: []const u8) !void { if (try sto.haltGet(aren)) |_| return error.Halted; const ver = try judge(aren, text, cfg.halt_word_list, cfg.labl_qrcd_page); switch (ver.kind) { .okay => {}, .login => return error.NeedLogin, .halt => { try sto.haltSet(now_ms, ver.word); try sto.logAdd(now_ms, "halt", "guard", ver.word); return error.Halted; } } }
pub fn guard(aren: std.mem.Allocator, cfg: conf.Conf, sto: *data.Stor, conn: *cdp.Conn, now_ms: i64) !void { if (try sto.haltGet(aren)) |_| return error.Halted; const txt = try snap.pageText(aren, conn); try guardText(aren, cfg, sto, now_ms, txt); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
