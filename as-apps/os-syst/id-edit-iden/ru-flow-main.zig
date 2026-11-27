// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Apply a plan: snapshot, edit, move, verify, hub check; roll back on any failure
// Flo: lock > journal open > per file: check drift, snapshot, journal, atomic write > per move: journal, rename > verify jobs + dispatchers + leftovers > hub check > done | fail = undo everything
// I/O: Ctxz + Plan + force > Resu {id, code, counts, notes}; files changed on disk
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const snap = @import("bk-snap-take.zig");
const ldz = @import("ut-file-load.zig");
const tk = @import("ut-iden-toke.zig");
const jz = @import("tk-jobz-read.zig");
const wk = @import("se-scan-walk.zig");
const pl = @import("pl-plan-buil.zig");
const hz = @import("sy-hubz-chec.zig");
const undo = @import("ru-flow-undo.zig");
pub const Erro = error{ Drift, Dangling, JobsBroken, OpenRun };
pub const Resu = struct { id: []const u8 = "", code: exit.Code = .okay, edit: usize = 0, mved: usize = 0, left: usize = 0, hubz: []const u8 = "", note: []const u8 = "" };
fn verif(ctxz: *const cx.Ctxz, plan: pl.Plan, resu: *Resu, hubb: hz.Snap) !void {
const conf = pl.confOf(ctxz, plan.opts);
if (plan.opts.scope != .state) {
const jobs = jz.loadAll(ctxz.allo, ctxz.iozz, ctxz.repo, conf) catch return Erro.JobsBroken;
for (plan.pairs) |pair| if (jz.hasIden(jobs, pair.old) or !jz.hasIden(jobs, pair.new)) return Erro.JobsBroken;
const unre = try jz.unresolved(ctxz.allo, ctxz.iozz, ctxz.repo, conf, try jz.calls(ctxz.allo, jobs));
if (unre.len != plan.unre.len) return Erro.Dangling;
var outc: wk.Outc = .{};
try wk.walk(ctxz.allo, ctxz.gpaz, ctxz.iozz, conf, ctxz.repo, plan.pairs, &outc);
for (outc.files.items) |item| resu.left += item.hits;
if (resu.left > 0) resu.code = exit.foldz(resu.code, .find);
}
const chec = hz.check(ctxz, plan.hubz.port, hubb, plan.pairs);
resu.hubz = chec.note;
if (chec.state == .bad) resu.code = exit.foldz(resu.code, .find);
}
fn body(ctxz: *const cx.Ctxz, plan: pl.Plan, pth: stor.Pths, resu: *Resu, hubb: hz.Snap) !void {
const allo = ctxz.allo;
const iozz = ctxz.iozz;
try jour.appd(allo, iozz, pth.jour, pth.jfil, .{ .op = "open", .note = try std.fmt.allocPrint(allo, "{d} pairs", .{plan.pairs.len}) });
for (plan.files, 0..) |item, indx| {
try ctxz.step();
const raww = try std.Io.Dir.cwd().readFileAlloc(iozz, item.path, allo, .limited(64 << 20));
const h0 = snap.hashHex(raww);
if (!std.mem.eql(u8, &h0, &item.hash)) return Erro.Drift;
const load = try ldz.loadz(allo, raww);
const hits = try tk.scan(allo, load.text, plan.pairs);
if (hits.len != item.hits) return Erro.Drift;
const newt = try tk.apply(allo, load.text, hits, plan.pairs);
const newb = try ldz.encode(allo, load.enc, newt);
const bakn = try std.fmt.allocPrint(allo, "{d}.bak", .{indx});
try snap.putz(allo, iozz, pth.snap, bakn, raww);
const h1 = snap.hashHex(newb);
try jour.appd(allo, iozz, pth.jour, pth.jfil, .{ .op = "edit", .a = item.path, .b = bakn, .h0 = &h0, .h1 = &h1 });
try snap.atom(allo, iozz, item.path, newb);
resu.edit += 1;
}
for (plan.moves) |mv| {
try ctxz.step();
try jour.appd(allo, iozz, pth.jour, pth.jfil, .{ .op = "move", .a = mv.from, .b = mv.to });
try std.Io.Dir.renamePreserve(std.Io.Dir.cwd(), mv.from, std.Io.Dir.cwd(), mv.to, iozz);
resu.mved += 1;
}
try verif(ctxz, plan, resu, hubb);
try jour.appd(allo, iozz, pth.jour, pth.jfil, .{ .op = "done" });
}
pub fn openRun(ctxz: *const cx.Ctxz) ?[]const u8 {
const last = (stor.idLast(ctxz) catch return null) orelse return null;
const pth = stor.pthsOf(ctxz, last) catch return null;
const ents = jour.readAll(ctxz.allo, ctxz.iozz, pth.jfil) catch return null;
return if (jour.stateOf(ents) == .open) last else null;
}
pub fn applyPlan(ctxz: *const cx.Ctxz, plan: pl.Plan) !Resu {
if (openRun(ctxz) != null) return Erro.OpenRun;
const id = try stor.idNew(ctxz);
try stor.lockTake(ctxz, id);
defer stor.lockFree(ctxz, id);
const pth = try stor.pthsOf(ctxz, id);
var resu: Resu = .{ .id = id };
const hubb = if (ctxz.conf.hubz_chec_on) hz.snap(ctxz, plan.hubz.port) else hz.Snap{};
body(ctxz, plan, pth, &resu, hubb) catch |err| {
const urs = undo.undoRun(ctxz, id, true, false) catch {
resu.note = std.fmt.allocPrint(ctxz.allo, "{s}; rollback failed: run ie undo {s} --live --force", .{ @errorName(err), id }) catch @errorName(err);
resu.code = .fail;
return resu;
};
resu.note = std.fmt.allocPrint(ctxz.allo, "{s}; rolled back ({d} files, {d} moves)", .{ @errorName(err), urs.back, urs.mved }) catch @errorName(err);
resu.code = .fail;
return resu;
};
return resu;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
