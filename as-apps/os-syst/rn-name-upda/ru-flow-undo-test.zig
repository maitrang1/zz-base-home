// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for undo: dry-run, conflicts, force, twice, unknown id
// Flo: run > undo variants > check disk and journal
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const flow = @import("ru-flow-main.zig");
const undo = @import("ru-flow-undo.zig");
const exit = @import("ct-exit-code.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const seed = @import("te-flow-seed.zig");
test "dry-run undo reports and changes nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
const after = try fake.dumpz(allo, &tmp, &.{ "p/new/x.txt", "p/doc/a.md", "p/c.txt" });
const ur = try undo.undoRun(&ctxz, rsl.id, .{});
try std.testing.expectEqual(exit.Code.okay, ur.code);
try std.testing.expectEqual(@as(usize, 4), ur.restd);
try std.testing.expectEqualSlices(u8, after, try fake.dumpz(allo, &tmp, &.{ "p/new/x.txt", "p/doc/a.md", "p/c.txt" }));
const again = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectEqual(exit.Code.okay, again.code);
}
test "undo twice: the second says already undone" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
_ = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectError(undo.Erro.AlreadyUndone, undo.undoRun(&ctxz, rsl.id, .{ .live = true }));
}
test "unknown run id" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
try std.testing.expectError(undo.Erro.NoJournal, undo.undoRun(&ctxz, "nope", .{ .live = true }));
}
test "a file changed after the run blocks the whole undo; nothing moves" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try fake.putz(&tmp, "p/c.txt", "edited by someone else\n");
const ur = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectEqual(exit.Code.bloc, ur.code);
try std.testing.expectEqual(@as(usize, 1), ur.conf);
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt") and !fake.hasz(&tmp, "p/old/x.txt"));
try std.testing.expectEqualStrings("edited by someone else\n", try fake.readz(allo, &tmp, "p/c.txt"));
}
test "force overwrites the conflicting file and finishes the undo" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try fake.putz(&tmp, "p/c.txt", "edited by someone else\n");
const ur = try undo.undoRun(&ctxz, rsl.id, .{ .live = true, .force = true });
try std.testing.expectEqual(exit.Code.okay, ur.code);
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
}
test "a missing snapshot is a conflict, not a silent skip" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try fake.putz(&tmp, try std.fmt.allocPrint(allo, "zz-tena/as-apps/os-syst/rn-name-upda/snap/{s}/2.bak", .{rsl.id}), "corrupted snapshot");
const ur = try undo.undoRun(&ctxz, rsl.id, .{ .live = true, .force = true });
try std.testing.expectEqual(exit.Code.bloc, ur.code);
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
