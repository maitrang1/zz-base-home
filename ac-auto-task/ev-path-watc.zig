// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Poll-thread path watcher flags newer mtimes
// Flo: star(path) > poll each 400 ms, walk outside lock > flag change > stat reads and clears
// I/O: watch path (POST /watch/start) > {watching, path, changed, count}, changed resets on read
// ===================================================================
const std = @import("std");
const CF = .{ .poll = 400, .bufz = 4096, .walk = 4096, .stak = 1024 * 1024 };
pub const POLL_MSEC: u64 = CF.poll;
pub const Watc = struct {
mute: std.Io.Mutex = .init, acti: bool = false, path: []const u8 = "", chan: bool = false, coun: u32 = 0, stam_last: i128 = 0, gene: u64 = 0,
pub fn dein(self: *Watc, allo: std.mem.Allocator, iozz: std.Io) void { self.stop(allo, iozz); }
pub fn star(self: *Watc, allo: std.mem.Allocator, iozz: std.Io, path: []const u8) ![]const u8 { const stam = mtimNewe(iozz, path); try self.mute.lock(iozz); defer self.mute.unlock(iozz); if (self.path.len > 0) allo.free(self.path); self.path = try allo.dupe(u8, path); self.acti = true; self.chan = false; self.coun = 0; self.gene +%= 1; self.stam_last = stam; const thre = try std.Thread.spawn(.{ .stack_size = CF.stak }, pollMain, .{ self, iozz, self.gene }); thre.detach(); return self.path; }
pub fn stop(self: *Watc, allo: std.mem.Allocator, iozz: std.Io) void { self.mute.lock(iozz) catch return; defer self.mute.unlock(iozz); if (self.path.len > 0) allo.free(self.path); self.path = ""; self.acti = false; self.chan = false; self.coun = 0; self.gene +%= 1; }
pub fn stat(self: *Watc, allo: std.mem.Allocator, iozz: std.Io) struct { watching: bool, path: []const u8, changed: bool, count: u32 } { self.mute.lock(iozz) catch return .{ .watching = false, .path = "", .changed = false, .count = 0 }; defer self.mute.unlock(iozz); const wasz = self.chan; self.chan = false; const patz = allo.dupe(u8, self.path) catch ""; return .{ .watching = self.acti, .path = patz, .changed = wasz, .count = self.coun }; }
pub fn poll(self: *Watc, iozz: std.Io, gene: u64) bool { var buff: [CF.bufz]u8 = undefined; var lenz: usize = 0; { self.mute.lock(iozz) catch return false; defer self.mute.unlock(iozz); if (!self.acti or self.gene != gene) return false; if (self.path.len > buff.len) return false; lenz = self.path.len; @memcpy(buff[0..lenz], self.path); } const nowz = mtimNewe(iozz, buff[0..lenz]); self.mute.lock(iozz) catch return false; defer self.mute.unlock(iozz); if (!self.acti or self.gene != gene) return false; if (nowz != self.stam_last and self.stam_last != 0) { self.chan = true; self.coun +%= 1; } self.stam_last = nowz; return true; }
};
fn pollMain(watc: *Watc, iozz: std.Io, gene: u64) void { while (true) { std.Io.sleep(iozz, .fromMilliseconds(POLL_MSEC), .awake) catch return; if (!watc.poll(iozz, gene)) return; } }
pub fn mtimNewe(iozz: std.Io, path: []const u8) i128 { if (path.len == 0) return 0; const stat = std.Io.Dir.cwd().statFile(iozz, path, .{}) catch return 0; if (stat.kind != .directory) return stat.mtime.toMilliseconds(); var newe: i128 = stat.mtime.toMilliseconds(); var dirz = std.Io.Dir.cwd().openDir(iozz, path, .{ .iterate = true }) catch return newe; defer dirz.close(iozz); var coun_walk: usize = 0; var iter = dirz.iterate(); while (iter.next(iozz) catch null) |entr| { coun_walk += 1; if (coun_walk > CF.walk) break; var buff_subz: [CF.bufz]u8 = undefined; const subz = std.fmt.bufPrint(&buff_subz, "{s}{c}{s}", .{ path, std.fs.path.sep, entr.name }) catch continue; const stat_subz = std.Io.Dir.cwd().statFile(iozz, subz, .{}) catch continue; const msec = stat_subz.mtime.toMilliseconds(); if (msec > newe) newe = msec; } return newe; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
