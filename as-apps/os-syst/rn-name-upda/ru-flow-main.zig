// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: The whole auto flow: scan, snapshot, apply, verify, report, rollback
// Flo: scan > journal open > patch each file > rename > re-scan > done | any fail > undo everything
// I/O: normalized old/new + Ctxz + Opts > Rslt {code, id, counts}; disk changed or fully restored
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const osys = @import("ut-osys-adap.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const scan = @import("ru-flow-scan.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const patc = @import("rn-refs-patc.zig");
const rena = @import("rn-rena-appl.zig");
const undo = @import("ru-flow-undo.zig");
const tick = @import("ut-faul-tick.zig");
pub const Opts = struct { force: bool = false, tck: ?*tick.Tick = null };
pub const Rslt = struct { code: exit.Code, id: []const u8 = "", patched: usize = 0, files: usize = 0, left: usize = 0, flagd: usize = 0, note: []const u8 = "" };
const Erro = error{ LeftRefs, NewMissing, OldStays };
fn stepz(opts: Opts) !void { if (opts.tck) |tck| try tck.step(); }
fn applyAll(ctxz: *const cx.Ctxz, targ: walk.Targ, items: []const plan.Item, pth: stor.Pths, opts: Opts, rsl: *Rslt) !void {
var seqn: usize = 0;
var prev: []const u8 = "";
var tck: tick.Tick = .{};
const tref = opts.tck orelse &tck;
for (items) |item| {
if (item.skip or std.mem.eql(u8, item.path, prev)) continue;
prev = item.path;
seqn += 1;
const cntz = patc.patchFile(ctxz, targ, item.path, pth, seqn, tref) catch |err| {
if (err == patc.Erro.Blocked and opts.force) continue;
return err;
};
if (cntz > 0) { rsl.patched += cntz; rsl.files += 1; }
}
}
fn verify(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8, rsl: *Rslt) !void {
if (!ctxz.exists(new)) return Erro.NewMissing;
if (!rena.caseOnly(ctxz.osy, old, new) and ctxz.exists(old)) return Erro.OldStays;
var wst: walk.Wstat = .{};
const items = try scan.collect(ctxz, old, new, &wst);
const summ = plan.summOf(items);
rsl.left = summ.appl;
rsl.flagd = summ.skip;
}
fn failOf(err: anyerror) exit.Code { return if (err == patc.Erro.Blocked) .bloc else .fail; }
pub fn runFlow(ctxz: *const cx.Ctxz, old: []const u8, new: []const u8, opts: Opts) !Rslt {
var wst: walk.Wstat = .{};
const items = try scan.collect(ctxz, old, new, &wst);
const id = try stor.idNew(ctxz);
const pth = try stor.pthsOf(ctxz, id);
var rsl: Rslt = .{ .code = .okay, .id = id };
try jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "open", .a = old, .b = new });
const targ = try scan.targOf(ctxz, old, new);
var failz: ?anyerror = null;
applyAll(ctxz, targ, items, pth, opts, &rsl) catch |err| { failz = err; };
if (failz == null) {
stepz(opts) catch |err| { failz = err; };
}
if (failz == null) {
try jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "rena", .a = old, .b = new });
rena.renaDo(ctxz, old, new, id) catch |err| { failz = err; jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "renx", .note = @errorName(err) }) catch {}; };
}
if (failz == null) {
stepz(opts) catch |err| { failz = err; };
}
if (failz == null) { verify(ctxz, old, new, &rsl) catch |err| { failz = err; }; }
if (failz == null and rsl.left > 0 and !opts.force) failz = Erro.LeftRefs;
if (failz) |err| {
const back = undo.undoRun(ctxz, id, .{ .live = true, .force = true }) catch |uerr| {
rsl.code = .fail;
rsl.note = try std.fmt.allocPrint(ctxz.allo, "{s}; rollback failed: {s}; run rn undo {s} --live --force", .{ @errorName(err), @errorName(uerr), id });
return rsl;
};
_ = back;
try jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "fail", .note = @errorName(err) });
rsl.code = failOf(err);
rsl.note = @errorName(err);
return rsl;
}
try jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "done" });
rsl.code = if (rsl.left > 0 or rsl.flagd > 0) .find else .okay;
return rsl;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
