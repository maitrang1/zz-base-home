// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests scan roots, skip list, forms and pair errors
// Flo: roots (explicit, volume, all drives) > skips hold the data dir > forms for text and binary > messages
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const scan = @import("ru-flow-scan.zig");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const cfgz = @import("cf-conf-load.zig");
test "fixed drives: letters on Windows, nothing elsewhere" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const drvs = try osys.drivesFixed(arna.allocator());
if (!osys.host.wind) { try std.testing.expectEqual(@as(usize, 0), drvs.len); return; }
try std.testing.expect(drvs.len >= 1);
for (drvs) |drv| {
try std.testing.expectEqual(@as(usize, 3), drv.len);
try std.testing.expect(drv[0] >= 'A' and drv[0] <= 'Z' and drv[1] == ':' and drv[2] == '/');
}
}
test "explicit roots win over every default" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const roots = try scan.rootsOf(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}));
try std.testing.expectEqual(@as(usize, 1), roots.len);
try std.testing.expectEqualStrings(root, roots[0]);
}
test "empty roots with all-drives off: only the old path's volume" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var conf: cfgz.Conf = .{};
conf.scan_alls_driv = false;
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, root, conf, false);
ctxz.conf.scan_root_list = &.{};
const old = try std.fmt.allocPrint(allo, "{s}/p/old", .{root});
const roots = try scan.rootsOf(&ctxz, old);
try std.testing.expectEqual(@as(usize, 1), roots.len);
try std.testing.expectEqualStrings(osys.rootOf(old), roots[0]);
}
test "empty roots with all-drives on: every fixed drive on Windows, / elsewhere" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, root, .{}, false);
ctxz.conf.scan_root_list = &.{};
const roots = try scan.rootsOf(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}));
if (osys.host.wind) {
const drvs = try osys.drivesFixed(allo);
try std.testing.expectEqual(drvs.len, roots.len);
for (drvs, roots) |left, righ| try std.testing.expectEqualStrings(left, righ);
} else {
try std.testing.expectEqual(@as(usize, 1), roots.len);
try std.testing.expectEqualStrings("/", roots[0]);
}
}
test "the skip list holds the config list plus the data dir" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const skps = try scan.skipsOf(&ctxz);
try std.testing.expectEqual(ctxz.conf.scan_skip_list.len + 1, skps.len);
try std.testing.expectEqualStrings(try ctxz.dirzData(), skps[skps.len - 1]);
try std.testing.expectEqualStrings("/proc", skps[0]);
}
test "forms: text forms are the abs forms; binary forms add UTF-16 and keep the order" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const targ = try scan.targOf(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqual(targ.olds.len, targ.news.len);
try std.testing.expectEqual(targ.bolds.len, targ.bnews.len);
try std.testing.expect(targ.bolds.len > targ.olds.len);
for (targ.olds, 0..) |item, indx| try std.testing.expectEqualStrings(item.text, targ.bolds[indx].text);
try std.testing.expectEqual(vari.Kind.u16l, targ.bolds[targ.bolds.len - 1].kind);
try std.testing.expectEqualStrings(root, targ.home);
}
test "config path lists written with backslashes are normalized on Windows, left alone elsewhere" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const win: osys.Osys = .{ .wind = true, .caze = true };
const nix: osys.Osys = .{ .wind = false, .caze = false };
const lst = [_][]const u8{ "C:\\Users\\me\\a.txt", "node_modules", "/x/y" };
const wout = try scan.normList(allo, win, &lst);
try std.testing.expectEqualStrings("C:/Users/me/a.txt", wout[0]);
try std.testing.expectEqualStrings("node_modules", wout[1]);
try std.testing.expectEqualStrings("/x/y", wout[2]);
const nout = try scan.normList(allo, nix, &lst);
try std.testing.expectEqualStrings("C:\\Users\\me\\a.txt", nout[0]);
try std.testing.expectEqual(@as(usize, 0), (try scan.normList(allo, win, &.{})).len);
}
test "a skip_path_list file written with backslashes is really skipped during the scan" {
if (!osys.host.wind) return error.SkipZigTest;
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const body = try std.fmt.allocPrint(allo, "{s}/p/old\n", .{root});
try fake.putz(&tmp, "a.txt", body);
try fake.putz(&tmp, "b.txt", body);
var conf: cfgz.Conf = .{};
const skipf = try osys.natiForm(allo, osys.host, try std.fmt.allocPrint(allo, "{s}/a.txt", .{root}));
conf.skip_path_list = &.{skipf};
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
const scn = try scan.collect(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqual(@as(usize, 1), scn.items.len);
try std.testing.expect(std.mem.endsWith(u8, scn.items[0].path, "b.txt"));
}
test "pair messages are the documented sentences" {
try std.testing.expectEqualStrings("", scan.badText(.none));
try std.testing.expectEqualStrings("rn: old path not found. Check the spelling and run again.\n", scan.badText(.oldz_miss));
try std.testing.expectEqualStrings("rn: new path already exists. Pick a free name.\n", scan.badText(.newz_exis));
try std.testing.expectEqualStrings("rn: rename keeps the same parent folder. A move is not built yet.\n", scan.badText(.sibl_only));
try std.testing.expectEqualStrings("rn: old and new names are the same. Nothing to do.\n", scan.badText(.same_name));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
