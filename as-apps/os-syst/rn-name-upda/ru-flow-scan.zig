// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Scan stage shared by plan, run and verify
// Flo: check old/new pair > roots + skip list > build forms (text + binary) > walk roots > locations > items + lrefs
// I/O: normalized old/new + Ctxz > checked pair, Scan {items, lrefs, counts}
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const loca = @import("sy-loca-list.zig");
pub const Bad = enum { none, oldz_miss, newz_exis, sibl_only, same_name };
pub const Scan = struct { items: []plan.Item, lrefs: []plan.Lref, wst: walk.Wstat };
pub fn checkPair(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8) Bad {
const osy = ctxz.osy;
if (!ctxz.exists(old)) return .oldz_miss;
if (!osys.eqlz(osy, osys.dirOf(old), osys.dirOf(new))) return .sibl_only;
const bold = osys.baseOf(old);
const bnew = osys.baseOf(new);
if (std.mem.eql(u8, bold, bnew)) return .same_name;
if (!osys.eqlz(osy, bold, bnew) and ctxz.exists(new)) return .newz_exis;
return .none;
}
pub fn badText(bad: Bad) []const u8 {
return switch (bad) {
.none => "",
.oldz_miss => "rn-name-upda: old path not found. Check the spelling and run again.\n",
.newz_exis => "rn-name-upda: new path already exists. Pick a free name.\n",
.sibl_only => "rn-name-upda: rename keeps the same parent folder. A move is not built yet.\n",
.same_name => "rn-name-upda: old and new names are the same. Nothing to do.\n",
};
}
pub fn rootsOf(ctxz: *const cx.Ctxz, old: []const u8) ![]const []const u8 {
if (ctxz.conf.scan_root_list.len == 0) {
if (ctxz.osy.wind and ctxz.conf.scan_alls_driv) {
const drvs = try osys.drivesFixed(ctxz.allo);
if (drvs.len > 0) return @ptrCast(drvs);
}
return try ctxz.allo.dupe([]const u8, &.{osys.rootOf(old)});
}
var list: std.ArrayList([]const u8) = .empty;
for (ctxz.conf.scan_root_list) |raww| try list.append(ctxz.allo, try ctxz.absOf(raww));
return list.toOwnedSlice(ctxz.allo);
}
pub fn normList(allo: std.mem.Allocator, osy: osys.Osys, list: []const []const u8) ![]const []const u8 {
const outz = try allo.alloc([]const u8, list.len);
for (list, 0..) |item, indx| {
const dupe = try allo.dupe(u8, item);
if (osy.wind) std.mem.replaceScalar(u8, dupe, '\\', '/');
outz[indx] = dupe;
}
return outz;
}
pub fn skipsOf(ctxz: *const cx.Ctxz) ![]const []const u8 {
var list: std.ArrayList([]const u8) = .empty;
for (try normList(ctxz.allo, ctxz.osy, ctxz.conf.scan_skip_list)) |item| try list.append(ctxz.allo, item);
try list.append(ctxz.allo, try ctxz.dirzData());
return list.toOwnedSlice(ctxz.allo);
}
pub fn targOf(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8) !walk.Targ {
const olds = try vari.absVari(ctxz.allo, ctxz.osy, old);
const news = try vari.absVari(ctxz.allo, ctxz.osy, new);
const home = osys.normPath(ctxz.allo, ctxz.osy, ctxz.home) catch "";
return .{ .osy = ctxz.osy, .old = old, .new = new, .olds = olds, .news = news, .bolds = try std.mem.concat(ctxz.allo, vari.Vari, &.{ olds, try vari.u16Vari(ctxz.allo, olds) }), .bnews = try std.mem.concat(ctxz.allo, vari.Vari, &.{ news, try vari.u16Vari(ctxz.allo, news) }), .home = home };
}
pub fn collect(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8) !Scan {
const targ = try targOf(ctxz, old, new);
var outc: walk.Outc = .{};
const skps = try skipsOf(ctxz);
var conf = ctxz.conf;
conf.skip_path_list = try normList(ctxz.allo, ctxz.osy, ctxz.conf.skip_path_list);
for (try rootsOf(ctxz, old)) |root| try walk.walkRoot(ctxz.allo, ctxz.gpaz, ctxz.iozz, conf, targ, root, skps, &outc);
try loca.collect(ctxz, targ, &outc);
return .{ .items = try outc.items.toOwnedSlice(ctxz.allo), .lrefs = try outc.lrefs.toOwnedSlice(ctxz.allo), .wst = outc.wst };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
