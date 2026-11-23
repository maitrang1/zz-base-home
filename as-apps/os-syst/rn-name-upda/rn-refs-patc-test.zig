// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for patching one file
// Flo: refs replaced, other bytes kept > snapshot + journal written first > skip classes > fault after journal > write retry
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const patc = @import("rn-refs-patc.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const take = @import("bk-snap-take.zig");
const rsc = @import("ru-flow-scan.zig");
const tick = @import("ut-faul-tick.zig");
const cfgz = @import("cf-conf-load.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const Setu = struct { ctxz: @import("ct-ctrl-ctxz.zig").Ctxz, targ: @import("se-scan-walk.zig").Targ, pth: stor.Pths, root: []u8 };
fn setu(allo: std.mem.Allocator, tmp: *std.testing.TmpDir, aw: *std.Io.Writer.Allocating, conf: cfgz.Conf) !Setu {
const root = try fake.rootOf(allo, tmp);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
const old = try std.fmt.allocPrint(allo, "{s}/p/old", .{root});
const new = try std.fmt.allocPrint(allo, "{s}/p/new", .{root});
return .{ .ctxz = ctxz, .targ = try rsc.targOf(&ctxz, old, new), .pth = try stor.pthsOf(&ctxz, "rid"), .root = root };
}
test "replaces refs, keeps every other byte (CRLF, unicode, NUL-free binary-like text)" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const st = try setu(allo, &tmp, &aw, .{});
const body = try std.fmt.allocPrint(allo, "a\r\n{s}/p/old/x\r\n\tTệp ✓ {s}/p/old;end", .{ st.root, st.root });
try fake.putz(&tmp, "f.txt", body);
var tck: tick.Tick = .{};
const cntz = try patc.patchFile(&st.ctxz, st.targ, try std.fmt.allocPrint(allo, "{s}/f.txt", .{st.root}), st.pth, 1, &tck);
try std.testing.expectEqual(@as(usize, 2), cntz);
const want = try std.fmt.allocPrint(allo, "a\r\n{s}/p/new/x\r\n\tTệp ✓ {s}/p/new;end", .{ st.root, st.root });
try std.testing.expectEqualStrings(want, try fake.readz(allo, &tmp, "f.txt"));
}
test "snapshot holds the original bytes and the journal holds both hashes" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const st = try setu(allo, &tmp, &aw, .{});
const body = try std.fmt.allocPrint(allo, "x {s}/p/old y", .{st.root});
try fake.putz(&tmp, "f.txt", body);
var tck: tick.Tick = .{};
_ = try patc.patchFile(&st.ctxz, st.targ, try std.fmt.allocPrint(allo, "{s}/f.txt", .{st.root}), st.pth, 7, &tck);
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "zz-tena/as-apps/os-syst/rn-name-upda/snap/rid/7.bak"));
const ents = try jour.readAll(allo, std.testing.io, st.pth.jfil);
try std.testing.expectEqual(@as(usize, 1), ents.len);
try std.testing.expectEqualStrings("patch", ents[0].op);
try std.testing.expectEqualStrings("7.bak", ents[0].b);
try std.testing.expectEqualStrings(&take.hashHex(body), ents[0].h0);
try std.testing.expectEqualStrings(&take.hashHex(try fake.readz(allo, &tmp, "f.txt")), ents[0].h1);
}
test "no refs: returns 0, file untouched, no snapshot, no journal" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const st = try setu(allo, &tmp, &aw, .{});
try fake.putz(&tmp, "f.txt", "nothing\n");
var tck: tick.Tick = .{};
try std.testing.expectEqual(@as(usize, 0), try patc.patchFile(&st.ctxz, st.targ, try std.fmt.allocPrint(allo, "{s}/f.txt", .{st.root}), st.pth, 1, &tck));
try std.testing.expectEqualStrings("nothing\n", try fake.readz(allo, &tmp, "f.txt"));
try std.testing.expect(!fake.hasz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/snap/rid/1.bak"));
try std.testing.expectEqual(@as(usize, 0), tck.seen);
}
test "a skipped class is left alone in the same file" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
var conf: cfgz.Conf = .{};
conf.skip_enco_vari = true;
const st = try setu(allo, &tmp, &aw, conf);
const url = try std.fmt.allocPrint(allo, "file:///{s}/p/old", .{if (st.ctxz.osy.wind) st.root else st.root[1..]});
const body = try std.fmt.allocPrint(allo, "{s}\n{s}/p/old\n", .{ url, st.root });
try fake.putz(&tmp, "f.txt", body);
var tck: tick.Tick = .{};
try std.testing.expectEqual(@as(usize, 1), try patc.patchFile(&st.ctxz, st.targ, try std.fmt.allocPrint(allo, "{s}/f.txt", .{st.root}), st.pth, 1, &tck));
const got = try fake.readz(allo, &tmp, "f.txt");
try std.testing.expect(std.mem.startsWith(u8, got, url));
try std.testing.expect(std.mem.indexOf(u8, got, "/p/new") != null);
}
test "a fault after the journal line leaves the file unchanged and undo-able" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const st = try setu(allo, &tmp, &aw, .{});
const body = try std.fmt.allocPrint(allo, "{s}/p/old\n", .{st.root});
try fake.putz(&tmp, "f.txt", body);
var tck: tick.Tick = .{ .left = 0 };
try std.testing.expectError(error.Injected, patc.patchFile(&st.ctxz, st.targ, try std.fmt.allocPrint(allo, "{s}/f.txt", .{st.root}), st.pth, 1, &tck));
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "f.txt"));
const ents = try jour.readAll(allo, std.testing.io, st.pth.jfil);
try std.testing.expectEqual(@as(usize, 1), ents.len);
}
test "an unwritable target retries then reports Blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
var conf: cfgz.Conf = .{};
conf.lock_retr = 1;
const st = try setu(allo, &tmp, &aw, conf);
const bad = try st.ctxz.nati(try std.fmt.allocPrint(allo, "{s}/no-such-dir/f.txt", .{st.root}));
try std.testing.expectError(patc.Erro.Blocked, patc.writeRetry(&st.ctxz, bad, "x"));
}
test "a vanished file is Blocked, never a crash" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const st = try setu(allo, &tmp, &aw, .{});
var tck: tick.Tick = .{};
try std.testing.expectError(patc.Erro.Blocked, patc.patchFile(&st.ctxz, st.targ, try std.fmt.allocPrint(allo, "{s}/gone.txt", .{st.root}), st.pth, 1, &tck));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
