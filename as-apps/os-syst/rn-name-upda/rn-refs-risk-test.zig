// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for risky files: UTF-16, binary, signed, git, links
// Flo: UTF-16 BOM patched and kept > binary same-length only when its key is off > signed/git skipped by default > symlink retarget plan
// I/O: tmp dir fake machine > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const patc = @import("rn-refs-patc.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const scan = @import("ru-flow-scan.zig");
const stor = @import("st-runz-stor.zig");
const tick = @import("ut-faul-tick.zig");
const cfgz = @import("cf-conf-load.zig");
const ldz = @import("ut-file-load.zig");
const osys = @import("ut-osys-adap.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
fn run(allo: std.mem.Allocator, tmp: *std.testing.TmpDir, conf: cfgz.Conf, rel: []const u8, old: []const u8, new: []const u8) !usize {
const root = try fake.rootOf(allo, tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
const targ = try scan.targOf(&ctxz, try std.fmt.allocPrint(allo, "{s}/{s}", .{ root, old }), try std.fmt.allocPrint(allo, "{s}/{s}", .{ root, new }));
const pth = try stor.pthsOf(&ctxz, "rid");
var tck: tick.Tick = .{};
return patc.patchFile(&ctxz, targ, try std.fmt.allocPrint(allo, "{s}/{s}", .{ root, rel }), pth, 1, &tck);
}
test "a UTF-16 LE file with BOM is patched and stays UTF-16 LE with its BOM" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const text = try std.fmt.allocPrint(allo, "[Run]\r\npath={s}/p/old/x.exe\r\n", .{root});
try fake.putz(&tmp, "a.reg", try ldz.encode(allo, .u16le, text));
try std.testing.expectEqual(@as(usize, 1), try run(allo, &tmp, .{}, "a.reg", "p/old", "p/newer"));
const raww = try fake.readz(allo, &tmp, "a.reg");
try std.testing.expect(raww[0] == 0xFF and raww[1] == 0xFE);
const load = try ldz.loadz(allo, raww);
try std.testing.expectEqual(ldz.Enc.u16le, load.enc);
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "[Run]\r\npath={s}/p/newer/x.exe\r\n", .{root}), load.text);
}
test "UTF-16 BE too" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "a.txt", try ldz.encode(allo, .u16be, try std.fmt.allocPrint(allo, "{s}/p/old", .{root})));
try std.testing.expectEqual(@as(usize, 1), try run(allo, &tmp, .{}, "a.txt", "p/old", "p/newer"));
const load = try ldz.loadz(allo, try fake.readz(allo, &tmp, "a.txt"));
try std.testing.expectEqual(ldz.Enc.u16be, load.enc);
}
test "binary: same-length ref patched only when skip_bina is off; different length never" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const body = try std.fmt.allocPrint(allo, "MZ\x00\x01{s}/p/old\x00tail", .{root});
try fake.putz(&tmp, "b.dat2", body);
try std.testing.expectEqual(@as(usize, 0), try run(allo, &tmp, .{}, "b.dat2", "p/old", "p/new"));
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "b.dat2"));
var conf: cfgz.Conf = .{};
conf.skip_bina = false;
try std.testing.expectEqual(@as(usize, 1), try run(allo, &tmp, conf, "b.dat2", "p/old", "p/new"));
const got = try fake.readz(allo, &tmp, "b.dat2");
try std.testing.expectEqual(body.len, got.len);
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "MZ\x00\x01{s}/p/new\x00tail", .{root}), got);
try fake.putz(&tmp, "c.dat2", body);
try std.testing.expectEqual(@as(usize, 0), try run(allo, &tmp, conf, "c.dat2", "p/old", "p/newer"));
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "c.dat2"));
}
test "binary UTF-16 path (like a .lnk) is found and patched when allowed and same length" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const wide = try std.unicode.utf8ToUtf16LeAlloc(allo, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}));
const body = try std.mem.concat(allo, u8, &.{ "L\x00\x00\x00", std.mem.sliceAsBytes(wide), "\x00\x00end" });
try fake.putz(&tmp, "s.lnk", body);
var conf: cfgz.Conf = .{};
conf.skip_bina = false;
try std.testing.expectEqual(@as(usize, 1), try run(allo, &tmp, conf, "s.lnk", "p/old", "p/new"));
const wnew = try std.unicode.utf8ToUtf16LeAlloc(allo, try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqualSlices(u8, try std.mem.concat(allo, u8, &.{ "L\x00\x00\x00", std.mem.sliceAsBytes(wnew), "\x00\x00end" }), try fake.readz(allo, &tmp, "s.lnk"));
}
test "signed or lock files are not patched by default, patched when the key is off" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const body = try std.fmt.allocPrint(allo, "dep {s}/p/old\n", .{root});
try fake.putz(&tmp, "mise.lock", body);
try std.testing.expectEqual(@as(usize, 0), try run(allo, &tmp, .{}, "mise.lock", "p/old", "p/new"));
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "mise.lock"));
var conf: cfgz.Conf = .{};
conf.skip_sign_hash = false;
try std.testing.expectEqual(@as(usize, 1), try run(allo, &tmp, conf, "mise.lock", "p/old", "p/new"));
}
test "files under .git are flagged and left alone by default" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const body = try std.fmt.allocPrint(allo, "[remote]\nurl = {s}/p/old\n", .{root});
try fake.putz(&tmp, "r/.git/config", body);
try std.testing.expectEqual(@as(usize, 0), try run(allo, &tmp, .{}, "r/.git/config", "p/old", "p/new"));
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "r/.git/config"));
}
test "walk lists the risky hits with their class and skip flag" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const body = try std.fmt.allocPrint(allo, "x {s}/p/old\n", .{root});
try fake.putz(&tmp, "r/.git/config", body);
try fake.putz(&tmp, "pkg/package-lock.json", body);
try fake.putz(&tmp, "ok.txt", body);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const scn = try scan.collect(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqual(@as(usize, 3), scn.items.len);
var gitz: usize = 0;
var sign: usize = 0;
var okay: usize = 0;
for (scn.items) |item| {
if (item.clas == .gitz and item.skip) gitz += 1;
if (item.clas == .sign and item.skip) sign += 1;
if (item.clas == .safe and !item.skip) okay += 1;
}
try std.testing.expectEqual(@as(usize, 1), gitz);
try std.testing.expectEqual(@as(usize, 1), sign);
try std.testing.expectEqual(@as(usize, 1), okay);
}
test "the walker finds binary and UTF-16 hits and flags the binary one by default" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "b.dat2", try std.fmt.allocPrint(allo, "MZ\x00{s}/p/old\x00", .{root}));
try fake.putz(&tmp, "u.txt", try ldz.encode(allo, .u16le, try std.fmt.allocPrint(allo, "x {s}/p/old y", .{root})));
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const scn = try scan.collect(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqual(@as(usize, 2), scn.items.len);
var binz: usize = 0;
var utf16: usize = 0;
for (scn.items) |item| {
if (std.mem.endsWith(u8, item.path, "b.dat2")) { binz += 1; try std.testing.expect(item.skip); try std.testing.expectEqual(plan.Clas.bina, item.clas); }
if (std.mem.endsWith(u8, item.path, "u.txt")) { utf16 += 1; try std.testing.expect(!item.skip); }
}
try std.testing.expectEqual(@as(usize, 1), binz);
try std.testing.expectEqual(@as(usize, 1), utf16);
try std.testing.expectEqual(@as(usize, 1), scn.wst.bina);
try std.testing.expectEqual(@as(usize, 1), scn.wst.scan);
}
test "a binary over scan_binz_maxz is counted and never scanned; maxz 0 means never" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "b.dat2", try std.fmt.allocPrint(allo, "MZ\x00{s}/p/old\x00", .{root}));
var conf: cfgz.Conf = .{};
conf.scan_binz_maxz = 0;
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
const scn = try scan.collect(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqual(@as(usize, 0), scn.items.len);
try std.testing.expectEqual(@as(usize, 1), scn.wst.bina);
}
test "a symlink into the old path becomes a link ref with the new target" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
const natv = try osys.natiForm(allo, osys.host, try std.fmt.allocPrint(allo, "{s}/p/old/x.txt", .{root}));
tmp.dir.symLink(std.testing.io, natv, "ln", .{}) catch return error.SkipZigTest;
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const scn = try scan.collect(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/new", .{root}));
try std.testing.expectEqual(@as(usize, 1), scn.lrefs.len);
try std.testing.expectEqual(plan.Lkind.link, scn.lrefs[0].kind);
try std.testing.expect(std.mem.indexOf(u8, scn.lrefs[0].newv, "p") != null and std.mem.indexOf(u8, scn.lrefs[0].newv, "new") != null);
try std.testing.expect(std.mem.indexOf(u8, scn.lrefs[0].newv, "old") == null);
try std.testing.expect(!scn.lrefs[0].skip);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
