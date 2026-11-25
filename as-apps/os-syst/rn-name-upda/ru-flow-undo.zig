// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Undo one run from its journal, also failed-run rollback
// Flo: dry pass finds conflicts > stop if any > live pass walks the journal backwards: rename back, restore snapshots by hash > mark rolled
// I/O: run id + live/force flags > state restored byte-identical; counts
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const osys = @import("ut-osys-adap.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const take = @import("bk-snap-take.zig");
const rest = @import("bk-snap-rest.zig");
const rena = @import("rn-rena-appl.zig");
const patc = @import("rn-refs-patc.zig");
const loca = @import("sy-loca-list.zig");
const CF = .{ .mbyt = 1024 * 1024 };
pub const Erro = error{ NoJournal, AlreadyUndone };
pub const Opts = struct { live: bool = false, force: bool = false };
pub const Rslt = struct { code: exit.Code, restd: usize = 0, skip: usize = 0, conf: usize = 0 };
fn cancl(ents: []const jour.Jent) bool { for (ents) |ent| { if (std.mem.eql(u8, ent.op, "renx")) return true; } return false; }
fn lastRena(ents: []const jour.Jent) ?jour.Jent {
if (cancl(ents)) return null;
var indx: usize = ents.len;
while (indx > 0) { indx -= 1; if (std.mem.eql(u8, ents[indx].op, "rena")) return ents[indx]; }
return null;
}
fn mapPath(ctxz: *const cx.Ctxz, path: []const u8, pend: ?jour.Jent) ![]const u8 {
const ren = pend orelse return path;
if (!osys.insid(ctxz.osy, path, ren.a)) return path;
return std.fmt.allocPrint(ctxz.allo, "{s}{s}", .{ ren.b, path[ren.a.len..] });
}
const Verd = enum { done, same, conf };
fn verdOf(cur: []const u8, ent: jour.Jent, force: bool) Verd {
const hcur = take.hashHex(cur);
if (std.mem.eql(u8, &hcur, ent.h0)) return .done;
if (!std.mem.eql(u8, &hcur, ent.h1) and !force) return .conf;
return .same;
}
fn tally(verd: Verd, rsl: *Rslt) bool {
switch (verd) { .done => rsl.skip += 1, .conf => rsl.conf += 1, .same => return true }
return false;
}
fn undoPatch(ctxz: *const cx.Ctxz, pth: stor.Pths, ent: jour.Jent, where: []const u8, live: bool, force: bool, rsl: *Rslt) !void {
var scra = std.heap.ArenaAllocator.init(ctxz.gpaz);
defer scra.deinit();
const sara = scra.allocator();
const nat = try ctxz.nati(where);
const maxz = ctxz.conf.scan_maxz * CF.mbyt + 1;
const cur = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, nat, sara, .limited(maxz)) catch { rsl.conf += 1; return; };
if (!tally(verdOf(cur, ent, force), rsl)) return;
const orig = rest.getz(sara, ctxz.iozz, pth.snap, ent.b, ent.h0, maxz) catch { rsl.conf += 1; return; };
if (live) try patc.writeRetry(ctxz, nat, orig);
rsl.restd += 1;
}
fn undoLoca(ctxz: *const cx.Ctxz, pth: stor.Pths, ent: jour.Jent, id: []const u8, pend: ?jour.Jent, live: bool, force: bool, rsl: *Rslt) !void {
const kind = loca.kindOf(ent.a) orelse { rsl.conf += 1; return; };
const name = if (kind == .link) try mapPath(ctxz, ent.b, pend) else ent.b;
const cur = loca.current(ctxz, kind, name) catch { rsl.conf += 1; return; };
if (!tally(verdOf(cur, ent, force), rsl)) return;
const orig = rest.getz(ctxz.allo, ctxz.iozz, pth.snap, ent.note, ent.h0, ctxz.conf.scan_maxz * CF.mbyt) catch { rsl.conf += 1; return; };
if (live) try loca.setz(ctxz, kind, name, orig, id);
rsl.restd += 1;
}
fn pass(ctxz: *const cx.Ctxz, id: []const u8, pth: stor.Pths, ents: []const jour.Jent, live: bool, force: bool) !Rslt {
var rsl: Rslt = .{ .code = .okay };
const ren = lastRena(ents);
var pend: ?jour.Jent = null;
if (!live) { if (ren) |rent| { if (ctxz.exists(rent.b) and (!ctxz.exists(rent.a) or rena.caseOnly(ctxz.osy, rent.a, rent.b))) pend = rent; } }
var indx: usize = ents.len;
while (indx > 0) {
indx -= 1;
const ent = ents[indx];
if (std.mem.eql(u8, ent.op, "rena")) {
if (cancl(ents)) continue;
const hasb = ctxz.exists(ent.b);
const hasa = ctxz.exists(ent.a);
if (rena.caseOnly(ctxz.osy, ent.a, ent.b) or (hasb and !hasa)) { if (live) try rena.renaDo(ctxz, ent.b, ent.a, id); rsl.restd += 1; }
else if (hasa and !hasb) rsl.skip += 1
else rsl.conf += 1;
continue;
}
if (std.mem.eql(u8, ent.op, "loca")) { try undoLoca(ctxz, pth, ent, id, pend, live, force, &rsl); continue; }
if (std.mem.eql(u8, ent.op, "patch")) try undoPatch(ctxz, pth, ent, try mapPath(ctxz, ent.a, pend), live, force, &rsl);
}
if (rsl.conf > 0) rsl.code = .bloc;
return rsl;
}
pub fn undoRun(ctxz: *const cx.Ctxz, id: []const u8, opts: Opts) !Rslt {
const pth = try stor.pthsOf(ctxz, id);
const ents = jour.readAll(ctxz.allo, ctxz.iozz, pth.jfil) catch return Erro.NoJournal;
if (jour.stateOf(ents) == .rolled) return Erro.AlreadyUndone;
const dry = try pass(ctxz, id, pth, ents, false, opts.force);
if (dry.code != .okay or !opts.live) return dry;
const liv = try pass(ctxz, id, pth, ents, true, opts.force);
if (liv.code == .okay) try jour.appd(ctxz.allo, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "rolled" });
return liv;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
