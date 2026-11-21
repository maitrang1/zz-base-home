// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Presence model: work sessions with breaks (seeded per day), reading time by message length, check interval with jitter
// Flo: day seed > alternating active and break segments (log-normal lengths) > state at a time > reading and think delay > next inbox check
// I/O: now ms + seed + ranges (caller) > Seg (active, ms left); delay msec
// ===================================================================
const std = @import("std"); const pace = @import("ru-huma-pace.zig");
const CF = .{ .mins = 60000, .dayz = 86400000, .wpmz = 225.0, .thkl = 600, .thkh = 2500, .maxr = 30000, .jitt = 30 };
pub const Seg = struct { active: bool, left_ms: i64 };
pub const Rng = struct { actv: [2]u32, brek: [2]u32 };
pub fn segAt(now_ms: i64, utcz: i32, seed: u64, rng: Rng) Seg { const loc = now_ms + @as(i64, utcz) * CF.mins; const day = @divFloor(loc, CF.dayz); const into = @mod(loc, CF.dayz); var prn = std.Random.DefaultPrng.init(seed ^ @as(u64, @bitCast(day)) *% 0x9E3779B97F4A7C15); const rand = prn.random(); var cur: i64 = 0; var active = true; while (true) { const lens = if (active) rng.actv else rng.brek; const span: i64 = @as(i64, pace.delayLogn(rand, @max(1, lens[0]), @max(lens[0], lens[1]))) * CF.mins; if (into < cur + span) return .{ .active = active, .left_ms = cur + span - into }; cur += span; active = !active; if (cur > CF.dayz * 2) return .{ .active = true, .left_ms = 1 }; } }
pub fn readDelay(rand: std.Random, incoming_len: usize) u32 { const words: f64 = @as(f64, @floatFromInt(incoming_len)) / 5.0; const base: f64 = words / CF.wpmz * 60000.0; const think = pace.delayLogn(rand, CF.thkl, CF.thkh); const total: f64 = base + @as(f64, @floatFromInt(think)); return @intFromFloat(@min(total, @as(f64, CF.maxr))); }
pub fn nextCheck(rand: std.Random, base_mins: u32) u32 { const base: u32 = @max(1, base_mins) * CF.mins; const span = base * CF.jitt / 100; const off = rand.uintLessThan(u32, span * 2 + 1); return base - span + off; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
