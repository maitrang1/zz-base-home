// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Undo a run from its journal: put old bytes back, move files back
// Flo: read journal > newest entry first: edit = restore the snapshot if the file is still our write, move = rename back without replacing > mark rolled
// I/O: Ctxz + run id + live/force flags > Urs counts; journal gets a rolled line
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const snap = @import("bk-snap-take.zig");
const pl = @import("pl-plan-buil.zig");
pub const Urs = struct { back: usize = 0, mved: usize = 0, skip: usize = 0, bloc: usize = 0, done: bool = false };
pub const Erro = error{UnknownRun};
fn hashOf(ctxz: *const cx.Ctxz, path: []const u8) ?[64]u8 {
const raww = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, path, ctxz.allo, .limited(64 << 20)) catch return null;
return snap.hashHex(raww);
}
pub fn undoRun(ctxz: *const cx.Ctxz, id: []const u8, live: bool, forc: bool) !Urs {
const pth = try stor.pthsOf(ctxz, id);
const ents = jour.readAll(ctxz.allo, ctxz.iozz, pth.jfil) catch return Erro.UnknownRun;
var urs: Urs = .{};
if (jour.stateOf(ents) == .rolled) { urs.done = true; return urs; }
var indx = ents.len;
while (indx > 0) {
indx -= 1;
const ent = ents[indx];
if (std.mem.eql(u8, ent.op, "move")) {
const hasa = pl.existz(ctxz, ent.a);
const hasb = pl.existz(ctxz, ent.b);
if (hasb and !hasa) { if (live) try std.Io.Dir.renamePreserve(std.Io.Dir.cwd(), ent.b, std.Io.Dir.cwd(), ent.a, ctxz.iozz); urs.mved += 1; }
else if (hasb and hasa) urs.bloc += 1
else urs.skip += 1;
continue;
}
if (!std.mem.eql(u8, ent.op, "edit")) continue;
const curr = hashOf(ctxz, ent.a) orelse { urs.bloc += 1; continue; };
if (std.mem.eql(u8, &curr, ent.h0)) { urs.skip += 1; continue; }
if (!std.mem.eql(u8, &curr, ent.h1) and !forc) { urs.bloc += 1; continue; }
if (live) {
const bakp = try std.fs.path.join(ctxz.allo, &.{ pth.snap, ent.b });
const raww = try std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, bakp, ctxz.allo, .limited(64 << 20));
try snap.atom(ctxz.allo, ctxz.iozz, ent.a, raww);
}
urs.back += 1;
}
if (live and (urs.bloc == 0 or forc)) { try jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "rolled" }); urs.done = true; }
return urs;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
