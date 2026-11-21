// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Command run: pick a job, run it through the session, print the report, map to exit code
// Flo: open store + browser > build Sess with the ladder mode > dispatch job > print text or JSON > exit code 0-4
// I/O: Ctx + job words (caller) > Report on stdout; alert on halt; exit code
// ===================================================================
const std = @import("std"); const ctxz = @import("ct-ctrl-ctxz.zig"); const sess = @import("ru-sess-ctxz.zig"); const rd = @import("ru-chat-read.zig"); const snd = @import("ru-chat-send.zig"); const grp = @import("ru-chat-grou.zig"); const rem = @import("ru-chat-remi.zig"); const rec = @import("ru-reci-main.zig"); const code = @import("ct-exit-code.zig"); const snap = @import("ru-page-snap.zig"); const jobs = @import("ru-jobs-main.zig");
pub const Out = struct { ok: bool, job: []const u8, mode: []const u8, sent: u32, prev: u32, skip: u32, lines: []const []const u8 };
pub fn runRun(ctx: *ctxz.Ctx) !u8 { if (ctx.args.rest.len == 0) return error.BadJob; const job = ctx.args.rest[0]; var sto = try ctxz.openStor(ctx); defer sto.close(); _ = sto.purge(ctxz.nowMs(ctx), ctx.cfg.msgs_keep_days) catch 0; var live = try ctxz.openLive(ctx, false); defer live.close(); var ses = sess.Sess.init(ctx.init.gpa, ctx.iozz, ctx.allo, ctx.cfg, &sto, live.conn, ctx.args.mode); ses.job = job;
const rep = jobs.dispatch(&ses, job, ctx.args.rest[1..]) catch |err| { if (err == error.Halted or err == error.NeedLogin) ctxz.alert(ctx, @errorName(err)); return err; };
const modz = @tagName(ctx.args.mode); if (ctx.args.json) { try ctxz.emit(ctx, try std.json.Stringify.valueAlloc(ctx.allo, Out{ .ok = true, .job = job, .mode = modz, .sent = rep.sent, .prev = rep.prev, .skip = rep.skip, .lines = rep.lines }, .{})); try ctxz.emit(ctx, "\n"); } else { for (rep.lines) |ln| try ctxz.emitf(ctx, "{s}\n", .{ln}); try ctxz.emitf(ctx, "{s} · mode {s} · done {d} · preview {d} · skipped {d}\n", .{ job, modz, rep.sent, rep.prev, rep.skip }); if (ctx.args.mode == .dry or ctx.args.mode == .read) try ctxz.emit(ctx, "nothing was changed (add --live to act)\n"); }
return code.jobCode(rep.sent + rep.prev, 0, rep.skip, 0, false); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
