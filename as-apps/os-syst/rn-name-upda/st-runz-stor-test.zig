// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for run ids and the data-dir layout
// Flo: id from the fixed clock > unique suffix > latest id > path shapes
// I/O: tmp dir > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const stor = @import("st-runz-stor.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
test "id comes from the clock: 1700000000 is 20231114-221320" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false);
try std.testing.expectEqualStrings("20231114-221320", try stor.idNew(&ctxz));
}
test "a taken id gets -2, then -3" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false);
try fake.putz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour/20231114-221320.jsonl", "{}\n");
try std.testing.expectEqualStrings("20231114-221320-2", try stor.idNew(&ctxz));
try fake.putz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour/20231114-221320-2.jsonl", "{}\n");
try std.testing.expectEqualStrings("20231114-221320-3", try stor.idNew(&ctxz));
}
test "latest id is the highest name; none when no runs" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false);
try std.testing.expect((try stor.idLast(&ctxz)) == null);
try fake.putz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour/20231101-000001.jsonl", "{}\n");
try fake.putz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour/20231114-221320.jsonl", "{}\n");
try fake.putz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour/note.txt", "x");
try std.testing.expectEqualStrings("20231114-221320", (try stor.idLast(&ctxz)).?);
}
test "paths sit under the data dir and carry the id" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false);
const pth = try stor.pthsOf(&ctxz, "rid");
try std.testing.expect(std.mem.endsWith(u8, pth.jfil, "rid.jsonl"));
try std.testing.expect(std.mem.indexOf(u8, pth.jfil, "jour") != null);
try std.testing.expect(std.mem.endsWith(u8, pth.snap, "rid"));
try std.testing.expect(std.mem.indexOf(u8, pth.snap, "snap") != null);
try std.testing.expect(std.mem.startsWith(u8, pth.jfil, pth.data));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
