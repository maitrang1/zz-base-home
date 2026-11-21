// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Circuit breaker: halt the run when failures spike
// Flo: push ok/fail into a sliding window > trip when enough samples and fail share too high > stay tripped until reset
// I/O: outcome flags (caller) > tripped flag; window of 64 results max
// ===================================================================
const std = @import("std");
const CF = .{ .maxw = 64 };
pub const Brea = struct { bits: u64 = 0, cntz: u8 = 0, winz: u8 = 20, minz: u8 = 10, pctz: u8 = 50, trip: bool = false,
pub fn init(winz: u8, minz: u8, pctz: u8) Brea { return .{ .winz = @min(@max(winz, 1), CF.maxw), .minz = @max(minz, 1), .pctz = @min(pctz, 100) }; }
fn mask(self: *const Brea) u64 { return if (self.winz >= CF.maxw) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(self.winz)) - 1; }
pub fn push(self: *Brea, okay: bool) void { self.bits = ((self.bits << 1) | @as(u64, if (okay) 0 else 1)) & self.mask(); if (self.cntz < self.winz) self.cntz += 1; if (self.cntz >= self.minz and self.fai2() * 100 >= @as(u32, self.pctz) * self.cntz) self.trip = true; }
pub fn fai2(self: *const Brea) u32 { return @popCount(self.bits); }
pub fn reset(self: *Brea) void { self.bits = 0; self.cntz = 0; self.trip = false; } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
