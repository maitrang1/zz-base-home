// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: rn plan OLD NEW: list every reference a rename would patch
// Flo: resolve paths > check sibling rename > scan files, links, locations > classify > print summary + items
// I/O: OLD NEW + config > text or JSON on stdout, exit 0 (clean) or 3 (flagged skips); writes nothing
// Run: E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn.exe plan E:\proj\old E:\proj\new
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const scan = @import("ru-flow-scan.zig");
pub const Bad = scan.Bad;
pub const checkPair = scan.checkPair;
pub const Outz = struct { old: []const u8, new: []const u8, summ: plan.Summ, walk: walk.Wstat, items: []const plan.Item, lrefs: []const plan.Lref };
pub fn render(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8, scn: scan.Scan) !exit.Code {
const summ = plan.summAdd(plan.summOf(scn.items), plan.summL(scn.lrefs));
const wst = scn.wst;
const code: exit.Code = if (summ.skip > 0) .find else .okay;
if (ctxz.ladd.json) {
const body = try std.json.Stringify.valueAlloc(ctxz.allo, Outz{ .old = old, .new = new, .summ = summ, .walk = wst, .items = scn.items, .lrefs = scn.lrefs }, .{});
try ctxz.outw.print("{s}\n", .{body});
return code;
}
try ctxz.outw.print("plan {s} -> {s}\napply {d} · skip {d} (comp {d}, enco {d}){s}{s} · dirs {d} files {d} scanned {d} bin {d} big {d} link {d} err {d}\n", .{ old, new, summ.appl, summ.skip, summ.comp, summ.enco, if (summ.risk > 0) " risk " else "", if (summ.risk > 0) try std.fmt.allocPrint(ctxz.allo, "{d}", .{summ.risk}) else "", wst.dirs, wst.filz, wst.scan, wst.bina, wst.bigz, wst.link, wst.errz });
for (scn.items, 0..) |item, indx| {
if (indx >= ctxz.conf.plan_line_maxz) { try ctxz.outw.print("… {d} more (use --json)\n", .{scn.items.len - indx}); break; }
try ctxz.outw.print("{s} {s} {s}:{d} {s}\n", .{ if (item.skip) "skip" else "do  ", @tagName(item.clas), item.path, item.line, @tagName(item.kind) });
}
for (scn.lrefs) |lref| try ctxz.outw.print("{s} {s} {s} {s}\n", .{ if (lref.skip) "skip" else "do  ", @tagName(lref.clas), @tagName(lref.kind), lref.name });
return code;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 2) return exit.Erro.Usag;
const old = try ctxz.absOf(args[0]);
const new = try ctxz.absOf(args[1]);
const bad = scan.checkPair(ctxz, old, new);
if (bad != .none) { std.debug.print("{s}", .{scan.badText(bad)}); return .fail; }
return render(ctxz, old, new, try scan.collect(ctxz, old, new));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
