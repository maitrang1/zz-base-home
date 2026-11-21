// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Human pace gate: delays, caps, quiet hours, warm-up ramp
// Flo: counts + clock in > quiet check > cap check > gap check > go, wait or deny verdict
// I/O: Lims + Stat + now ms (caller) > Verd; log-normal delay msec (seeded rng)
// ===================================================================
const std = @import("std"); const conf = @import("cf-conf-load.zig");
const CF = .{ .sigm = 0.5, .warm = 0.2, .mins = 60000, .hour = 3600000, .dayz = 86400000 };
pub const Kind = enum { read, send, newc, react, upld };
pub const Verd = struct { kind: enum { go, wait, quie, cap }, msec: u32 = 0 };
pub const Stat = struct { first_ms: i64 = 0, hour_cnt: u32 = 0, minu_cnt: u32 = 0, day_cnt: u32 = 0, newc_cnt: u32 = 0, last_ms: i64 = 0, reac_cnt: u32 = 0, upld_cnt: u32 = 0 };
pub const Lims = struct { hour: u32, dayz: u32, newc: u32, minu: u32, gapz: u32, qfrm: u8, qtoz: u8, utcz: i32, warm: u32, reac: u32 = 60, upld: u32 = 30 };
pub fn limsOf(cfg: conf.Conf) Lims { return .{ .hour = cfg.capz_send_hour, .dayz = cfg.capz_send_dayz, .newc = cfg.capz_newc_dayz, .minu = cfg.capz_send_minu, .gapz = cfg.gapz_send_msec, .qfrm = cfg.quie_hour_rang[0], .qtoz = cfg.quie_hour_rang[1], .utcz = cfg.loca_utcz_mins, .warm = cfg.warm_dayz_coun, .reac = cfg.capz_reac_dayz, .upld = cfg.capz_upld_dayz }; }
pub fn delayLogn(rand: std.Random, lowz: u32, higz: u32) u32 { if (higz <= lowz) return lowz; const lof: f64 = @floatFromInt(lowz); const hif: f64 = @floatFromInt(higz); const muzz = @log(@sqrt(lof * hif)); const nrm = rand.floatNorm(f64); const val = @exp(muzz + CF.sigm * nrm); const clp = @min(hif, @max(lof, val)); return @intFromFloat(@round(clp)); }
pub fn hourLocal(now_ms: i64, utcz: i32) u8 { const minu = @divFloor(now_ms, CF.mins) + utcz; return @intCast(@divFloor(@mod(minu, 1440), 60)); }
pub fn quietNow(now_ms: i64, utcz: i32, frmz: u8, toxx: u8) bool { if (frmz == toxx) return false; const hour = hourLocal(now_ms, utcz); if (frmz < toxx) return hour >= frmz and hour < toxx; return hour >= frmz or hour < toxx; }
pub fn warmFact(first_ms: i64, now_ms: i64, days: u32) f64 { if (days == 0 or first_ms <= 0) return 1.0; const agez = @max(0, now_ms - first_ms); const dayf: f64 = @as(f64, @floatFromInt(agez)) / @as(f64, CF.dayz); const full: f64 = @floatFromInt(days); if (dayf >= full) return 1.0; return CF.warm + (1.0 - CF.warm) * (dayf / full); }
pub fn capEff(base: u32, fact: f64) u32 { const val: u32 = @intFromFloat(@floor(@as(f64, @floatFromInt(base)) * fact)); return @max(1, val); }
pub fn gate(lim: Lims, sta: Stat, now_ms: i64, kind: Kind) Verd { if (quietNow(now_ms, lim.utcz, lim.qfrm, lim.qtoz)) return .{ .kind = .quie }; if (kind == .read) return .{ .kind = .go }; const fact = warmFact(sta.first_ms, now_ms, lim.warm); if (kind == .react) { if (sta.reac_cnt >= capEff(lim.reac, fact)) return .{ .kind = .cap }; return .{ .kind = .go }; } if (kind == .upld and sta.upld_cnt >= capEff(lim.upld, fact)) return .{ .kind = .cap }; if (sta.day_cnt >= capEff(lim.dayz, fact) or sta.hour_cnt >= capEff(lim.hour, fact)) return .{ .kind = .cap }; if (kind == .newc and sta.newc_cnt >= capEff(lim.newc, fact)) return .{ .kind = .cap }; if (sta.minu_cnt >= capEff(lim.minu, fact)) return .{ .kind = .wait, .msec = @intCast(@max(1, CF.mins - @mod(now_ms, CF.mins))) }; const gapn = now_ms - sta.last_ms; if (sta.last_ms > 0 and gapn >= 0 and gapn < lim.gapz) return .{ .kind = .wait, .msec = @intCast(@as(i64, lim.gapz) - gapn) }; return .{ .kind = .go }; }
pub fn gateErr(verd: Verd) !void { return switch (verd.kind) { .go, .wait => {}, .quie => error.QuietHrs, .cap => error.CapHit }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
