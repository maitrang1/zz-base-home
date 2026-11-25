// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests the flow with non-file locations: registry, crontab
// Flo: run with a mock tool > value written > undo writes the old value back > fault at every step restores the location too
// I/O: tmp dir + mock tool > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const flow = @import("ru-flow-main.zig");
const undo = @import("ru-flow-undo.zig");
const exit = @import("ct-exit-code.zig");
const tick = @import("ut-faul-tick.zig");
const osys = @import("ut-osys-adap.zig");
const mock = @import("te-mock-runn.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const seed = @import("te-flow-seed.zig");
const Rigz = struct { old_data: []u8, new_data: []u8, out_old: []u8, out_new: []u8 };
fn regRig(allo: std.mem.Allocator, fxt: seed.Fxt) !Rigz {
const nold = try osys.natiForm(allo, osys.host, fxt.old);
const nnew = try osys.natiForm(allo, osys.host, fxt.new);
const od = try std.fmt.allocPrint(allo, "C:\\bin;{s}\\tools", .{nold});
const nd = try std.fmt.allocPrint(allo, "C:\\bin;{s}\\tools", .{nnew});
return .{ .old_data = od, .new_data = nd, .out_old = try std.fmt.allocPrint(allo, "\r\nHKEY_CURRENT_USER\\Environment\r\n    Path    REG_EXPAND_SZ    {s}\r\n", .{od}), .out_new = try std.fmt.allocPrint(allo, "\r\nHKEY_CURRENT_USER\\Environment\r\n    Path    REG_EXPAND_SZ    {s}\r\n", .{nd}) };
}
test "registry value is patched with reg add, then undo writes the old value back" {
if (!osys.host.wind) return error.SkipZigTest;
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const rg = try regRig(allo, fxt);
var mck: mock.Mock = .{ .rule = &.{
.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = rg.out_old, .maxz = 1 },
.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = rg.out_new },
.{ .pref = &.{ "reg", "query", "HKEY_CURRENT_USER\\Environment", "/v", "Path" }, .outz = rg.out_new },
.{ .pref = &.{ "reg", "add" } },
} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.makeMock(allo, &aw.writer, fxt.root, .{}, false, &mck);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.okay, rsl.code);
try std.testing.expectEqual(@as(usize, 1), rsl.locs);
try std.testing.expectEqual(@as(usize, 5), rsl.patched);
try std.testing.expectEqual(@as(usize, 1), mck.callz("reg add "));
var addz: []const u8 = "";
for (mck.call.items) |call| { if (std.mem.startsWith(u8, call, "reg add ")) addz = call; }
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "reg add HKEY_CURRENT_USER\\Environment /v Path /t REG_EXPAND_SZ /d {s} /f", .{rg.new_data}), addz);
_ = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectEqual(@as(usize, 2), mck.callz("reg add "));
for (mck.call.items) |call| { if (std.mem.startsWith(u8, call, "reg add ")) addz = call; }
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "reg add HKEY_CURRENT_USER\\Environment /v Path /t REG_EXPAND_SZ /d {s} /f", .{rg.old_data}), addz);
}
test "a fault at every step puts the registry value back too" {
if (!osys.host.wind) return error.SkipZigTest;
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
const rg = try regRig(allo, fxt);
var stepz: usize = 0;
while (stepz < 12) : (stepz += 1) {
var mck: mock.Mock = .{ .rule = &.{
.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = rg.out_old, .maxz = 1 },
.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = rg.out_new },
.{ .pref = &.{ "reg", "query", "HKEY_CURRENT_USER\\Environment", "/v", "Path" }, .outz = if (stepz <= 3) rg.out_old else rg.out_new },
.{ .pref = &.{ "reg", "add" } },
} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.makeMock(allo, &aw.writer, fxt.root, .{}, false, &mck);
var tck: tick.Tick = .{ .left = stepz };
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{ .tck = &tck });
if (rsl.code != .fail) break;
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
const adds = mck.callz("reg add ");
if (stepz <= 3) try std.testing.expectEqual(@as(usize, 0), adds) else {
try std.testing.expectEqual(@as(usize, 2), adds);
try std.testing.expect(std.mem.indexOf(u8, mck.call.items[mck.call.items.len - 1], rg.old_data) != null);
}
}
try std.testing.expectEqual(@as(usize, 6), stepz);
}
test "a registry value changed by someone else blocks the undo" {
if (!osys.host.wind) return error.SkipZigTest;
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const rg = try regRig(allo, fxt);
const other = try std.fmt.allocPrint(allo, "\r\nHKEY_CURRENT_USER\\Environment\r\n    Path    REG_EXPAND_SZ    C:\\somebody\\else\r\n", .{});
var mck: mock.Mock = .{ .rule = &.{
.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = rg.out_old, .maxz = 1 },
.{ .pref = &.{ "reg", "query", "HKCU\\Environment", "/s" }, .outz = rg.out_new },
.{ .pref = &.{ "reg", "query", "HKEY_CURRENT_USER\\Environment", "/v", "Path" }, .outz = other },
.{ .pref = &.{ "reg", "add" } },
} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.makeMock(allo, &aw.writer, fxt.root, .{}, false, &mck);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.okay, rsl.code);
const ur = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectEqual(exit.Code.bloc, ur.code);
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt"));
}
test "crontab line is patched with crontab FILE, undo reinstalls the old text" {
if (osys.host.wind) return error.SkipZigTest;
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const oldt = try std.fmt.allocPrint(allo, "0 3 * * * {s}/run.sh\n", .{fxt.old});
const newt = try std.fmt.allocPrint(allo, "0 3 * * * {s}/run.sh\n", .{fxt.new});
var mck: mock.Mock = .{ .rule = &.{
.{ .pref = &.{ "crontab", "-l" }, .outz = oldt, .maxz = 1 },
.{ .pref = &.{ "crontab", "-l" }, .outz = newt },
.{ .pref = &.{"crontab"} },
} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.makeMock(allo, &aw.writer, fxt.root, .{}, false, &mck);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.okay, rsl.code);
try std.testing.expectEqual(@as(usize, 1), rsl.locs);
try std.testing.expectEqual(@as(usize, 1), mck.callz("crontab /"));
_ = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectEqual(@as(usize, 2), mck.callz("crontab /"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
