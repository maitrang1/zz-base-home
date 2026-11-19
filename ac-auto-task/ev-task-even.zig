// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Filesystem and control trigger states, fire verdicts
// Flo: statArmz validates sche > duez each tick samples path or latch > rising edge fires; first sample is baseline, never a fire (boot excepted); queu claims one file
// I/O: kind + sche path or none (store, armz) > Stat + duez verdict + claimed file (ticker)
// ===================================================================
const std = @import("std"); const watc = @import("watch");
pub const CF = .{ .boot_dely_defa = 0, .queu_clai_maxz = 1, .clai_size = 512, .minu_msec = 60_000, .trim = " \t", .pref = "file:" };
pub const ArmzErro = error{ NeedsPath, BadFlagPrefix, NotEventType };
pub const Kind = enum { boot, even, flag, hand, queu };
pub const Stat = struct {
kind: Kind, path: []const u8 = "", mtim_last: i128 = 0, pres_wasz: bool = false, prim: bool = false, boot_fire: bool = false, boot_read_msec: i64 = 0, dely_minu: u32 = 0, hand_requ: bool = false, clai_buff: [CF.clai_size]u8 = undefined, clai_leng: usize = 0,
pub fn clai(self: *const Stat) []const u8 { return self.clai_buff[0..self.clai_leng]; }
pub fn duez(self: *Stat, iozz: std.Io, nowz_msec: i64) bool { switch (self.kind) { .boot => { if (self.boot_fire) return false; if (self.boot_read_msec == 0) { self.boot_read_msec = nowz_msec + @as(i64, self.dely_minu) * CF.minu_msec; if (self.dely_minu == 0) { self.boot_fire = true; return true; } return false; } if (nowz_msec < self.boot_read_msec) return false; self.boot_fire = true; return true; }, .hand => { if (!self.hand_requ) return false; self.hand_requ = false; return true; }, .even => { const mtim_nowz = watc.mtimNewe(iozz, self.path); if (mtim_nowz == 0) return false; if (!self.prim) { self.prim = true; self.mtim_last = mtim_nowz; return false; } if (mtim_nowz == self.mtim_last) return false; self.mtim_last = mtim_nowz; return true; }, .flag => { const pres = fileExis(iozz, self.path); if (!self.prim) { self.prim = true; self.pres_wasz = pres; return false; } const risi = pres and !self.pres_wasz; self.pres_wasz = pres; return risi; }, .queu => { const name = entrFirs(iozz, self.path) orelse return false; if (name.len > self.clai_buff.len) return false; @memcpy(self.clai_buff[0..name.len], name); self.clai_leng = name.len; return true; } } }
pub fn typeName(self: *const Stat) []const u8 { return switch (self.kind) { .boot => "boot", .even => "even", .flag => "flag", .hand => "hand", .queu => "queu" }; }
};
fn fileExis(iozz: std.Io, path: []const u8) bool { if (path.len == 0) return false; _ = std.Io.Dir.cwd().statFile(iozz, path, .{}) catch return false; return true; }
fn entrFirs(iozz: std.Io, path: []const u8) ?[]const u8 { if (path.len == 0) return null; var dirz = std.Io.Dir.cwd().openDir(iozz, path, .{ .iterate = true }) catch return null; defer dirz.close(iozz); var iter = dirz.iterate(); while (iter.next(iozz) catch null) |entr| { if (entr.kind == .directory) continue; return entr.name; } return null; }
pub fn statArmz(kind: []const u8, sche: ?[]const u8, dely_minu: ?u32) ArmzErro!Stat { if (std.mem.eql(u8, kind, "boot")) return .{ .kind = .boot, .dely_minu = dely_minu orelse 0 }; if (std.mem.eql(u8, kind, "hand")) return .{ .kind = .hand }; const rawz = sche orelse return ArmzErro.NeedsPath; const schz = std.mem.trim(u8, rawz, CF.trim); if (schz.len == 0) return ArmzErro.NeedsPath; if (std.mem.eql(u8, kind, "even")) return .{ .kind = .even, .path = schz }; if (std.mem.eql(u8, kind, "queu")) return .{ .kind = .queu, .path = schz }; if (std.mem.eql(u8, kind, "flag")) { if (!std.mem.startsWith(u8, schz, CF.pref)) return ArmzErro.BadFlagPrefix; const patz = std.mem.trim(u8, schz[CF.pref.len..], CF.trim); if (patz.len == 0) return ArmzErro.NeedsPath; return .{ .kind = .flag, .path = patz }; } return ArmzErro.NotEventType; }
pub fn typeEvenChec(kind: []const u8) bool { const allz = [_][]const u8{ "boot", "even", "flag", "hand", "queu" }; for (allz) |item| if (std.mem.eql(u8, item, kind)) return true; return false; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
