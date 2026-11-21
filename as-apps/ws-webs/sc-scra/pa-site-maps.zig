// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Parse sitemap.xml and sitemap index into URL lists
// Flo: find each <loc> > strip CDATA and spaces > decode XML entities > keep http(s) only > cap count
// I/O: XML text (caller) > Smap (urls, is-index); strings owned by the arena
// ===================================================================
const std = @import("std"); const mem2 = std.mem;
pub const Smap = struct { urls: []const []const u8, indx: bool };
fn xmlzDeco(aren: std.mem.Allocator, text: []const u8) ![]u8 { var outp: std.ArrayList(u8) = .empty; var indx: usize = 0; const nams = [_][]const u8{ "&amp;", "&lt;", "&gt;", "&quot;", "&apos;" }; const vals = [_][]const u8{ "&", "<", ">", "\"", "'" }; oute: while (indx < text.len) { if (text[indx] == '&') { for (nams, 0..) |nam2, ind3| { if (mem2.startsWith(u8, text[indx..], nam2)) { try outp.appendSlice(aren, vals[ind3]); indx += nam2.len; continue :oute; } } } try outp.append(aren, text[indx]); indx += 1; } return outp.toOwnedSlice(aren); }
pub fn smapPars(aren: std.mem.Allocator, xmlz: []const u8, maxz: usize) !Smap { var list: std.ArrayList([]const u8) = .empty; var indx: usize = 0; while (list.items.len < maxz) { const begz = std.ascii.findIgnoreCasePos(xmlz, indx, "<loc>") orelse break; const endz = std.ascii.findIgnoreCasePos(xmlz, begz + 5, "</loc>") orelse break; indx = endz + 6; var raws = mem2.trim(u8, xmlz[begz + 5 .. endz], " \t\r\n"); if (mem2.startsWith(u8, raws, "<![CDATA[") and mem2.endsWith(u8, raws, "]]>")) raws = mem2.trim(u8, raws[9 .. raws.len - 3], " \t\r\n"); const urlz = try xmlzDeco(aren, raws); if (mem2.startsWith(u8, urlz, "http://") or mem2.startsWith(u8, urlz, "https://")) try list.append(aren, urlz); } return .{ .urls = try list.toOwnedSlice(aren), .indx = std.ascii.findIgnoreCase(xmlz, "<sitemapindex") != null }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
