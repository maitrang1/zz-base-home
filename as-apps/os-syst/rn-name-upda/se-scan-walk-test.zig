// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests the walker on a fake machine
// Flo: build fake tree > walk > check hits, skips, counters, limits
// I/O: tmp dir > pass or fail (never the live machine)
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const cfgz = @import("cf-conf-load.zig");
const fake = @import("te-mach-fake.zig");
const Rigz = struct { root: []u8, old: []u8, new: []u8, targ: walk.Targ };
fn rig(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir) !Rigz {
const root = try fake.rootOf(allo, tmp);
const old = try std.fmt.allocPrint(allo, "{s}/proj/old", .{root});
const new = try std.fmt.allocPrint(allo, "{s}/proj/new", .{root});
return .{ .root = root, .old = old, .new = new, .targ = .{ .osy = osys.host, .old = old, .new = new, .olds = try vari.absVari(allo, osys.host, old), .news = try vari.absVari(allo, osys.host, new) } };
}
fn go(allo: std.mem.Allocator, conf: cfgz.Conf, rg: Rigz, skps: []const []const u8, wst: *walk.Wstat) ![]plan.Item {
var outc: walk.Outc = .{};
try walk.walkRoot(allo, std.testing.allocator, std.testing.io, conf, rg.targ, rg.root, skps, &outc);
wst.* = outc.wst;
return outc.items.toOwnedSlice(allo);
}
fn countz(items: []const plan.Item, suff: []const u8, kind: vari.Kind) usize {
var cntz: usize = 0;
for (items) |item| { if (item.kind == kind and std.mem.endsWith(u8, item.path, suff)) cntz += 1; }
return cntz;
}
fn seed(allo: std.mem.Allocator, tmp: *std.testing.TmpDir, rg: Rigz) !void {
try fake.putz(tmp, "proj/old/x.txt", try std.fmt.allocPrint(allo, "self {s}/x.txt\n", .{rg.old}));
try fake.putz(tmp, "proj/doc/a.md", try std.fmt.allocPrint(allo, "see ../old/x.txt and {s} and {s}2\n", .{ rg.old, rg.old }));
try fake.putz(tmp, "proj/b.txt", "bare old and ./old/x.txt\n");
}
test "finds abs and relative refs; bare name is flagged; nothing else" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const rg = try rig(allo, &tmp);
try seed(allo, &tmp, rg);
var wst: walk.Wstat = .{};
const items = try go(allo, .{}, rg, &.{}, &wst);
try std.testing.expectEqual(@as(usize, 1), countz(items, "old/x.txt", .fwds));
try std.testing.expectEqual(@as(usize, 1), countz(items, "doc/a.md", .fwds));
try std.testing.expectEqual(@as(usize, 1), countz(items, "doc/a.md", .rela));
try std.testing.expectEqual(@as(usize, 1), countz(items, "proj/b.txt", .rela));
try std.testing.expectEqual(@as(usize, 1), countz(items, "proj/b.txt", .bare));
try std.testing.expectEqual(@as(usize, 5), items.len);
for (items) |item| { if (item.kind == .bare) try std.testing.expect(item.skip) else try std.testing.expect(!item.skip); }
try std.testing.expectEqual(@as(usize, 3), wst.scan);
try std.testing.expectEqual(@as(usize, 0), wst.errz);
}
test "binary files are counted and not scanned" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const rg = try rig(allo, &tmp);
try fake.putz(&tmp, "proj/bin.dat", try std.fmt.allocPrint(allo, "ab\x00{s}\n", .{rg.old}));
var wst: walk.Wstat = .{};
const items = try go(allo, .{}, rg, &.{}, &wst);
try std.testing.expectEqual(@as(usize, 0), items.len);
try std.testing.expectEqual(@as(usize, 1), wst.bina);
try std.testing.expectEqual(@as(usize, 0), wst.scan);
}
test "files over the size cap are counted and not read" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const rg = try rig(allo, &tmp);
try seed(allo, &tmp, rg);
var conf: cfgz.Conf = .{};
conf.scan_maxz = 0;
var wst: walk.Wstat = .{};
const items = try go(allo, conf, rg, &.{}, &wst);
try std.testing.expectEqual(@as(usize, 0), items.len);
try std.testing.expectEqual(@as(usize, 3), wst.bigz);
}
test "listed dirs are never entered: by name and by full path" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const rg = try rig(allo, &tmp);
const text = try std.fmt.allocPrint(allo, "{s}\n", .{rg.old});
try fake.putz(&tmp, "proj/node_modules/m.txt", text);
try fake.putz(&tmp, "data/zz/own/j.txt", text);
try fake.putz(&tmp, "proj/keep.txt", text);
const full = try std.fmt.allocPrint(allo, "{s}/data/zz/own", .{rg.root});
var wst: walk.Wstat = .{};
const items = try go(allo, .{}, rg, &.{ "node_modules", full }, &wst);
try std.testing.expectEqual(@as(usize, 1), items.len);
try std.testing.expect(std.mem.endsWith(u8, items[0].path, "proj/keep.txt"));
}
test "skip_path_list exempts one file" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const rg = try rig(allo, &tmp);
const text = try std.fmt.allocPrint(allo, "{s}\n", .{rg.old});
try fake.putz(&tmp, "a.txt", text);
try fake.putz(&tmp, "b.txt", text);
var conf: cfgz.Conf = .{};
const skipf = try std.fmt.allocPrint(allo, "{s}/a.txt", .{rg.root});
conf.skip_path_list = &.{skipf};
var wst: walk.Wstat = .{};
const items = try go(allo, conf, rg, &.{}, &wst);
try std.testing.expectEqual(@as(usize, 1), items.len);
try std.testing.expect(std.mem.endsWith(u8, items[0].path, "b.txt"));
}
test "depth cap stops the walk" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const rg = try rig(allo, &tmp);
const text = try std.fmt.allocPrint(allo, "{s}\n", .{rg.old});
try fake.putz(&tmp, "l1/l2/l3/deep.txt", text);
try fake.putz(&tmp, "l1/top.txt", text);
var conf: cfgz.Conf = .{};
conf.scan_deep = 1;
var wst: walk.Wstat = .{};
const items = try go(allo, conf, rg, &.{}, &wst);
try std.testing.expectEqual(@as(usize, 1), items.len);
try std.testing.expect(std.mem.endsWith(u8, items[0].path, "l1/top.txt"));
}
test "a missing root is an error count, not a crash" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var rg = try rig(allo, &tmp);
rg.root = try std.fmt.allocPrint(allo, "{s}/nope", .{rg.root});
var wst: walk.Wstat = .{};
const items = try go(allo, .{}, rg, &.{}, &wst);
try std.testing.expectEqual(@as(usize, 0), items.len);
try std.testing.expectEqual(@as(usize, 1), wst.errz);
}
test "skipDir rules: name, exact path, path suffix, case rule" {
const win: osys.Osys = .{ .wind = true, .caze = true };
const nix: osys.Osys = .{ .wind = false, .caze = false };
try std.testing.expect(walk.skipDir(nix, "node_modules", "/a/node_modules", &.{"node_modules"}));
try std.testing.expect(!walk.skipDir(nix, "node_modules2", "/a/node_modules2", &.{"node_modules"}));
try std.testing.expect(walk.skipDir(nix, "proc", "/proc", &.{"/proc"}));
try std.testing.expect(!walk.skipDir(nix, "proc", "/x/proc", &.{"/proc"}));
try std.testing.expect(walk.skipDir(nix, "objects", "/r/.git/objects", &.{".git/objects"}));
try std.testing.expect(!walk.skipDir(nix, "objects", "/r/x.git/objects", &.{".git/objects"}));
try std.testing.expect(walk.skipDir(win, "Windows", "C:/Windows", &.{"c:/windows"}));
try std.testing.expect(!walk.skipDir(nix, "Windows", "C:/Windows", &.{"c:/windows"}));
try std.testing.expect(walk.skipDir(win, "NODE_MODULES", "C:/a/NODE_MODULES", &.{"node_modules"}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
