// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Walk the repo, find files that hold an old id, find name clashes
// Flo: stack of dirs > skip listed dirs > per entry: name clash check > per file: ext kind, size cap, binary skip > scan tokens > Fhit with hash
// I/O: repo root + Conf + Pair list > Outc {files, clash, stat} (never follows links, never writes)
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const tk = @import("ut-iden-toke.zig");
const ldz = @import("ut-file-load.zig");
const snap = @import("bk-snap-take.zig");
pub const Kind = enum { live, docs };
pub const Fhit = struct { path: []const u8, kind: Kind, hits: usize, line: usize, hash: [64]u8 };
pub const Clash = struct { iden: []const u8, path: []const u8 };
pub const Wstat = struct { dirs: usize = 0, filz: usize = 0, scan: usize = 0, skip: usize = 0, bina: usize = 0, bigz: usize = 0, errz: usize = 0 };
pub const Outc = struct { files: std.ArrayList(Fhit) = .empty, clash: std.ArrayList(Clash) = .empty, wst: Wstat = .{} };
const Node = struct { path: []const u8, deep: u32 };
fn inList(name: []const u8, list: []const []const u8) bool { for (list) |item| if (std.mem.eql(u8, item, name)) return true; return false; }
fn hasPref(name: []const u8, list: []const []const u8) bool { for (list) |item| if (std.mem.startsWith(u8, name, item)) return true; return false; }
pub fn kindOf(conf: cfgz.Conf, name: []const u8) ?Kind {
const dot = std.mem.lastIndexOfScalar(u8, name, '.') orelse return null;
var buff: [16]u8 = undefined;
const ext = name[dot..];
if (ext.len > buff.len) return null;
const lowr = std.ascii.lowerString(&buff, ext);
if (inList(lowr, conf.scan_live_ext)) return .live;
if (conf.scan_docs_on and inList(lowr, conf.scan_docs_ext)) return .docs;
return null;
}
pub fn skipDir(conf: cfgz.Conf, name: []const u8) bool { return inList(name, conf.scan_skip_dirs) or hasPref(name, conf.scan_skip_pref); }
fn stemOf(name: []const u8) []const u8 { return name[0 .. std.mem.indexOfScalar(u8, name, '.') orelse name.len]; }
fn clashChec(perm: std.mem.Allocator, name: []const u8, full: []const u8, pairs: []const tk.Pair, outc: *Outc) !void {
const stem = stemOf(name);
for (pairs) |pair| if (std.mem.eql(u8, stem, pair.old)) try outc.clash.append(perm, .{ .iden = pair.old, .path = try perm.dupe(u8, full) });
}
fn fileScan(perm: std.mem.Allocator, scra: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, pairs: []const tk.Pair, full: []const u8, name: []const u8, outc: *Outc) !void {
outc.wst.filz += 1;
const kind = kindOf(conf, name) orelse { outc.wst.skip += 1; return; };
if (inList(name, conf.scan_skip_name)) { outc.wst.skip += 1; return; }
const raww = std.Io.Dir.cwd().readFileAlloc(iozz, full, scra, .limited(conf.scan_maxz_mbyt << 20)) catch |err| {
if (err == error.StreamTooLong) outc.wst.bigz += 1 else outc.wst.errz += 1;
return;
};
const load = ldz.loadz(scra, raww) catch { outc.wst.errz += 1; return; };
if (load.enc == .binz) { outc.wst.bina += 1; return; }
outc.wst.scan += 1;
const hits = try tk.scan(scra, load.text, pairs);
if (hits.len == 0) return;
try outc.files.append(perm, .{ .path = try perm.dupe(u8, full), .kind = kind, .hits = hits.len, .line = hits[0].line, .hash = snap.hashHex(raww) });
}
fn lessFhit(_: void, left: Fhit, righ: Fhit) bool { return std.mem.order(u8, left.path, righ.path) == .lt; }
pub fn walk(perm: std.mem.Allocator, back: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, root: []const u8, pairs: []const tk.Pair, outc: *Outc) !void {
var stak: std.ArrayList(Node) = .empty;
defer { for (stak.items) |node| back.free(node.path); stak.deinit(back); }
try stak.append(back, .{ .path = try back.dupe(u8, root), .deep = 0 });
while (stak.pop()) |node| {
defer back.free(node.path);
var scra = std.heap.ArenaAllocator.init(back);
defer scra.deinit();
const sara = scra.allocator();
outc.wst.dirs += 1;
var dirz = std.Io.Dir.cwd().openDir(iozz, node.path, .{ .iterate = true }) catch { outc.wst.errz += 1; continue; };
defer dirz.close(iozz);
var iter = dirz.iterate();
while (iter.next(iozz) catch { outc.wst.errz += 1; break; }) |entr| {
if (entr.kind == .directory and (skipDir(conf, entr.name) or node.deep + 1 > conf.scan_deep)) continue;
const full = try std.fs.path.join(sara, &.{ node.path, entr.name });
switch (entr.kind) {
.directory => { try clashChec(perm, entr.name, full, pairs, outc); try stak.append(back, .{ .path = try back.dupe(u8, full), .deep = node.deep + 1 }); },
.file => { try clashChec(perm, entr.name, full, pairs, outc); var fara = std.heap.ArenaAllocator.init(back); defer fara.deinit(); try fileScan(perm, fara.allocator(), iozz, conf, pairs, full, entr.name, outc); },
else => {},
}
}
}
std.mem.sort(Fhit, outc.files.items, {}, lessFhit);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
