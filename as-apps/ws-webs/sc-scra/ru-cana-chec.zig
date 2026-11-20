// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Canary: DOM signature per page, report drift against baseline
// Flo: count tag names into 32 buckets + title/JSON-LD flags + text length > compare to the stored baseline > drift reason or null
// I/O: HTML (caller) > Sig; Db rows in cana (baseline JSON per URL)
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig"); const html = @import("pa-html-text.zig"); const stru = @import("pa-stru-data.zig");
const CF = .{ .bukt = 32, .dpct = 30, .tpct = 50 };
pub const Sig = struct { tags: [CF.bukt]u16 = [_]u16{0} ** CF.bukt, titl: bool = false, ldjs: bool = false, tlen: u32 = 0 };
pub const Cana = struct { urlz: []const u8, sig: Sig };
pub fn sigMake(aren: std.mem.Allocator, src: []const u8) !Sig { var sig: Sig = .{}; var indx: usize = 0; while (std.mem.findScalarPos(u8, src, indx, '<')) |lt| { var endz = lt + 1; while (endz < src.len and std.ascii.isAlphanumeric(src[endz])) endz += 1; if (endz > lt + 1) { var low: [16]u8 = undefined; const nam = src[lt + 1 .. endz]; const lenz = @min(nam.len, low.len); const slot = std.hash.Wyhash.hash(0, std.ascii.lowerString(&low, nam[0..lenz])) % CF.bukt; sig.tags[slot] +|= 1; } indx = lt + 1; } if (try html.htmlTitl(aren, src)) |titl| sig.titl = titl.len > 0; const blks = try stru.blokFind(aren, src); for (blks) |blk| if (blk.kind == .ldjs) { sig.ldjs = true; }; sig.tlen = @intCast((try html.htmlText(aren, src)).len); return sig; }
pub fn sigDrif(base: Sig, curz: Sig) ?[]const u8 { if (base.titl and !curz.titl) return "title lost"; if (base.ldjs and !curz.ldjs) return "json-ld lost"; if (base.tlen > 0 and @as(u64, curz.tlen) * 100 < @as(u64, base.tlen) * (100 - CF.tpct)) return "text shrank"; var diff: u32 = 0; var tota: u32 = 0; for (base.tags, curz.tags) |left, rite| { diff += if (left > rite) left - rite else rite - left; tota += @as(u32, left) + rite; } if (tota > 0 and diff * 100 / tota > CF.dpct) return "dom changed"; return null; }
pub fn canaSet(dbzz: *sqli.Db, aren: std.mem.Allocator, urlz: []const u8, sig: Sig, timz: i64) !void { const jsn = try std.json.Stringify.valueAlloc(aren, sig, .{}); var stmt = try dbzz.prep("INSERT INTO cana(urlz,sigj,timz) VALUES(?1,?2,?3) ON CONFLICT(urlz) DO UPDATE SET sigj=?2,timz=?3;"); defer stmt.fini(); try stmt.bindText(1, urlz); try stmt.bindText(2, jsn); try stmt.bindInt(3, timz); _ = try stmt.step(); }
pub fn canaAll(dbzz: *sqli.Db, aren: std.mem.Allocator) ![]Cana { var stmt = try dbzz.prep("SELECT urlz,sigj FROM cana ORDER BY urlz;"); defer stmt.fini(); var list: std.ArrayList(Cana) = .empty; while (try stmt.step()) { const sig = std.json.parseFromSliceLeaky(Sig, aren, stmt.colText(1), .{ .allocate = .alloc_always }) catch continue; try list.append(aren, .{ .urlz = try aren.dupe(u8, stmt.colText(0)), .sig = sig }); } return list.toOwnedSlice(aren); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
