// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Command probe: save a redacted dump of the current Zalo page for label discovery
// Flo: open browser > AX snapshot + page text > redact by registry > write <stat>/probe/<name>.json > print counts
// I/O: Ctx + name (caller) > redacted json file, stdout line; exit 0
// ===================================================================
const std = @import("std"); const ctxz = @import("ct-ctrl-ctxz.zig"); const snap = @import("ru-page-snap.zig"); const prob = @import("ru-page-prob.zig"); const lab = @import("cf-labl-load.zig"); const file = @import("st-stor-file.zig");
pub fn nameOk(name: []const u8) bool { if (name.len == 0 or name.len > 40) return false; for (name) |chr| { if (!(std.ascii.isLower(chr) or std.ascii.isDigit(chr) or chr == '-' or chr == '_')) return false; } return true; }
pub fn probeRun(ctx: *ctxz.Ctx) !u8 { if (ctx.args.rest.len != 1 or !nameOk(ctx.args.rest[0])) return error.BadJob; var live = try ctxz.openLive(ctx, false); defer live.close(); const reg = try lab.load(ctx.allo, ctx.iozz, ctx.cfg.labl_file_path); const nodes = try snap.axSnap(ctx.allo, live.conn); const text = try snap.pageText(ctx.allo, live.conn); const body = try prob.dump(ctx.allo, &reg, nodes, text, ctxz.nowMs(ctx)); const path = try std.fmt.allocPrint(ctx.allo, "{s}{c}probe{c}{s}.json", .{ ctx.stat, std.fs.path.sep, std.fs.path.sep, ctx.args.rest[0] }); try file.fileAtom(ctx.allo, ctx.iozz, path, body); try ctxz.emitf(ctx, "probe saved: {s} ({d} nodes, personal text hashed)\n", .{ path, nodes.len }); return 0; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
