// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Parse sitemap.xml and sitemap index into URL lists
// Flo: find each <loc> > strip CDATA and spaces > decode XML entities > keep http(s) only > cap count
// I/O: XML text (caller) > Smap (urls, is-index); strings owned by the arena
// ===================================================================
const std = @import("std"); const mem = std.mem;
pub const Smap = struct { urls: []const []const u8, indx: bool };
fn xmlDeco(aren: std.mem.Allocator, text: []const u8) ![]u8 { var outp: std.ArrayList(u8) = .empty; var indx: usize = 0; const nams = [_][]const u8{ "&amp;", "&lt;", "&gt;", "&quot;", "&apos;" }; const vals = [_][]const u8{ "&", "<", ">", "\"", "'" }; outer: while (indx < text.len) { if (text[indx] == '&') { for (nams, 0..) |nam, ix| { if (mem.startsWith(u8, text[indx..], nam)) { try outp.appendSlice(aren, vals[ix]); indx += nam.len; continue :outer; } } } try outp.append(aren, text[indx]); indx += 1; } return outp.toOwnedSlice(aren); }
pub fn smapParse(aren: std.mem.Allocator, xml: []const u8, maxz: usize) !Smap { var list: std.ArrayList([]const u8) = .empty; var indx: usize = 0; while (list.items.len < maxz) { const beg = std.ascii.findIgnoreCasePos(xml, indx, "<loc>") orelse break; const endz = std.ascii.findIgnoreCasePos(xml, beg + 5, "</loc>") orelse break; indx = endz + 6; var raws = mem.trim(u8, xml[beg + 5 .. endz], " \t\r\n"); if (mem.startsWith(u8, raws, "<![CDATA[") and mem.endsWith(u8, raws, "]]>")) raws = mem.trim(u8, raws[9 .. raws.len - 3], " \t\r\n"); const urlz = try xmlDeco(aren, raws); if (mem.startsWith(u8, urlz, "http://") or mem.startsWith(u8, urlz, "https://")) try list.append(aren, urlz); } return .{ .urls = try list.toOwnedSlice(aren), .indx = std.ascii.findIgnoreCase(xml, "<sitemapindex") != null }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
