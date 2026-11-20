// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Chain triggers by link, supervise loops
// Flo: link: parent finishes > push done onto ring > next tick matches filter + depth cap > fire | loop: own thread > respawn on exit > backoff 1s doubling to 60s, reset after healthy run | stop: kill via registry by task id, never a raw pid
// I/O: "after:<parentId>[:ok|:fail]" (task sche) > LinkSpec; loop task (id, cmd, cwd, shell) > Supe; done ring (drop oldest, depth cap stops A>B>A loops; skip = exit 4 no-op member) > ticker
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const spawn = @import("spawn"); const registry = @import("registry");
pub const CF = .{ .back_minz_msec = 1000, .back_maxz_msec = 60_000, .heal_runz_msec = 60_000, .done_ring = 64, .maxz_casc_dept = 8, .wait_step_msec = 20, .pref = "after:", .trim = " \t" };
pub const LinkFilt = enum { anyz, okzz, fail };
pub const LinkSpec = struct { pare: []const u8, filt: LinkFilt };
pub const LinkErro = error{ BadPrefix, NoParent, BadFilter };
pub fn linkPars(inpu: []const u8) LinkErro!LinkSpec { const text = std.mem.trim(u8, inpu, CF.trim); if (!std.mem.startsWith(u8, text, CF.pref)) return LinkErro.BadPrefix; const rest = text[CF.pref.len..]; if (rest.len == 0) return LinkErro.NoParent; if (std.mem.lastIndexOfScalar(u8, rest, ':')) |colo| { const pare = std.mem.trim(u8, rest[0..colo], CF.trim); const suff = std.mem.trim(u8, rest[colo + 1 ..], CF.trim); if (pare.len == 0) return LinkErro.NoParent; if (std.mem.eql(u8, suff, "ok")) return .{ .pare = pare, .filt = .okzz }; if (std.mem.eql(u8, suff, "fail")) return .{ .pare = pare, .filt = .fail }; return LinkErro.BadFilter; } return .{ .pare = rest, .filt = .anyz }; }
pub const Done = struct {
iden: [128]u8 = undefined, iden_leng: usize = 0, okzz: bool = false, dept: u8 = 0, skip: bool = false,
pub fn name(self: *const Done) []const u8 { return self.iden[0..self.iden_leng]; }
};
pub const DoneRing = struct {
bufz: [CF.done_ring]Done = undefined, leng: usize = 0, drop: u32 = 0,
pub fn push(self: *DoneRing, iden: []const u8, okzz: bool, dept: u8) void { self.skipPush(iden, okzz, dept, false); }
pub fn skipPush(self: *DoneRing, iden: []const u8, okzz: bool, dept: u8, skip: bool) void { if (self.leng == CF.done_ring) { std.mem.copyForwards(Done, self.bufz[0 .. CF.done_ring - 1], self.bufz[1..CF.done_ring]); self.leng -= 1; self.drop += 1; } var done: Done = .{ .okzz = okzz, .dept = dept, .skip = skip }; const copy_leng = @min(iden.len, done.iden.len); @memcpy(done.iden[0..copy_leng], iden[0..copy_leng]); done.iden_leng = copy_leng; self.bufz[self.leng] = done; self.leng += 1; }
pub fn item(self: *const DoneRing) []const Done { return self.bufz[0..self.leng]; }
pub fn clea(self: *DoneRing) void { self.leng = 0; }
};
pub fn linkMatc(spec: LinkSpec, done: *const Done) bool { if (!std.mem.eql(u8, spec.pare, done.name())) return false; if (done.dept >= CF.maxz_casc_dept) return false; return switch (spec.filt) { .anyz => true, .okzz => done.okzz, .fail => !done.okzz }; }
pub const Supe = struct {
gpaz: std.mem.Allocator, iden: []const u8, cmdz: []const u8, cwdz: []const u8, shel: spawn.ShelKind,
stop: std.atomic.Value(bool) = .init(false), exit: std.atomic.Value(bool) = .init(false), rest: std.atomic.Value(u32) = .init(0), back_msec: u32 = CF.back_minz_msec,
pub fn crea(gpaz: std.mem.Allocator, iden: []const u8, cmdz: []const u8, cwdz: []const u8, shel: spawn.ShelKind) !*Supe { const self = try gpaz.create(Supe); errdefer gpaz.destroy(self); const iden_dupe = try gpaz.dupe(u8, iden); errdefer gpaz.free(iden_dupe); const cmdz_dupe = try gpaz.dupe(u8, cmdz); errdefer gpaz.free(cmdz_dupe); const cwdz_dupe = try gpaz.dupe(u8, cwdz); self.* = .{ .gpaz = gpaz, .iden = iden_dupe, .cmdz = cmdz_dupe, .cwdz = cwdz_dupe, .shel = shel }; return self; }
pub fn dest(self: *Supe) void { const gpaz = self.gpaz; gpaz.free(self.iden); gpaz.free(self.cmdz); gpaz.free(self.cwdz); gpaz.destroy(self); }
pub fn stopSign(self: *Supe, iozz: std.Io, regi: *registry.Regi) void { self.stop.store(true, .release); _ = regi.idenKill(iozz, self.iden); }
pub fn exitWait(self: *Supe, iozz: std.Io, time_msec: u32) bool { var wait_msec: u32 = 0; while (wait_msec < time_msec) { if (self.exit.load(.acquire)) return true; std.Io.sleep(iozz, .fromMilliseconds(CF.wait_step_msec), .awake) catch return false; wait_msec += CF.wait_step_msec; } return self.exit.load(.acquire); }
};
pub fn backNext(curr: u32) u32 { const doub = std.math.mul(u32, curr, 2) catch CF.back_maxz_msec; return @min(doub, CF.back_maxz_msec); }
pub fn runzHeal(runz_msec: i64) bool { return runz_msec >= CF.heal_runz_msec; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
