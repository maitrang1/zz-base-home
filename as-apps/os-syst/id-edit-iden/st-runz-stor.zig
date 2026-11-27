// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Run ids, data-dir layout and the one-run-at-a-time lock
// Flo: data dir > jour/snap paths per id > new unique id > latest id > take the lock (stale = moved aside) > release by moving it
// I/O: Ctxz + id > native paths; dir listing > id text; lock file
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
pub const Pths = struct { data: []const u8, jour: []const u8, snap: []const u8, jfil: []const u8, lock: []const u8, lold: []const u8 };
pub const Erro = error{Busy};
const CF = .{ .tryz = 99, .exte = ".jsonl" };
pub fn pthsOf(ctxz: *const cx.Ctxz, id: []const u8) !Pths {
const data = try ctxz.dirzData();
const allo = ctxz.allo;
return .{
.data = data,
.jour = try std.fs.path.join(allo, &.{ data, "jour" }),
.snap = try std.fs.path.join(allo, &.{ data, "snap", id }),
.jfil = try std.fs.path.join(allo, &.{ data, "jour", try std.fmt.allocPrint(allo, "{s}{s}", .{ id, CF.exte }) }),
.lock = try std.fs.path.join(allo, &.{ data, "run.lock" }),
.lold = try std.fs.path.join(allo, &.{ data, "lock-old" }),
};
}
pub fn idNew(ctxz: *const cx.Ctxz) ![]u8 {
const stam = try cx.stamTxt(ctxz.allo, ctxz.nowz());
var tryz: usize = 1;
while (tryz <= CF.tryz) : (tryz += 1) {
const cand = if (tryz == 1) try ctxz.allo.dupe(u8, stam) else try std.fmt.allocPrint(ctxz.allo, "{s}-{d}", .{ stam, tryz });
const pth = try pthsOf(ctxz, cand);
if (std.Io.Dir.cwd().statFile(ctxz.iozz, pth.jfil, .{})) |_| continue else |_| return cand;
}
return error.NoFreeId;
}
pub fn idLast(ctxz: *const cx.Ctxz) !?[]u8 {
const pth = try pthsOf(ctxz, "x");
var dirz = std.Io.Dir.cwd().openDir(ctxz.iozz, pth.jour, .{ .iterate = true }) catch return null;
defer dirz.close(ctxz.iozz);
var best: ?[]u8 = null;
var iter = dirz.iterate();
while (try iter.next(ctxz.iozz)) |entr| {
if (entr.kind != .file or !std.mem.endsWith(u8, entr.name, CF.exte)) continue;
const stem = entr.name[0 .. entr.name.len - CF.exte.len];
if (best == null or std.mem.order(u8, stem, best.?) == .gt) best = try ctxz.allo.dupe(u8, stem);
}
return best;
}
pub fn lockTake(ctxz: *const cx.Ctxz, id: []const u8) !void {
const pth = try pthsOf(ctxz, id);
const iozz = ctxz.iozz;
try std.Io.Dir.cwd().createDirPath(iozz, pth.data);
var tryz: usize = 0;
while (tryz < 2) : (tryz += 1) {
if (std.Io.Dir.cwd().createFile(iozz, pth.lock, .{ .exclusive = true })) |file| {
defer file.close(iozz);
file.writePositionalAll(iozz, id, 0) catch {};
return;
} else |err| if (err != error.PathAlreadyExists) return err;
const stat = std.Io.Dir.cwd().statFile(iozz, pth.lock, .{}) catch continue;
const agez = ctxz.nowz() - @divTrunc(stat.mtime.toMilliseconds(), 1000);
if (agez < ctxz.conf.lock_stal_seco) return Erro.Busy;
try std.Io.Dir.cwd().createDirPath(iozz, pth.lold);
const aside = try std.fs.path.join(ctxz.allo, &.{ pth.lold, try std.fmt.allocPrint(ctxz.allo, "{s}.lock", .{id}) });
try std.Io.Dir.renamePreserve(std.Io.Dir.cwd(), pth.lock, std.Io.Dir.cwd(), aside, iozz);
}
return Erro.Busy;
}
pub fn lockFree(ctxz: *const cx.Ctxz, id: []const u8) void {
const pth = pthsOf(ctxz, id) catch return;
std.Io.Dir.cwd().createDirPath(ctxz.iozz, pth.lold) catch return;
var tryz: usize = 0;
while (tryz < CF.tryz) : (tryz += 1) {
const aside = std.fs.path.join(ctxz.allo, &.{ pth.lold, std.fmt.allocPrint(ctxz.allo, "{s}-done{d}.lock", .{ id, tryz }) catch return }) catch return;
std.Io.Dir.renamePreserve(std.Io.Dir.cwd(), pth.lock, std.Io.Dir.cwd(), aside, ctxz.iozz) catch continue;
return;
}
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
