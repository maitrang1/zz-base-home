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
pub fn deinit(self: *Rate) void { var iter = self.nexz.keyIterator(); while (iter.next()) |key| self.gpaz.free(key.*); self.nexz.deinit(self.gpaz); }
pub fn wait(self: *Rate, host: []const u8, now: i64) i64 { const nexz = self.nexz.get(host) orelse return 0; return if (nexz > now) nexz - now else 0; }
fn slot(self: *Rate, host: []const u8, valu: i64) !void { if (self.nexz.getPtr(host)) |ptr| { ptr.* = valu; return; } const key = try self.gpaz.dupe(u8, host); errdefer self.gpaz.free(key); try self.nexz.put(self.gpaz, key, valu); }
pub fn mark(self: *Rate, host: []const u8, now: i64, gap: i64) !void { const jit: i64 = if (gap >= CF.jitz) @intCast(self.prng.random().uintLessThan(u64, @intCast(@divTrunc(gap, CF.jitz) + 1))) else 0; try self.slot(host, now + gap + jit); }
pub fn hold(self: *Rate, host: []const u8, now: i64, retr_ms: i64) !void { const till = now + @min(@max(retr_ms, 0), CF.holz); const cur = self.nexz.get(host) orelse 0; try self.slot(host, @max(cur, till)); } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
