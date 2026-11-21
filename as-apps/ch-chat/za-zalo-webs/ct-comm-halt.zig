// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Commands pause, stop, resume, log: owner control over the halt flag and the activity log
// Flo: open store > set or clear halt flag (running jobs stop at the next action) > or print log tail
// I/O: Ctx (caller) > halt flag in state db, stdout text or JSON; exit 0
// ===================================================================
const std = @import("std"); const ctxz = @import("ct-ctrl-ctxz.zig");
const CF = .{ .tail = 20 };
pub fn pauseRun(ctx: *ctxz.Ctx, why: []const u8) !u8 { var sto = try ctxz.openStor(ctx); defer sto.close(); try sto.haltSet(ctxz.nowMs(ctx), why); try sto.logAdd(ctxz.nowMs(ctx), "info", "owner", why); try ctxz.emitf(ctx, "{s}: all jobs stop at the next action\n", .{why}); return 0; }
pub fn resumeRun(ctx: *ctxz.Ctx) !u8 { var sto = try ctxz.openStor(ctx); defer sto.close(); try sto.haltClear(); try sto.logAdd(ctxz.nowMs(ctx), "info", "owner", "resume"); try ctxz.emit(ctx, "resumed\n"); return 0; }
pub fn purgeRun(ctx: *ctxz.Ctx) !u8 { var sto = try ctxz.openStor(ctx); defer sto.close(); const cnt = try sto.purge(ctxz.nowMs(ctx), ctx.cfg.msgs_keep_days); try ctxz.emitf(ctx, "purged {d} messages older than {d} days\n", .{ cnt, ctx.cfg.msgs_keep_days }); return 0; }
pub fn logRun(ctx: *ctxz.Ctx) !u8 { var sto = try ctxz.openStor(ctx); defer sto.close(); const rows = try sto.logTail(ctx.allo, CF.tail); if (ctx.args.json) { try ctxz.emit(ctx, try std.json.Stringify.valueAlloc(ctx.allo, rows, .{})); try ctxz.emit(ctx, "\n"); return 0; } for (rows) |row| try ctxz.emitf(ctx, "{d} {s} {s}: {s}\n", .{ row.ts, row.lvl, row.job, row.msg }); if (rows.len == 0) try ctxz.emit(ctx, "log is empty\n"); return 0; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
