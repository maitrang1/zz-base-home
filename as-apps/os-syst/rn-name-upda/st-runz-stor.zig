// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Run ids and the data-dir layout (one owner of run state paths)
// Flo: data dir > jour/snap paths per id > new unique id > latest id
// I/O: Ctxz + id > native paths; dir listing > id text
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
pub const Pths = struct { data: []const u8, jour: []const u8, snap: []const u8, jfil: []const u8 };
const CF = .{ .tryz = 99, .exte = ".jsonl" };
pub fn pthsOf(ctxz: *const cx.Ctxz, id: []const u8) !Pths {
const data = try ctxz.dirzData();
return .{
.data = try ctxz.nati(data),
.jour = try ctxz.nati(try std.fmt.allocPrint(ctxz.allo, "{s}/jour", .{data})),
.snap = try ctxz.nati(try std.fmt.allocPrint(ctxz.allo, "{s}/snap/{s}", .{ data, id })),
.jfil = try ctxz.nati(try std.fmt.allocPrint(ctxz.allo, "{s}/jour/{s}{s}", .{ data, id, CF.exte })),
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
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
