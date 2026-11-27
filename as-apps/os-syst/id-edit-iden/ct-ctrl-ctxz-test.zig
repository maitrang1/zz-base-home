// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for repo discovery and the clock stamp
// Flo: stamp format > repo found from a nested folder > explicit repo_root wins > none found = error
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const fk = @import("te-fake-repo.zig");
test "stamTxt: epoch, a known date, a pre-epoch value clamps to 0" {
const allo = std.testing.allocator;
const a = try cx.stamTxt(allo, 0);
defer allo.free(a);
try std.testing.expectEqualStrings("19700101-000000", a);
const b = try cx.stamTxt(allo, 1_700_000_000);
defer allo.free(b);
try std.testing.expectEqualStrings("20231114-221320", b);
const c = try cx.stamTxt(allo, -5);
defer allo.free(c);
try std.testing.expectEqualStrings("19700101-000000", c);
}
test "repoFind: walks up from a nested folder, honors repo_root, errors when absent" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
const deep = try std.fs.path.join(allo, &.{ fake.repo, "do-note" });
const conf: cfgz.Conf = .{};
try std.testing.expectEqualStrings(fake.repo, try cx.repoFind(allo, std.testing.io, conf, deep, null));
try std.testing.expectEqualStrings(fake.repo, try cx.repoFind(allo, std.testing.io, conf, "/nowhere/x", fake.repo));
var set: cfgz.Conf = .{};
set.repo_root = "/forced/root";
try std.testing.expect(std.mem.indexOf(u8, try cx.repoFind(allo, std.testing.io, set, deep, null), "forced") != null);
try std.testing.expectError(cx.Erro.NoRepo, cx.repoFind(allo, std.testing.io, conf, "/nowhere/x", null));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
