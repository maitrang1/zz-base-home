// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Command login: open Zalo Web in a visible window, wait while the owner scans the QR
// Flo: launch Chrome on own profile > poll page text > QR page: tell owner once > chat page: done > halt words: alert > timeout: NeedLogin
// I/O: Ctx (caller) > session saved in the profile dir; stdout text; exit 0 or 4
// ===================================================================
const std = @import("std"); const ctxz = @import("ct-ctrl-ctxz.zig"); const snap = @import("ru-page-snap.zig"); const halt = @import("ru-safe-halt.zig"); const lab = @import("cf-labl-load.zig");
const CF = .{ .tick = 2000 };
pub fn loginRun(ctx: *ctxz.Ctx) !u8 { var live = try ctxz.openLive(ctx, true); defer live.close(); var reg = try lab.load(ctx.allo, ctx.iozz, ctx.cfg.labl_file_path); var told = false; const total: u64 = @as(u64, ctx.cfg.logi_wait_secs) * 1000; var spent: u64 = 0; while (spent <= total) : (spent += CF.tick) { var aren = std.heap.ArenaAllocator.init(ctx.init.gpa); defer aren.deinit(); const txt = snap.pageText(aren.allocator(), live.conn) catch ""; const ver = try halt.check(aren.allocator(), ctx.cfg, &reg, txt); switch (ver.kind) { .okay => { if (txt.len > 0) { try ctxz.emit(ctx, "logged in: session saved in the za profile\n"); return 0; } }, .need, .unsf => { ctxz.alert(ctx, ver.word); return error.Halted; }, .login => { if (!told) { try ctxz.emit(ctx, "Scan the QR code in the window with the Zalo phone app, then approve on the phone.\n"); told = true; } } } std.Io.sleep(ctx.iozz, .fromMilliseconds(CF.tick), .awake) catch {}; } return error.NeedLogin; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
