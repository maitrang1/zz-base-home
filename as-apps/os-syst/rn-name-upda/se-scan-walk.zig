// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Walk roots, collect plan items from files and links
// Flo: stack of dirs > skip listed dirs > per dir build relative forms > per file load, scan, classify > links read and scanned > items
// I/O: roots + Conf + Targ > Outc {items, lrefs, counts} (never follows links, never writes)
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const stex = @import("se-scan-text.zig");
const plan = @import("pl-plan-buil.zig");
const cfgz = @import("cf-conf-load.zig");
const risk = @import("ut-risk-clas.zig");
const ldz = @import("ut-file-load.zig");
const CF = .{ .mbyt = 1024 * 1024, .linz = 4096, .nprf = "\\??\\" };
pub const Wstat = struct { dirs: usize = 0, filz: usize = 0, scan: usize = 0, bina: usize = 0, bigz: usize = 0, errz: usize = 0, link: usize = 0 };
pub const Targ = struct { osy: osys.Osys, old: []const u8, new: []const u8, olds: []const vari.Vari, news: []const vari.Vari, bolds: []const vari.Vari = &.{}, bnews: []const vari.Vari = &.{}, home: []const u8 = "" };
pub const Outc = struct { items: std.ArrayList(plan.Item) = .empty, lrefs: std.ArrayList(plan.Lref) = .empty, wst: Wstat = .{} };
const Node = struct { path: []const u8, deep: u32 };
pub const Pair = struct { olds: []const vari.Vari, news: []const vari.Vari };
pub fn variDir(sara: std.mem.Allocator, targ: Targ, dirz: []const u8) !Pair {
const inzd = osys.insid(targ.osy, dirz, targ.old) or osys.insid(targ.osy, dirz, targ.new);
const rela = if (inzd) &[_]vari.Vari{} else try vari.relaVari(sara, targ.osy, dirz, targ.old);
const relb = if (inzd) &[_]vari.Vari{} else try vari.relaVari(sara, targ.osy, dirz, targ.new);
if (rela.len != relb.len) return stex.Erro.ShapeMismatch;
return .{ .olds = try std.mem.concat(sara, vari.Vari, &.{ targ.olds, rela }), .news = try std.mem.concat(sara, vari.Vari, &.{ targ.news, relb }) };
}
pub fn skipDir(osy: osys.Osys, name: []const u8, path: []const u8, skps: []const []const u8) bool {
for (skps) |skip| {
if (std.mem.indexOfScalar(u8, skip, '/') == null) { if (osys.eqlz(osy, name, skip)) return true; continue; }
if (osys.eqlz(osy, path, skip)) return true;
if (path.len > skip.len and path[path.len - skip.len - 1] == '/' and osys.hasSuf(osy, path, skip)) return true;
}
return false;
}
fn extSkip(osy: osys.Osys, name: []const u8, list: []const []const u8) bool { for (list) |ext| { if (osys.hasSuf(osy, name, ext)) return true; } return false; }
fn fileScan(perm: std.mem.Allocator, scra: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, targ: Targ, full: []const u8, olds: []const vari.Vari, news: []const vari.Vari, outc: *Outc) !void {
const osy = targ.osy;
outc.wst.filz += 1;
for (conf.skip_path_list) |skip| { if (osys.eqlz(osy, full, skip)) return; }
if (extSkip(osy, osys.baseOf(full), conf.scan_skip_ext)) { outc.wst.bina += 1; return; }
const nati = try osys.natiForm(scra, osy, full);
const raww = std.Io.Dir.cwd().readFileAlloc(iozz, nati, scra, .limited(conf.scan_maxz * CF.mbyt)) catch |err| {
if (std.mem.eql(u8, @errorName(err), "StreamTooLong")) outc.wst.bigz += 1 else outc.wst.errz += 1;
return;
};
const load = ldz.loadz(scra, raww) catch { outc.wst.errz += 1; return; };
const binz = load.enc == .binz;
if (binz) {
outc.wst.bina += 1;
if (raww.len > conf.scan_binz_maxz * CF.mbyt) return;
} else outc.wst.scan += 1;
const pmask = risk.pathMask(osy, conf, targ.home, full);
const hits = try stex.scanText(scra, osy, load.text, if (binz) targ.bolds else olds, if (binz) targ.bnews else news);
if (hits.len == 0) return;
const pdup = try perm.dupe(u8, full);
for (hits) |hit| {
const decd = plan.decide(conf, pmask, hit.kind, binz, hit.newz.len == hit.lenz);
try outc.items.append(perm, .{ .path = pdup, .line = hit.line, .offz = hit.offz, .lenz = hit.lenz, .kind = hit.kind, .clas = decd.clas, .mask = decd.mask, .skip = decd.skip, .newz = try perm.dupe(u8, hit.newz) });
}
}
fn linkScan(perm: std.mem.Allocator, sara: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, targ: Targ, dirz: std.Io.Dir, name: []const u8, full: []const u8, olds: []const vari.Vari, news: []const vari.Vari, outc: *Outc) !void {
var buff: [CF.linz]u8 = undefined;
const lenz = dirz.readLink(iozz, name, &buff) catch { outc.wst.errz += 1; return; };
outc.wst.link += 1;
const whol = buff[0..lenz];
const pref: []const u8 = if (std.mem.startsWith(u8, whol, CF.nprf)) whol[0..CF.nprf.len] else "";
const tgt = whol[pref.len..];
const hits = try stex.scanText(sara, targ.osy, tgt, olds, news);
if (hits.len == 0) return;
const pmask = risk.pathMask(targ.osy, conf, targ.home, full);
var mask: u16 = pmask;
var skip = false;
var outz: std.ArrayList(u8) = .empty;
var curz: usize = 0;
try outz.appendSlice(sara, pref);
for (hits) |hit| {
const decd = plan.decide(conf, pmask, hit.kind, false, true);
mask |= decd.mask;
if (decd.skip) skip = true;
try outz.appendSlice(sara, tgt[curz..hit.offz]);
try outz.appendSlice(sara, hit.newz);
curz = hit.offz + hit.lenz;
}
try outz.appendSlice(sara, tgt[curz..]);
try outc.lrefs.append(perm, .{ .kind = .link, .name = try perm.dupe(u8, full), .oldv = try perm.dupe(u8, whol), .newv = try perm.dupe(u8, outz.items), .clas = plan.firstOf(mask), .mask = mask, .skip = skip });
}
pub fn walkRoot(perm: std.mem.Allocator, back: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, targ: Targ, root: []const u8, skps: []const []const u8, outc: *Outc) !void {
var stak: std.ArrayList(Node) = .empty;
defer { for (stak.items) |node| back.free(node.path); stak.deinit(back); }
try stak.append(back, .{ .path = try back.dupe(u8, root), .deep = 0 });
while (stak.pop()) |node| {
defer back.free(node.path);
var scra = std.heap.ArenaAllocator.init(back);
defer scra.deinit();
const sara = scra.allocator();
outc.wst.dirs += 1;
var dirz = std.Io.Dir.cwd().openDir(iozz, try osys.natiForm(sara, targ.osy, node.path), .{ .iterate = true }) catch { outc.wst.errz += 1; continue; };
defer dirz.close(iozz);
const pair = try variDir(sara, targ, node.path);
const slsh: []const u8 = if (node.path[node.path.len - 1] == '/') "" else "/";
var iter = dirz.iterate();
while (iter.next(iozz) catch { outc.wst.errz += 1; break; }) |entr| {
const full = try std.fmt.allocPrint(sara, "{s}{s}{s}", .{ node.path, slsh, entr.name });
switch (entr.kind) {
.directory => { if (node.deep + 1 > conf.scan_deep or skipDir(targ.osy, entr.name, full, skps)) continue; try stak.append(back, .{ .path = try back.dupe(u8, full), .deep = node.deep + 1 }); },
.file => { var fara = std.heap.ArenaAllocator.init(back); defer fara.deinit(); try fileScan(perm, fara.allocator(), iozz, conf, targ, full, pair.olds, pair.news, outc); },
.sym_link => try linkScan(perm, sara, iozz, conf, targ, dirz, entr.name, full, pair.olds, pair.news, outc),
else => {},
}
}
}
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
