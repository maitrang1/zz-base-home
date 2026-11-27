// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for run ids, paths and the lock
// Flo: id is a stamp, a clash gets -2 > last id = newest > lock take, busy, release
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const stor = @import("st-runz-stor.zig");
const fk = @import("te-fake-repo.zig");
const tc = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
test "idNew is the clock stamp, then -2 when its journal exists; idLast is the newest" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
var wrtr: std.Io.Writer.Allocating = .init(allo);
var mck: mock.Mock = .{};
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
const ctxz = try tc.make(allo, &wrtr.writer, fake, .{}, &mck);
try std.testing.expect((try stor.idLast(&ctxz)) == null);
const one = try stor.idNew(&ctxz);
try std.testing.expectEqualStrings("20231114-221320", one);
const pth = try stor.pthsOf(&ctxz, one);
try std.Io.Dir.cwd().createDirPath(std.testing.io, pth.jour);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = pth.jfil, .data = "{}\n" });
try std.testing.expectEqualStrings("20231114-221320-2", try stor.idNew(&ctxz));
try std.testing.expectEqualStrings("20231114-221320", (try stor.idLast(&ctxz)).?);
}
test "lock: take, busy while fresh, free moves it aside, take again" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
var wrtr: std.Io.Writer.Allocating = .init(allo);
var mck: mock.Mock = .{};
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
const ctxz = try tc.make(allo, &wrtr.writer, fake, .{}, &mck);
try stor.lockTake(&ctxz, "r1");
try std.testing.expectError(stor.Erro.Busy, stor.lockTake(&ctxz, "r2"));
stor.lockFree(&ctxz, "r1");
try stor.lockTake(&ctxz, "r3");
const pth = try stor.pthsOf(&ctxz, "r3");
try std.testing.expectEqualStrings("r3", try fk.get(allo, std.testing.io, pth.data, "run.lock"));
try std.testing.expect(fk.has(allo, std.testing.io, pth.lold, "r1-done.lock"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
