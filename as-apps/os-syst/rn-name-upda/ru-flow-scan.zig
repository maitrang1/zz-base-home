// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Scan stage shared by plan, run and verify
// Flo: check old/new pair > roots + skip list > build forms > walk roots > items
// I/O: normalized old/new + Ctxz > checked pair, Item list, Wstat counts
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
pub const Bad = enum { none, oldz_miss, newz_exis, sibl_only, same_name };
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
.oldz_miss => "rn: old path not found. Check the spelling and run again.\n",
.newz_exis => "rn: new path already exists. Pick a free name.\n",
.sibl_only => "rn: rename keeps the same parent folder. A move is not built yet.\n",
.same_name => "rn: old and new names are the same. Nothing to do.\n",
};
}
pub fn rootsOf(ctxz: *const cx.Ctxz, old: []const u8) ![]const []const u8 {
if (ctxz.conf.scan_root_list.len == 0) return try ctxz.allo.dupe([]const u8, &.{osys.rootOf(old)});
var list: std.ArrayList([]const u8) = .empty;
for (ctxz.conf.scan_root_list) |raww| try list.append(ctxz.allo, try ctxz.absOf(raww));
return list.toOwnedSlice(ctxz.allo);
}
pub fn skipsOf(ctxz: *const cx.Ctxz) ![]const []const u8 {
var list: std.ArrayList([]const u8) = .empty;
for (ctxz.conf.scan_skip_list) |item| try list.append(ctxz.allo, item);
try list.append(ctxz.allo, try ctxz.dirzData());
return list.toOwnedSlice(ctxz.allo);
}
pub fn targOf(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8) !walk.Targ { return .{ .osy = ctxz.osy, .old = old, .new = new, .olds = try vari.absVari(ctxz.allo, ctxz.osy, old), .news = try vari.absVari(ctxz.allo, ctxz.osy, new) }; }
pub fn collect(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8, wst: *walk.Wstat) ![]plan.Item {
const targ = try targOf(ctxz, old, new);
var items: std.ArrayList(plan.Item) = .empty;
const skps = try skipsOf(ctxz);
for (try rootsOf(ctxz, old)) |root| try walk.walkRoot(ctxz.allo, ctxz.gpaz, ctxz.iozz, ctxz.conf, targ, root, skps, &items, wst);
return items.toOwnedSlice(ctxz.allo);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
