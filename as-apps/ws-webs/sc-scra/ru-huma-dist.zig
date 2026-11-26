// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Human timing: log-logistic delays, persona, fatigue
// Flo: two uniforms > 80/20 short or long log-logistic > clamp to the config range > scaled by persona and fatigue
// I/O: uniforms in (0,1) + range + factor (caller) > delay (pure, no clock, no entropy)
// ===================================================================
const std = @import("std");
const CF = .{ .beta = 3.0, .shrt = 0.35, .long = 0.8, .eps = 1e-6, .drif = 0.05, .spdl = 0.85, .spdh = 1.15, .tird = 0.3, .tirh = 7200000.0, .plol = 0.15, .ploh = 0.25, .perd = 23, .pers = 14, .tau = 6.283185307179586 };
pub const Pers = struct { speed: f64, plong: f64 };
pub fn hashOf(text: []const u8) u64 { var hsh: u64 = 0xcbf29ce484222325; for (text) |chr| { hsh ^= chr; hsh *%= 0x100000001b3; } return hsh; }
pub fn logl(uni: f64, med: f64) f64 { const uc = std.math.clamp(uni, CF.eps, 1.0 - CF.eps); return med * std.math.pow(f64, uc / (1.0 - uc), 1.0 / CF.beta); }
pub fn pick(upik: f64, uval: f64, lo: u64, hi: u64, fact: f64, plong: f64) u64 { if (hi <= lo or lo == 0) return lo; const lof: f64 = @floatFromInt(lo); const hif: f64 = @floatFromInt(hi); const rat = hif / lof; const long = upik < plong; const med = lof * std.math.pow(f64, rat, if (long) CF.long else CF.shrt) * fact; return @intFromFloat(std.math.clamp(logl(uval, med), lof, hif)); }
pub fn persona(hash: u64, day: i64) Pers { const unit: f64 = @as(f64, @floatFromInt(hash >> 11)) / 9007199254740992.0; const base = CF.spdl + (CF.spdh - CF.spdl) * unit; const pha: f64 = @as(f64, @floatFromInt((hash >> 3) & 1023)) / 1024.0 * CF.tau; const per: f64 = @floatFromInt(CF.perd + hash % CF.pers); const drf = 1.0 + CF.drif * @sin(@as(f64, @floatFromInt(day)) / per * CF.tau + pha); const spd = std.math.clamp(base * drf, CF.spdl - 0.05, CF.spdh + 0.05); return .{ .speed = spd, .plong = CF.plol + (CF.ploh - CF.plol) * std.math.clamp((spd - CF.spdl) / (CF.spdh - CF.spdl), 0.0, 1.0) }; }
pub fn fatigue(run_ms: u64) f64 { const age: f64 = @floatFromInt(run_ms); return 1.0 + CF.tird * (1.0 - @exp(-age / CF.tirh)); }
pub fn factor(pers: Pers, run_ms: u64) f64 { return pers.speed * fatigue(run_ms); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
