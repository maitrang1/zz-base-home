// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Human pace: random delays, daily caps, warm-up, quiet hours
// Flo: seeded rng > log-normal delay in range > warm-up percent from account age > cap per action kind > quiet hour check
// I/O: ms and config numbers (caller) > delays in ms, caps, bool quiet (pure, no clock reads)
// ===================================================================
const std = @import("std"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .golz = 0x9E3779B97F4A7C15, .mix1 = 0xBF58476D1CE4E5B9, .mix2 = 0x94D049BB133111EB, .dayz = 86400000, .minz = 60000, .warm_floo = 20, .sigm_div = 4.0 };
pub const Kind = enum { acct, prod, data, mone, acce, sett, help };
pub const Rng = struct { sta: u64,
pub fn init(seed: u64) Rng { return .{ .sta = seed }; }
pub fn next(self: *Rng) u64 { self.sta +%= CF.golz; var zed = self.sta; zed = (zed ^ (zed >> 30)) *% CF.mix1; zed = (zed ^ (zed >> 27)) *% CF.mix2; return zed ^ (zed >> 31); }
pub fn unit(self: *Rng) f64 { return (@as(f64, @floatFromInt(self.next() >> 11)) + 0.5) / 9007199254740992.0; }
pub fn norm(self: *Rng) f64 { const ua = self.unit(); const ub = self.unit(); return @sqrt(-2.0 * @log(ua)) * @cos(2.0 * std.math.pi * ub); }
pub fn span(self: *Rng, lo: u64, hi: u64) u64 { if (hi <= lo) return lo; return lo + self.next() % (hi - lo + 1); } };
pub fn logn(rng: *Rng, lo: u64, hi: u64) u64 { if (hi <= lo or lo == 0) return lo; const lof: f64 = @floatFromInt(lo); const hif: f64 = @floatFromInt(hi); const sig = @log(hif / lof) / CF.sigm_div; const val = @sqrt(lof * hif) * @exp(sig * rng.norm()); return @intFromFloat(std.math.clamp(val, lof, hif)); }
pub fn scaled(ms: u64, perc: u32) u64 { return ms * perc / 100; }
pub fn warmPerc(born: i64, now: i64, days: u32) u32 { if (days == 0 or now <= born) return if (days == 0) 100 else CF.warm_floo; const age: u64 = @intCast(now - born); const full: u64 = @as(u64, days) * CF.dayz; if (age >= full) return 100; return @intCast(CF.warm_floo + (100 - CF.warm_floo) * age / full); }
pub fn capEff(base: u32, perc: u32) u32 { if (base == 0) return 0; return @max(1, @as(u32, @intCast(@as(u64, base) * perc / 100))); }
pub fn capOf(conf: cfgz.Conf, kind: Kind) u32 { return switch (kind) { .acct => conf.capz_acct_dayz, .prod => conf.capz_prod_dayz, .data => conf.capz_data_dayz, .mone => conf.capz_mone_dayz, .acce => conf.capz_acce_dayz, .sett => conf.capz_sett_dayz, .help => conf.capz_help_dayz }; }
pub fn hourLocal(now: i64, zone: i32) u8 { const mins = @divFloor(now, CF.minz) + zone; return @intCast(@divFloor(@mod(mins, 1440), 60)); }
pub fn quietNow(now: i64, zone: i32, rang: [2]u8) bool { if (rang[0] == rang[1]) return false; const hor = hourLocal(now, zone); if (rang[0] < rang[1]) return hor >= rang[0] and hor < rang[1]; return hor >= rang[0] or hor < rang[1]; }
pub fn dayStart(now: i64) i64 { return now - @mod(now, @as(i64, CF.dayz)); }
pub fn nap(iozz: std.Io, ms: u64, perc: u32) void { const real = scaled(ms, perc); if (real == 0) return; std.Io.sleep(iozz, .fromMilliseconds(@intCast(real)), .awake) catch {}; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
