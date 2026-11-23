// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the append-only journal and the run state
// Flo: append > read back in order > hostile text > run state from ops
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const jour = @import("lg-jour-writ.zig");
const fake = @import("te-mach-fake.zig");
fn paths(allo: std.mem.Allocator, tmp: *const std.testing.TmpDir) ![2][]u8 {
const root = try fake.rootOf(allo, tmp);
return .{ try std.fmt.allocPrint(allo, "{s}/jour", .{root}), try std.fmt.allocPrint(allo, "{s}/jour/r1.jsonl", .{root}) };
}
test "append keeps order and earlier lines" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const pth = try paths(allo, &tmp);
try jour.appd(allo, std.testing.io, pth[0], pth[1], .{ .op = "open", .a = "/o", .b = "/n" });
try jour.appd(allo, std.testing.io, pth[0], pth[1], .{ .op = "patch", .a = "/f", .b = "1.bak", .h0 = "aa", .h1 = "bb" });
try jour.appd(allo, std.testing.io, pth[0], pth[1], .{ .op = "done" });
const ents = try jour.readAll(allo, std.testing.io, pth[1]);
try std.testing.expectEqual(@as(usize, 3), ents.len);
try std.testing.expectEqualStrings("open", ents[0].op);
try std.testing.expectEqualStrings("/n", ents[0].b);
try std.testing.expectEqualStrings("patch", ents[1].op);
try std.testing.expectEqualStrings("bb", ents[1].h1);
try std.testing.expectEqualStrings("done", ents[2].op);
}
test "quotes, backslashes, unicode and spaces survive" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const pth = try paths(allo, &tmp);
const weird = "C:\\Users\\Dell 7750\\\"q\" tệp ✓\n2nd";
try jour.appd(allo, std.testing.io, pth[0], pth[1], .{ .op = "patch", .a = weird, .note = weird });
const ents = try jour.readAll(allo, std.testing.io, pth[1]);
try std.testing.expectEqual(@as(usize, 1), ents.len);
try std.testing.expectEqualStrings(weird, ents[0].a);
try std.testing.expectEqualStrings(weird, ents[0].note);
}
test "reading a missing journal is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const pth = try paths(allo, &tmp);
try std.testing.expectError(error.FileNotFound, jour.readAll(allo, std.testing.io, pth[1]));
}
test "blank lines are skipped, a broken line is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const pth = try paths(allo, &tmp);
try fake.putz(&tmp, "jour/r1.jsonl", "\n{\"op\":\"open\"}\r\n\n  \n{\"op\":\"done\"}\n");
const ents = try jour.readAll(allo, std.testing.io, pth[1]);
try std.testing.expectEqual(@as(usize, 2), ents.len);
try fake.putz(&tmp, "jour/r2.jsonl", "{not json}\n");
const bad = try std.fmt.allocPrint(allo, "{s}/jour/r2.jsonl", .{try fake.rootOf(allo, &tmp)});
try std.testing.expect(std.meta.isError(jour.readAll(allo, std.testing.io, bad)));
}
test "state: none, open, done, rolled (rolled after fail still rolled)" {
const none = [_]jour.Jent{};
try std.testing.expectEqual(jour.State.none, jour.stateOf(&none));
const open = [_]jour.Jent{ .{ .op = "open" }, .{ .op = "patch" } };
try std.testing.expectEqual(jour.State.open, jour.stateOf(&open));
const done = [_]jour.Jent{ .{ .op = "open" }, .{ .op = "done" } };
try std.testing.expectEqual(jour.State.done, jour.stateOf(&done));
const rolled = [_]jour.Jent{ .{ .op = "open" }, .{ .op = "rolled" }, .{ .op = "fail" } };
try std.testing.expectEqual(jour.State.rolled, jour.stateOf(&rolled));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
