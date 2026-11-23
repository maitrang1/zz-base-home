// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the whole flow: happy run, rollback at every step, flagged refs
// Flo: run on a fake machine > check files, names, journal > inject a fault at each step > tree must be byte-identical
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const flow = @import("ru-flow-main.zig");
const undo = @import("ru-flow-undo.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const exit = @import("ct-exit-code.zig");
const tick = @import("ut-faul-tick.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const seed = @import("te-flow-seed.zig");
fn stateOf(allo: std.mem.Allocator, ctxz: anytype, id: []const u8) !jour.State {
const pth = try stor.pthsOf(ctxz, id);
return jour.stateOf(try jour.readAll(allo, std.testing.io, pth.jfil));
}
test "happy run: refs patched, folder renamed, journal done, snapshots kept" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.okay, rsl.code);
try std.testing.expectEqual(@as(usize, 4), rsl.patched);
try std.testing.expectEqual(@as(usize, 3), rsl.files);
try std.testing.expectEqual(@as(usize, 0), rsl.left);
try std.testing.expectEqual(@as(usize, 0), rsl.flagd);
try std.testing.expect(!fake.hasz(&tmp, "p/old/x.txt") and fake.hasz(&tmp, "p/new/x.txt"));
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "self {s}/p/new/x.txt\nline2\r\nunicode tệp ✓\n", .{fxt.root}), try fake.readz(allo, &tmp, "p/new/x.txt"));
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "abs {s}/p/new and rel ../new/x.txt\n", .{fxt.root}), try fake.readz(allo, &tmp, "p/doc/a.md"));
try std.testing.expectEqualStrings(try std.fmt.allocPrint(allo, "see {s}/p/new/x.txt ok\nnothing else\n", .{fxt.root}), try fake.readz(allo, &tmp, "p/c.txt"));
try std.testing.expectEqualStrings("no refs here\n", try fake.readz(allo, &tmp, "p/untouched.txt"));
try std.testing.expectEqual(jour.State.done, try stateOf(allo, &ctxz, rsl.id));
try std.testing.expect(fake.hasz(&tmp, try std.fmt.allocPrint(allo, "zz-tena/as-apps/os-syst/rn-name-upda/snap/{s}/1.bak", .{rsl.id})));
try std.testing.expect(fake.hasz(&tmp, try std.fmt.allocPrint(allo, "zz-tena/as-apps/os-syst/rn-name-upda/snap/{s}/3.bak", .{rsl.id})));
}
test "run then undo is byte-identical to the start" {
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
const ur = try undo.undoRun(&ctxz, rsl.id, .{ .live = true });
try std.testing.expectEqual(exit.Code.okay, ur.code);
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
try std.testing.expect(!fake.hasz(&tmp, "p/new/x.txt"));
try std.testing.expectEqual(jour.State.rolled, try stateOf(allo, &ctxz, rsl.id));
}
test "a fault at every step rolls everything back to the exact start" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
var stepz: usize = 0;
while (stepz < 12) : (stepz += 1) {
var tck: tick.Tick = .{ .left = stepz };
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{ .tck = &tck });
if (rsl.code != .fail) break;
try std.testing.expectEqualStrings("Injected", rsl.note);
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
try std.testing.expect(!fake.hasz(&tmp, "p/new/x.txt"));
try std.testing.expectEqual(jour.State.rolled, try stateOf(allo, &ctxz, rsl.id));
}
try std.testing.expectEqual(@as(usize, 5), stepz);
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt") and !fake.hasz(&tmp, "p/old/x.txt"));
}
test "new name taken at rename time: rollback restores every patched file" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
try fake.putz(&tmp, "p/new/keep.txt", "mine");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.fail, rsl.code);
try std.testing.expectEqualStrings("PathAlreadyExists", rsl.note);
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
try std.testing.expectEqualStrings("mine", try fake.readz(allo, &tmp, "p/new/keep.txt"));
}
test "a bare name stays flagged: run succeeds, exit find, that file untouched" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
try fake.putz(&tmp, "p/n.txt", "the old one\n");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.find, rsl.code);
try std.testing.expectEqual(@as(usize, 1), rsl.flagd);
try std.testing.expectEqual(@as(usize, 0), rsl.left);
try std.testing.expectEqualStrings("the old one\n", try fake.readz(allo, &tmp, "p/n.txt"));
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt"));
}
test "with skip_comp_part off the bare name is patched too" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
try fake.putz(&tmp, "p/n.txt", "the old one\n");
var conf: @import("cf-conf-load.zig").Conf = .{};
conf.skip_comp_part = false;
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, conf, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.okay, rsl.code);
try std.testing.expectEqualStrings("the new one\n", try fake.readz(allo, &tmp, "p/n.txt"));
}
test "a ref that moved or vanished between plan and patch does not corrupt the file" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
try fake.putz(&tmp, "p/c.txt", "no ref now\n");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{});
try std.testing.expectEqual(exit.Code.okay, rsl.code);
try std.testing.expectEqualStrings("no ref now\n", try fake.readz(allo, &tmp, "p/c.txt"));
try std.testing.expectEqual(@as(usize, 3), rsl.patched);
}
test "a blocked file stops the run: exit blocked, every file restored, old name back" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
const before = try seed.dumpOld(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
var tck: tick.Tick = .{ .left = 1, .err = @import("rn-refs-patc.zig").Erro.Blocked };
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{ .tck = &tck });
try std.testing.expectEqual(exit.Code.bloc, rsl.code);
try std.testing.expectEqualStrings("Blocked", rsl.note);
try std.testing.expectEqualSlices(u8, before, try seed.dumpOld(allo, &tmp));
try std.testing.expect(!fake.hasz(&tmp, "p/new/x.txt"));
}
test "with force the blocked file is skipped, the rest finishes, its refs are left over" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const fxt = try seed.seed(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, fxt.root, .{}, false);
var tck: tick.Tick = .{ .left = 1, .err = @import("rn-refs-patc.zig").Erro.Blocked, .once = true };
const rsl = try flow.runFlow(&ctxz, fxt.old, fxt.new, .{ .force = true, .tck = &tck });
try std.testing.expectEqual(exit.Code.find, rsl.code);
try std.testing.expect(rsl.left >= 1);
try std.testing.expectEqual(@as(usize, 4), rsl.patched + rsl.left);
try std.testing.expect(fake.hasz(&tmp, "p/new/x.txt"));
try std.testing.expectEqual(jour.State.done, try stateOf(allo, &ctxz, rsl.id));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
