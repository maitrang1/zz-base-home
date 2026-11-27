// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: za-zalo-webs secret: list accounts from user-acct.json, no passwords
// Flo: the book loaded by the context > one line per account > count and limit
// I/O: Ctx (caller) > text or JSON on stdout; exit 0
// ===================================================================
const std = @import("std"); const ctxz = @import("ct-ctrl-ctxz.zig"); const book = @import("ut-acct-book.zig");
pub fn secretRun(ctx: *ctxz.Ctx) !u8 { const bk = ctx.book; if (ctx.args.json) { var out: std.ArrayList(u8) = .empty; for (bk.accs, 0..) |ac, ix| { try out.appendSlice(ctx.allo, try std.fmt.allocPrint(ctx.allo, "{s}{{\"id\":\"{s}\",\"caps\":{d}}}", .{ if (ix > 0) "," else "", ac.id, ac.scal })); } try ctxz.emitf(ctx, "{{\"file\":\"user-acct.json\",\"main\":\"{s}\",\"accounts\":[{s}]}}\n", .{ bk.main, out.items }); return 0; }
try ctxz.emitf(ctx, "secrets folder: {s}\n", .{ctx.secd}); if (!bk.filez) { try ctxz.emit(ctx, "no user-acct.json: one account \"main\". To use several, create it there: {\"main\":\"shop1\",\"accs\":[{\"id\":\"shop1\",\"label\":\"Shop\",\"phone\":\"0900000000\"}]}. za never stores or types a password.\n"); return 0; }
for (bk.accs) |ac| { try ctxz.emitf(ctx, "{s}{s}: {s} phone {s} lang={s} caps={d}%\n", .{ ac.id, if (std.mem.eql(u8, ac.id, bk.main)) " [main]" else "", if (ac.label.len > 0) ac.label else "-", try book.maskPhone(ctx.allo, ac.phone), if (ac.lang.len > 0) ac.lang else "default", ac.scal }); } try ctxz.emitf(ctx, "{d} account(s), limit {d}; each has its own browser profile: scan its QR once with za-zalo-webs login --acct <id>\n", .{ bk.accs.len, ctx.cfg.acct_maxx_coun }); return 0; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
