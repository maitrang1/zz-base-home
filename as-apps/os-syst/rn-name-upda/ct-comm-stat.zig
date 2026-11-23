// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: rn stat: version, OS, data dir, which skip keys are on
// Flo: read config > print one line + the skip list > exit 0
// I/O: config > text or JSON on stdout; read-only
// Run: E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn.exe stat
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
pub const CF = .{ .vers = "0.1.0" };
const Skip = struct { bina: bool, arch: bool, sign_hash: bool, othe_user: bool, syst_owne: bool, runn_proc: bool, sync_remo: bool, pack_mana: bool, comp_part: bool, urls_exte: bool, enco_vari: bool, gitz_hist: bool };
const Outz = struct { vers: []const u8, osys: []const u8, data: []const u8, skip: Skip };
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 0) return exit.Erro.Usag;
const conf = ctxz.conf;
const skip: Skip = .{ .bina = conf.skip_bina, .arch = conf.skip_arch, .sign_hash = conf.skip_sign_hash, .othe_user = conf.skip_othe_user, .syst_owne = conf.skip_syst_owne, .runn_proc = conf.skip_runn_proc, .sync_remo = conf.skip_sync_remo, .pack_mana = conf.skip_pack_mana, .comp_part = conf.skip_comp_part, .urls_exte = conf.skip_urls_exte, .enco_vari = conf.skip_enco_vari, .gitz_hist = conf.skip_gitz_hist };
const osnm = if (ctxz.osy.wind) "windows" else if (ctxz.osy.caze) "macos" else "unix";
const data = try ctxz.dirzData();
if (ctxz.ladd.json) {
const body = try std.json.Stringify.valueAlloc(ctxz.allo, Outz{ .vers = CF.vers, .osys = osnm, .data = data, .skip = skip }, .{});
try ctxz.outw.print("{s}\n", .{body});
return .okay;
}
try ctxz.outw.print("rn {s} · {s} · data {s}\nskip on:", .{ CF.vers, osnm, data });
inline for (@typeInfo(Skip).@"struct".field_names) |name| { if (@field(skip, name)) try ctxz.outw.print(" {s}", .{name}); }
try ctxz.outw.print("\n", .{});
return .okay;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
