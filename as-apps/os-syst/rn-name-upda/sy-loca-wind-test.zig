// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for registry locations through a mock reg tool
// Flo: parse reg output > collect refs > classes (HKLM, multi) > apply and read back calls > failures
// I/O: tmp dir + mock > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const wind = @import("sy-loca-wind.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const scan = @import("ru-flow-scan.zig");
const mock = @import("te-mock-runn.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const cfgz = @import("cf-conf-load.zig");
const SAMP = "\r\nHKEY_CURRENT_USER\\Environment\r\n    Path    REG_EXPAND_SZ    C:\\bin;C:\\p\\old\\tools;%USERPROFILE%\\x\r\n    TEMP    REG_EXPAND_SZ    %USERPROFILE%\\AppData\\Local\\Temp\r\n    Multi    REG_MULTI_SZ    C:\\p\\old\\a\\0C:\\q\r\n    Count    REG_DWORD    0x5\r\n    (Default)    REG_SZ    \r\n\r\nHKEY_CURRENT_USER\\Environment\\Sub\r\n    Home    REG_SZ    C:\\p\\old\r\n";
test "parse: keys, names, types, data, empty data, tabs of the format" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const vals = try wind.parseQuery(arna.allocator(), SAMP);
try std.testing.expectEqual(@as(usize, 6), vals.len);
try std.testing.expectEqualStrings("HKEY_CURRENT_USER\\Environment", vals[0].key);
try std.testing.expectEqualStrings("Path", vals[0].name);
try std.testing.expectEqualStrings("REG_EXPAND_SZ", vals[0].typz);
try std.testing.expectEqualStrings("C:\\bin;C:\\p\\old\\tools;%USERPROFILE%\\x", vals[0].data);
try std.testing.expectEqualStrings("(Default)", vals[4].name);
try std.testing.expectEqualStrings("", vals[4].data);
try std.testing.expectEqualStrings("HKEY_CURRENT_USER\\Environment\\Sub", vals[5].key);
}
test "garbage and empty output parse to nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectEqual(@as(usize, 0), (try wind.parseQuery(arna.allocator(), "")).len);
try std.testing.expectEqual(@as(usize, 0), (try wind.parseQuery(arna.allocator(), "ERROR: The system was unable to find the specified registry key\r\n")).len);
try std.testing.expectEqual(@as(usize, 0), (try wind.parseQuery(arna.allocator(), "    Orphan    REG_SZ    x\r\n")).len);
}
test "name packs and unpacks key, value and type" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const name = try wind.nameOf(arna.allocator(), .{ .key = "HKCU\\E", .name = "Path", .typz = "REG_SZ", .data = "" });
const spl = wind.splitName(name).?;
try std.testing.expectEqualStrings("HKCU\\E", spl.key);
try std.testing.expectEqualStrings("Path", spl.name);
try std.testing.expectEqualStrings("REG_SZ", spl.typz);
try std.testing.expect(wind.splitName("nope") == null);
}
test "collect finds string values with the old path, patches only the path part" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = SAMP }} };
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, root, .{}, false, &mck);
ctxz.osy = .{ .wind = true, .caze = true };
const targ = try scan.targOf(&ctxz, "C:/p/old", "C:/p/new");
var outc: walk.Outc = .{};
try wind.collect(&ctxz, targ, &outc);
try std.testing.expectEqual(@as(usize, 3), outc.lrefs.items.len);
const first = outc.lrefs.items[0];
try std.testing.expectEqual(plan.Lkind.regv, first.kind);
try std.testing.expectEqualStrings("C:\\bin;C:\\p\\new\\tools;%USERPROFILE%\\x", first.newv);
try std.testing.expectEqualStrings("C:\\bin;C:\\p\\old\\tools;%USERPROFILE%\\x", first.oldv);
try std.testing.expect(!first.skip);
try std.testing.expect(outc.lrefs.items[1].skip);
try std.testing.expect(!outc.lrefs.items[2].skip);
try std.testing.expectEqualStrings("C:\\p\\new", outc.lrefs.items[2].newv);
}
test "multi-string values are found but never patched" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var conf: cfgz.Conf = .{};
conf.skip_bina = false;
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = SAMP }} };
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, root, conf, false, &mck);
ctxz.osy = .{ .wind = true, .caze = true };
const targ = try scan.targOf(&ctxz, "C:/p/old", "C:/p/new");
var outc: walk.Outc = .{};
try wind.collect(&ctxz, targ, &outc);
try std.testing.expect(outc.lrefs.items[1].skip);
}
test "HKLM values carry the system class and are skipped by default" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const svc = "\r\nHKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Foo\r\n    ImagePath    REG_EXPAND_SZ    C:\\p\\old\\svc.exe -run\r\n";
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "reg", "query", "HKLM\\SYSTEM\\CurrentControlSet\\Services", "/s" }, .outz = svc }} };
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, root, .{}, false, &mck);
ctxz.osy = .{ .wind = true, .caze = true };
const targ = try scan.targOf(&ctxz, "C:/p/old", "C:/p/new");
var outc: walk.Outc = .{};
try wind.collect(&ctxz, targ, &outc);
try std.testing.expectEqual(@as(usize, 1), outc.lrefs.items.len);
try std.testing.expect(outc.lrefs.items[0].skip);
try std.testing.expectEqual(plan.Clas.syst, outc.lrefs.items[0].clas);
}
test "absent reg tool and a failing query are quiet" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"reg"}, .code = 1, .errz = "ERROR" }} };
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, root, .{}, false, &mck);
ctxz.osy = .{ .wind = true, .caze = true };
const targ = try scan.targOf(&ctxz, "C:/p/old", "C:/p/new");
var outc: walk.Outc = .{};
try wind.collect(&ctxz, targ, &outc);
try std.testing.expectEqual(@as(usize, 0), outc.lrefs.items.len);
var none: mock.Mock = .{};
var ctx2 = try make.makeMock(allo, &aw.writer, root, .{}, false, &none);
ctx2.osy = .{ .wind = true, .caze = true };
try wind.collect(&ctx2, targ, &outc);
try std.testing.expectEqual(@as(usize, 0), outc.lrefs.items.len);
}
test "set calls reg add with key, value, type, data and /f; failure is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "reg", "add" } }} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.makeMock(allo, &aw.writer, root, .{}, false, &mck);
const name = try wind.nameOf(allo, .{ .key = "HKEY_CURRENT_USER\\Environment", .name = "Path", .typz = "REG_EXPAND_SZ", .data = "" });
try wind.setz(&ctxz, name, "C:\\p\\new");
try std.testing.expectEqualStrings("reg add HKEY_CURRENT_USER\\Environment /v Path /t REG_EXPAND_SZ /d C:\\p\\new /f", mck.call.items[0]);
const defn = try wind.nameOf(allo, .{ .key = "HKCU\\K", .name = "(Default)", .typz = "REG_SZ", .data = "" });
try wind.setz(&ctxz, defn, "v");
try std.testing.expectEqualStrings("reg add HKCU\\K /ve /t REG_SZ /d v /f", mck.call.items[1]);
var bad: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "reg", "add" }, .code = 1 }} };
const ctx2 = try make.makeMock(allo, &aw.writer, root, .{}, false, &bad);
try std.testing.expectError(wind.Erro.RegFail, wind.setz(&ctx2, name, "x"));
try std.testing.expectError(wind.Erro.RegFail, wind.setz(&ctx2, "broken", "x"));
}
test "current reads one value back by name" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "reg", "query", "HKEY_CURRENT_USER\\Environment", "/v", "Path" }, .outz = SAMP }, .{ .pref = &.{ "reg", "query", "HKEY_CURRENT_USER\\Environment", "/v", "Nope" }, .code = 1 }} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.makeMock(allo, &aw.writer, root, .{}, false, &mck);
const name = try wind.nameOf(allo, .{ .key = "HKEY_CURRENT_USER\\Environment", .name = "Path", .typz = "REG_EXPAND_SZ", .data = "" });
try std.testing.expectEqualStrings("C:\\bin;C:\\p\\old\\tools;%USERPROFILE%\\x", try wind.current(&ctxz, name));
const gone = try wind.nameOf(allo, .{ .key = "HKEY_CURRENT_USER\\Environment", .name = "Nope", .typz = "REG_SZ", .data = "" });
try std.testing.expectError(wind.Erro.RegFail, wind.current(&ctxz, gone));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
