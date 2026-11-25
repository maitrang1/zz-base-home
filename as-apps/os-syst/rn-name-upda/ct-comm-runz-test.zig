// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: End-to-end tests for rn runz and undo
// Flo: dry-run writes nothing > live run line > json > undo last > bad input
// I/O: tmp dir fake machine > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const runz = @import("ct-comm-runz.zig");
const undo = @import("ct-comm-undo.zig");
const exit = @import("ct-exit-code.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const seed = @import("te-flow-seed.zig");
fn pair(allo: std.mem.Allocator, fxt: seed.Fxt) ![]const []const u8 { return allo.dupe([]const u8, &.{ fxt.old, fxt.new }); }
test "dry-run is the default: plan printed, disk untouched" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&ctxz, try pair(allo, fxt)));
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "apply 4 ") != null);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "dry-run: nothing written. Add --live to apply.") != null);
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
try std.testing.expect(!fake.hasz(&tmp, "p/new/x.txt"));
try std.testing.expect(!fake.hasz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour/20231114-221320.jsonl"));
}
test "live run prints one result line with the run id and the undo hint" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
ctxz.ladd.live = true;
try std.testing.expectEqual(exit.Code.okay, try runz.comm(&ctxz, try pair(allo, fxt)));
try std.testing.expectEqualStrings("ok 20231114-221320 · patched 4 refs in 3 files · renamed · left 0 · flagged 0\nundo: rn undo 20231114-221320 --live\n", aw.written());
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt"));
}
test "json live result parses" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, true);
ctxz.ladd.live = true;
_ = try runz.comm(&ctxz, try pair(allo, fxt));
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "\"patched\":4") != null);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "\"code\":\"okay\"") != null);
}
test "undo last: dry-run first, then live restores everything" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
ctxz.ladd.live = true;
_ = try runz.comm(&ctxz, try pair(allo, fxt));
aw.clearRetainingCapacity();
ctxz.ladd.live = false;
try std.testing.expectEqual(exit.Code.okay, try undo.comm(&ctxz, &.{"last"}));
try std.testing.expectEqualStrings("dry-run 20231114-221320 · restored 4 · already ok 0 · add --live to apply\n", aw.written());
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt"));
aw.clearRetainingCapacity();
ctxz.ladd.live = true;
try std.testing.expectEqual(exit.Code.okay, try undo.comm(&ctxz, &.{"last"}));
try std.testing.expectEqualStrings("undone 20231114-221320 · restored 4 · already ok 0\n", aw.written());
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
}
test "undo with nothing to undo, an unknown id, a twice-undone id: all fail cleanly" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
ctxz.ladd.live = true;
try std.testing.expectEqual(exit.Code.fail, try undo.comm(&ctxz, &.{"last"}));
try std.testing.expectEqual(exit.Code.fail, try undo.comm(&ctxz, &.{"nope"}));
_ = try runz.comm(&ctxz, try pair(allo, fxt));
_ = try undo.comm(&ctxz, &.{"last"});
try std.testing.expectEqual(exit.Code.fail, try undo.comm(&ctxz, &.{"last"}));
}
test "a changed file makes undo print blocked and exit 4" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
ctxz.ladd.live = true;
_ = try runz.comm(&ctxz, try pair(allo, fxt));
try fake.putz(&tmp, "p/c.txt", "someone edited\n");
aw.clearRetainingCapacity();
try std.testing.expectEqual(exit.Code.bloc, try undo.comm(&ctxz, &.{"last"}));
try std.testing.expect(std.mem.startsWith(u8, aw.written(), "blocked 20231114-221320: 1 items changed since the run."));
}
test "bad pair fails; wrong arg counts are usage errors" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
ctxz.ladd.live = true;
try std.testing.expectEqual(exit.Code.fail, try runz.comm(&ctxz, &.{ fxt.old, fxt.old }));
try std.testing.expectEqual(exit.Code.fail, try runz.comm(&ctxz, &.{ try std.fmt.allocPrint(allo, "{s}/ghost", .{fxt.root}), fxt.new }));
try std.testing.expectError(exit.Erro.Usag, runz.comm(&ctxz, &.{"one"}));
try std.testing.expectError(exit.Erro.Usag, undo.comm(&ctxz, &.{}));
try std.testing.expectError(exit.Erro.Usag, undo.comm(&ctxz, &.{ "a", "b" }));
try std.testing.expect(fake.hasz(&tmp, "p/old/x.txt"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
