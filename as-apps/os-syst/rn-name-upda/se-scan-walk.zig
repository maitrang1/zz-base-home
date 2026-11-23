// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Walk the roots and collect every plan item from text files
// Flo: stack of dirs > skip listed dirs > per dir build relative forms > per file stat, read, scan > items
// I/O: roots + Conf + Targ > Item list + Wstat counts (never follows links, never writes)
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const stex = @import("se-scan-text.zig");
const plan = @import("pl-plan-buil.zig");
const cfgz = @import("cf-conf-load.zig");
const CF = .{ .binz = 8192, .mbyt = 1024 * 1024 };
pub const Wstat = struct { dirs: usize = 0, filz: usize = 0, scan: usize = 0, bina: usize = 0, bigz: usize = 0, errz: usize = 0 };
pub const Targ = struct { osy: osys.Osys, old: []const u8, new: []const u8, olds: []const vari.Vari, news: []const vari.Vari };
const Node = struct { path: []const u8, deep: u32 };
pub fn skipDir(osy: osys.Osys, name: []const u8, path: []const u8, skps: []const []const u8) bool {
for (skps) |skip| {
if (std.mem.indexOfScalar(u8, skip, '/') == null) { if (osys.eqlz(osy, name, skip)) return true; continue; }
if (osys.eqlz(osy, path, skip)) return true;
if (path.len > skip.len and path[path.len - skip.len - 1] == '/' and osys.hasSuf(osy, path, skip)) return true;
}
return false;
}
fn fileScan(perm: std.mem.Allocator, scra: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, osy: osys.Osys, full: []const u8, olds: []const vari.Vari, news: []const vari.Vari, out: *std.ArrayList(plan.Item), wst: *Wstat) !void {
wst.filz += 1;
for (conf.skip_path_list) |skip| { if (osys.eqlz(osy, full, skip)) return; }
const nati = try osys.natiForm(scra, osy, full);
const info = std.Io.Dir.cwd().statFile(iozz, nati, .{}) catch { wst.errz += 1; return; };
if (info.size > conf.scan_maxz * CF.mbyt) { wst.bigz += 1; return; }
const text = std.Io.Dir.cwd().readFileAlloc(iozz, nati, scra, .limited(conf.scan_maxz * CF.mbyt)) catch { wst.errz += 1; return; };
if (std.mem.indexOfScalar(u8, text[0..@min(text.len, CF.binz)], 0) != null) { wst.bina += 1; return; }
wst.scan += 1;
const hits = try stex.scanText(scra, osy, text, olds, news);
if (hits.len == 0) return;
const pdup = try perm.dupe(u8, full);
for (hits) |hit| {
const clas = plan.clasOf(hit.kind);
try out.append(perm, .{ .path = pdup, .line = hit.line, .offz = hit.offz, .lenz = hit.lenz, .kind = hit.kind, .clas = clas, .skip = plan.skipOf(conf, clas), .newz = try perm.dupe(u8, hit.newz) });
}
}
pub fn walkRoot(perm: std.mem.Allocator, back: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, targ: Targ, root: []const u8, skps: []const []const u8, out: *std.ArrayList(plan.Item), wst: *Wstat) !void {
var stak: std.ArrayList(Node) = .empty;
defer { for (stak.items) |node| back.free(node.path); stak.deinit(back); }
try stak.append(back, .{ .path = try back.dupe(u8, root), .deep = 0 });
while (stak.pop()) |node| {
defer back.free(node.path);
var scra = std.heap.ArenaAllocator.init(back);
defer scra.deinit();
const sara = scra.allocator();
wst.dirs += 1;
var dirz = std.Io.Dir.cwd().openDir(iozz, try osys.natiForm(sara, targ.osy, node.path), .{ .iterate = true }) catch { wst.errz += 1; continue; };
defer dirz.close(iozz);
const inzd = osys.insid(targ.osy, node.path, targ.old);
const rela = if (inzd) &[_]vari.Vari{} else try vari.relaVari(sara, targ.osy, node.path, targ.old);
const relb = if (inzd) &[_]vari.Vari{} else try vari.relaVari(sara, targ.osy, node.path, targ.new);
if (rela.len != relb.len) return stex.Erro.ShapeMismatch;
const olds = try std.mem.concat(sara, vari.Vari, &.{ targ.olds, rela });
const news = try std.mem.concat(sara, vari.Vari, &.{ targ.news, relb });
const slsh: []const u8 = if (node.path[node.path.len - 1] == '/') "" else "/";
var iter = dirz.iterate();
while (iter.next(iozz) catch { wst.errz += 1; break; }) |entr| {
const full = try std.fmt.allocPrint(sara, "{s}{s}{s}", .{ node.path, slsh, entr.name });
switch (entr.kind) {
.directory => { if (node.deep + 1 > conf.scan_deep or skipDir(targ.osy, entr.name, full, skps)) continue; try stak.append(back, .{ .path = try back.dupe(u8, full), .deep = node.deep + 1 }); },
.file => { var fara = std.heap.ArenaAllocator.init(back); defer fara.deinit(); try fileScan(perm, fara.allocator(), iozz, conf, targ.osy, full, olds, news, out, wst); },
else => {},
}
}
}
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
