// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Validate pages and records before they are stored
// Flo: JSON must parse and not be empty > HTML must have visible text > short pages with block words = block page > records: required fields not empty, 0 or null
// I/O: content type + body (caller) > Verd; Fiel list + required names > first bad field name or null
// ===================================================================
const std = @import("std"); const html = @import("pa-html-text.zig");
const CF = .{ .shot = 3000, .mark = @as([]const []const u8, &.{ "just a moment", "access denied", "unusual traffic", "are you a robot", "verify you are human", "verify you are a human", "captcha", "checking your browser", "attention required", "request blocked", "pardon our interruption", "enable javascript and cookies", "ddos protection", "bot detection", "you have been blocked", "temporarily blocked" }), .nulz = @as([]const []const u8, &.{ "", "null", "none", "n/a", "na", "undefined", "nan", "0", "0.0", "0.00", "-", "--" }) };
pub const Verd = enum { okay, empt, bloc, jbad };
pub const Fiel = struct { name: []const u8, valu: []const u8 };
fn markHit(text: []const u8) bool { for (CF.mark) |mark| if (std.ascii.findIgnoreCase(text, mark) != null) return true; return false; }
pub fn pageVali(aren: std.mem.Allocator, ctyp: []const u8, body: []const u8) !Verd { const trim = std.mem.trim(u8, body, " \t\r\n"); if (std.ascii.findIgnoreCase(ctyp, "json") != null) { if (!(std.json.validate(aren, trim) catch false)) return .jbad; if (trim.len <= 4 and (std.mem.eql(u8, trim, "{}") or std.mem.eql(u8, trim, "[]") or std.mem.eql(u8, trim, "null"))) return .empt; return .okay; } const text = try html.htmlText(aren, trim); if (text.len == 0) return .empt; if (text.len > CF.shot) return .okay; if (markHit(text)) return .bloc; if (try html.htmlTitl(aren, trim)) |titl| { if (markHit(titl)) return .bloc; } return .okay; }
pub fn recoChek(recs: []const Fiel, requ: []const []const u8) ?[]const u8 { for (requ) |name| { var valu: []const u8 = ""; for (recs) |fiel| if (std.mem.eql(u8, fiel.name, name)) { valu = std.mem.trim(u8, fiel.valu, " \t\r\n"); break; }; var bad = false; for (CF.nulz) |nulz| if (std.ascii.eqlIgnoreCase(valu, nulz)) { bad = true; break; }; if (bad) return name; } return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
