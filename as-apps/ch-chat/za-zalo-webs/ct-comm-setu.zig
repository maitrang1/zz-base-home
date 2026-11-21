// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Command setup: check browser and folders, explain the risk, record consent once, print the next steps
// Flo: find browser > open store (folders + owner-only) > text in Vietnamese or English > --yes records the date > next steps
// I/O: Ctx (caller) > consent date in the store; stdout text; safe to run again
// ===================================================================
const std = @import("std"); const ctxz = @import("ct-ctrl-ctxz.zig"); const brow = @import("nt-brow-laun.zig"); const flo = @import("st-flow-data.zig");
pub const RISK_VI = "Zalo không cho phép tự động hóa trên tài khoản cá nhân. Tài khoản của bạn có thể bị hạn chế hoặc khóa dù za đã chạy chậm và an toàn. Bạn chấp nhận rủi ro này.";
pub const RISK_EN = "Zalo does not allow automation on personal accounts. Your account can still be restricted or locked even though za runs slowly and safely. You accept this risk.";
pub fn setupRun(ctx: *ctxz.Ctx) !u8 { const vi = std.mem.eql(u8, ctx.cfg.lang_main_code, "vi"); const exe = try brow.exeFind(ctx.init.gpa, ctx.iozz, ctx.cfg.brow_exec_path); if (exe) |path| { defer ctx.init.gpa.free(path); try ctxz.emitf(ctx, "{s}: {s}\n", .{ if (vi) "trình duyệt" else "browser", path }); } else { try ctxz.emit(ctx, if (vi) "không tìm thấy Chrome hoặc Edge: hãy cài Chrome\n" else "Chrome or Edge not found: please install Chrome\n"); return 1; }
var sto = try ctxz.openStor(ctx); defer sto.close(); try ctxz.emitf(ctx, "{s}: {s}\n", .{ if (vi) "dữ liệu" else "data", ctx.stat }); try ctxz.emit(ctx, if (vi) RISK_VI else RISK_EN); try ctxz.emit(ctx, "\n");
if (ctxz.consentOk(&sto, ctx.allo)) { try ctxz.emit(ctx, if (vi) "đã đồng ý trước đó\n" else "already accepted\n"); } else if (ctx.args.yes) { var buf: [24]u8 = undefined; try sto.metaSet("tos_ok", try std.fmt.bufPrint(&buf, "{d}", .{ctxz.nowMs(ctx)})); try sto.logAdd(ctxz.nowMs(ctx), "info", "setup", "risk accepted"); _ = flo; try ctxz.emit(ctx, if (vi) "đã ghi nhận đồng ý\n" else "acceptance recorded\n"); } else { try ctxz.emit(ctx, if (vi) "để đồng ý và dùng --live, chạy: za setup --yes\n" else "to accept and use --live, run: za setup --yes\n"); return 3; }
try ctxz.emit(ctx, if (vi) "bước tiếp: za login → za run canary --read → za run send <tên> <nội dung> (xem trước) → thêm --live\n" else "next: za login → za run canary --read → za run send <name> <text> (preview) → add --live\n"); return 0; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
