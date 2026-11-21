// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: CLI glue for live feeds: fetch --stream sse|poll|ws
// Flo: pick reader > frames under strm_time_seco and strm_frme_maxz > JSONL > save as record kind strm > print outcome
// I/O: Ctx (caller, --live required) > Outc line; exit 0 saved, 1 nothing read
// ===================================================================
const std = @import("std"); const ctx3 = @import("ct-ctrl-ctxz.zig"); const strm = @import("nt-strm-read.zig"); const brwx = @import("ct-ctrl-brow.zig"); const pipe = @import("ru-page-fetc.zig"); const urln = @import("ut-urlz-norm.zig"); const site = @import("cf-site-rule.zig"); const exit = @import("ct-exit-code.zig");
pub fn runzStrm(ctx2: *const ctx3.Ctxz) !u8 { const mode = ctx2.args.strm; const isws = std.mem.eql(u8, mode, "ws"); if (!isws and !std.mem.eql(u8, mode, "sse") and !std.mem.eql(u8, mode, "poll")) return error.BadUsage; const norm = try urln.urlzNorm(ctx2.allo, ctx2.args.urlz); const spar = try urln.urlzSpli(norm); const mcfg = try site.siteConf(ctx2.allo, ctx2.conf, spar.host, spar.path); const opts: strm.Opts = .{ .time_mill = mcfg.strm_time_seco * 1000, .fra2 = mcfg.strm_frme_maxz, .repe = std.mem.eql(u8, mode, "poll") };
var fram: []const []const u8 = &.{}; if (isws) { var brwz = (try brwx.brwzMake(ctx2, "")) orelse return error.NoBrowser; defer brwz.deinit(); fram = try strm.wszzRead(&brwz, ctx2.allo, norm, opts); } else { fram = try strm.ssezRead(ctx2.init.gpa, ctx2.allo, ctx2.iozz, norm, opts); }
if (fram.len == 0) { try ctx3.outz(ctx2, "stream | 0 frames | nothing saved"); return 1; } const body = try strm.jso2(ctx2.allo, fram); var dbzz = try ctx3.dbzzOpen(ctx2); defer dbzz.close(); const outc = try pipe.pageSave(ctx2.allo, ctx2.iozz, ctx2.conf, &dbzz, ctx2.dirz, norm, null, .{ .code = 200, .ctyp = "application/x-ndjson", .body = body }); const plai = try std.fmt.allocPrint(ctx2.allo, "stream | {d} frames | {s} | {s} | {s}", .{ fram.len, outc.stat, outc.kind, outc.hexz }); try ctx3.outz(ctx2, try ctx3.jsonOrzz(ctx2, outc, plai)); return exit.outcCode(outc.stat, outc.code); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
