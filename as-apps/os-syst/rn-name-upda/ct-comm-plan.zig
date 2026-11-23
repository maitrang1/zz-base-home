// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: rn plan OLD NEW: list every reference a rename would patch
// Flo: resolve paths > check sibling rename > build forms > walk roots > classify > print summary + items
// I/O: OLD NEW + config > text or JSON on stdout, exit 0 (clean) or 3 (flagged skips); writes nothing
// Run: E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn.exe plan E:\proj\old E:\proj\new
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
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
fn badText(bad: Bad) []const u8 {
return switch (bad) {
.none => "",
.oldz_miss => "rn: old path not found. Check the spelling and run again.\n",
.newz_exis => "rn: new path already exists. Pick a free name.\n",
.sibl_only => "rn: rename keeps the same parent folder. A move is not built yet.\n",
.same_name => "rn: old and new names are the same. Nothing to do.\n",
};
}
pub const Outz = struct { old: []const u8, new: []const u8, summ: plan.Summ, walk: walk.Wstat, items: []const plan.Item };
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
pub fn collect(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8, wst: *walk.Wstat) ![]plan.Item {
const targ: walk.Targ = .{ .osy = ctxz.osy, .old = old, .new = new, .olds = try vari.absVari(ctxz.allo, ctxz.osy, old), .news = try vari.absVari(ctxz.allo, ctxz.osy, new) };
var items: std.ArrayList(plan.Item) = .empty;
const skps = try skipsOf(ctxz);
for (try rootsOf(ctxz, old)) |root| try walk.walkRoot(ctxz.allo, ctxz.allo, ctxz.iozz, ctxz.conf, targ, root, skps, &items, wst);
return items.toOwnedSlice(ctxz.allo);
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 2) return exit.Erro.Usag;
const old = try ctxz.absOf(args[0]);
const new = try ctxz.absOf(args[1]);
const bad = checkPair(ctxz, old, new);
if (bad != .none) { std.debug.print("{s}", .{badText(bad)}); return .fail; }
var wst: walk.Wstat = .{};
const items = try collect(ctxz, old, new, &wst);
const summ = plan.summOf(items);
const code: exit.Code = if (summ.skip > 0) .find else .okay;
if (ctxz.ladd.json) {
const body = try std.json.Stringify.valueAlloc(ctxz.allo, Outz{ .old = old, .new = new, .summ = summ, .walk = wst, .items = items }, .{});
try ctxz.outw.print("{s}\n", .{body});
return code;
}
try ctxz.outw.print("plan {s} -> {s}\napply {d} · skip {d} (comp {d}, enco {d}) · dirs {d} files {d} scanned {d} bin {d} big {d} err {d}\n", .{ old, new, summ.appl, summ.skip, summ.comp, summ.enco, wst.dirs, wst.filz, wst.scan, wst.bina, wst.bigz, wst.errz });
for (items, 0..) |item, indx| {
if (indx >= ctxz.conf.plan_line_maxz) { try ctxz.outw.print("… {d} more (use --json)\n", .{items.len - indx}); break; }
try ctxz.outw.print("{s} {s} {s}:{d} {s}\n", .{ if (item.skip) "skip" else "do  ", @tagName(item.clas), item.path, item.line, @tagName(item.kind) });
}
return code;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
