// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for re-pointing a symbolic link
// Flo: make a link > retarget it > read back > missing link target > skip when the OS refuses links
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const link = @import("sy-link-kind.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
fn mkLink(tmp: *std.testing.TmpDir, target: []const u8, name: []const u8) !void {
tmp.dir.symLink(std.testing.io, target, name, .{}) catch return error.SkipZigTest;
}
test "retarget a link and read it back" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "a.txt", "A");
try fake.putz(&tmp, "b.txt", "B");
try mkLink(&tmp, "a.txt", "ln");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const name = try std.fmt.allocPrint(allo, "{s}/ln", .{root});
try std.testing.expectEqualStrings("a.txt", try link.currentz(&ctxz, name));
try link.setz(&ctxz, name, "b.txt", "t1");
try std.testing.expectEqualStrings("b.txt", try link.currentz(&ctxz, name));
try std.testing.expectEqualStrings("B", try fake.readz(allo, &tmp, "ln"));
try link.setz(&ctxz, name, "a.txt", "t2");
try std.testing.expectEqualStrings("A", try fake.readz(allo, &tmp, "ln"));
}
test "reading a path that is not a link is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "plain.txt", "x");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
try std.testing.expect(std.meta.isError(link.currentz(&ctxz, try std.fmt.allocPrint(allo, "{s}/plain.txt", .{root}))));
try std.testing.expect(std.meta.isError(link.currentz(&ctxz, try std.fmt.allocPrint(allo, "{s}/none", .{root}))));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
