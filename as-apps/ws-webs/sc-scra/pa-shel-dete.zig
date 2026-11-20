// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Detect a thin JavaScript shell page with no real content
// Flo: visible text > too short? > embedded data block big? > shell marker or noscript hint
// I/O: HTML text + min text length (caller) > bool (true = shell, content needs JS)
// ===================================================================
const std = @import("std"); const html = @import("pa-html-text.zig"); const stru = @import("pa-stru-data.zig");
const CF = .{ .datz = 200, .mark = @as([]const []const u8, &.{ "id=\"root\"", "id='root'", "id=\"app\"", "id='app'", "id=\"__next\"", "id=\"__nuxt\"", "id=\"___gatsby\"", "<app-root", "ng-app", "<iframe" }) };
fn nosJs(page: []const u8) bool { var indx: usize = 0; while (std.ascii.findIgnoreCasePos(page, indx, "<noscript")) |beg| { const endz = std.ascii.findIgnoreCasePos(page, beg, "</noscript") orelse page.len; if (std.ascii.findIgnoreCase(page[beg..endz], "javascript") != null) return true; indx = endz; if (indx >= page.len) break; } return false; }
pub fn shelChek(aren: std.mem.Allocator, page: []const u8, minz: usize) !bool { const text = try html.htmlText(aren, page); if (text.len >= minz) return false; const blks = try stru.blokFind(aren, page); for (blks) |blk| if (blk.json.len > CF.datz) return false; for (CF.mark) |mark| if (std.ascii.findIgnoreCase(page, mark) != null) return true; return nosJs(page); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
