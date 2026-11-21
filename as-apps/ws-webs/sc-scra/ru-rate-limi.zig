// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Per-host politeness: gap, jitter, Retry-After hold
// Flo: ask wait ms for host > after a request mark next slot = now + gap + jitter > on 429/503 hold until Retry-After
// I/O: host + time (caller) > ms to wait; state kept in memory per host
// ===================================================================
const std = @import("std");
const CF = .{ .jitz = 4, .holz = 3600000 };
pub const Rate = struct { gpaz: std.mem.Allocator, nexz: std.StringHashMapUnmanaged(i64) = .empty, prng: std.Random.DefaultPrng,
pub fn init(gpaz: std.mem.Allocator, seed: u64) Rate { return .{ .gpaz = gpaz, .prng = std.Random.DefaultPrng.init(seed) }; }
pub fn deinit(self: *Rate) void { var iter = self.nexz.keyIterator(); while (iter.next()) |key2| self.gpaz.free(key2.*); self.nexz.deinit(self.gpaz); }
pub fn wait(self: *Rate, host: []const u8, nowz: i64) i64 { const nexz = self.nexz.get(host) orelse return 0; return if (nexz > nowz) nexz - nowz else 0; }
fn slot(self: *Rate, host: []const u8, valu: i64) !void { if (self.nexz.getPtr(host)) |ptr| { ptr.* = valu; return; } const key2 = try self.gpaz.dupe(u8, host); errdefer self.gpaz.free(key2); try self.nexz.put(self.gpaz, key2, valu); }
pub fn mark(self: *Rate, host: []const u8, nowz: i64, gap2: i64) !void { const jit2: i64 = if (gap2 >= CF.jitz) @intCast(self.prng.random().uintLessThan(u64, @intCast(@divTrunc(gap2, CF.jitz) + 1))) else 0; try self.slot(host, nowz + gap2 + jit2); }
pub fn hold(self: *Rate, host: []const u8, nowz: i64, retr_ms: i64) !void { const till = nowz + @min(@max(retr_ms, 0), CF.holz); const curr = self.nexz.get(host) orelse 0; try self.slot(host, @max(curr, till)); } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
