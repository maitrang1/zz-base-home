// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: CLI glue for live feeds: fetch --stream sse|poll|ws
// Flo: pick reader > frames under strm_time_seco and strm_frme_maxz > JSONL > save as record kind strm > print outcome
// I/O: Ctx (caller, --live required) > Outc line; exit 0 saved, 1 nothing read
// ===================================================================
const std = @import("std"); const cx = @import("ct-ctrl-ctxz.zig"); const strm = @import("nt-strm-read.zig"); const brwx = @import("ct-ctrl-brow.zig"); const pipe = @import("ru-page-fetc.zig"); const urln = @import("ut-urlz-norm.zig"); const exit = @import("ct-exit-code.zig");
pub fn runStrm(ctx: *const cx.Ctx) !u8 { const mode = ctx.args.strm; const isws = std.mem.eql(u8, mode, "ws"); if (!isws and !std.mem.eql(u8, mode, "sse") and !std.mem.eql(u8, mode, "poll")) return error.BadUsage; const norm = try urln.urlNorm(ctx.allo, ctx.args.urlz); const opts: strm.Opts = .{ .time_mill = ctx.conf.strm_time_seco * 1000, .framz = ctx.conf.strm_frme_maxz, .repeat = std.mem.eql(u8, mode, "poll") };
var frames: []const []const u8 = &.{}; if (isws) { var brw = (try brwx.brwMake(ctx, "")) orelse return error.NoBrowser; defer brw.deinit(); frames = try strm.wsRead(&brw, ctx.allo, norm, opts); } else { frames = try strm.sseRead(ctx.init.gpa, ctx.allo, ctx.iozz, norm, opts); }
if (frames.len == 0) { try cx.outz(ctx, "stream | 0 frames | nothing saved"); return 1; } const body = try strm.jsonl(ctx.allo, frames); var dbzz = try cx.dbOpen(ctx); defer dbzz.close(); const outc = try pipe.pageSave(ctx.allo, ctx.iozz, ctx.conf, &dbzz, ctx.dirz, norm, null, .{ .code = 200, .ctyp = "application/x-ndjson", .body = body }); const plain = try std.fmt.allocPrint(ctx.allo, "stream | {d} frames | {s} | {s} | {s}", .{ frames.len, outc.stat, outc.kind, outc.hexz }); try cx.outz(ctx, try cx.jsonOr(ctx, outc, plain)); return exit.outcCode(outc.stat, outc.code); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
