// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the crontab location through a mock crontab tool
// Flo: collect refs > no crontab > absent tool > set writes a file and calls crontab
// I/O: tmp dir + mock > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const cron = @import("sy-loca-cron.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const scan = @import("ru-flow-scan.zig");
const mock = @import("te-mock-runn.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
const TAB = "# m h dom mon dow cmd\n0 3 * * * /srv/old/backup.sh --full\n5 3 * * * /srv/other/x.sh\n";
fn ctxOf(allo: std.mem.Allocator, tmp: *std.testing.TmpDir, aw: *std.Io.Writer.Allocating, mck: *mock.Mock, unix: bool) !@import("ct-ctrl-ctxz.zig").Ctxz {
var ctxz = try make.makeMock(allo, &aw.writer, try fake.rootOf(allo, tmp), .{}, false, mck);
if (unix) ctxz.osy = .{ .wind = false, .caze = false };
return ctxz;
}
test "collect finds the ref in the crontab text and patches only the path" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{ "crontab", "-l" }, .outz = TAB }} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try ctxOf(allo, &tmp, &aw, &mck, true);
const targ = try scan.targOf(&ctxz, "/srv/old", "/srv/new");
var outc: walk.Outc = .{};
try cron.collect(&ctxz, targ, &outc);
try std.testing.expectEqual(@as(usize, 1), outc.lrefs.items.len);
const lref = outc.lrefs.items[0];
try std.testing.expectEqual(plan.Lkind.cron, lref.kind);
try std.testing.expectEqualStrings(TAB, lref.oldv);
try std.testing.expectEqualStrings("# m h dom mon dow cmd\n0 3 * * * /srv/new/backup.sh --full\n5 3 * * * /srv/other/x.sh\n", lref.newv);
try std.testing.expect(!lref.skip);
}
test "no ref, no crontab (exit 1), empty crontab, absent tool: all quiet" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var aw: std.Io.Writer.Allocating = .init(allo);
const rulz = [_][]const mock.Rule{
&.{.{ .pref = &.{ "crontab", "-l" }, .outz = "0 3 * * * /srv/other/x.sh\n" }},
&.{.{ .pref = &.{ "crontab", "-l" }, .code = 1, .errz = "no crontab for me" }},
&.{.{ .pref = &.{ "crontab", "-l" }, .outz = "" }},
&.{},
};
for (rulz) |rul| {
var mck: mock.Mock = .{ .rule = rul };
const ctxz = try ctxOf(allo, &tmp, &aw, &mck, true);
const targ = try scan.targOf(&ctxz, "/srv/old", "/srv/new");
var outc: walk.Outc = .{};
try cron.collect(&ctxz, targ, &outc);
try std.testing.expectEqual(@as(usize, 0), outc.lrefs.items.len);
}
}
test "set writes the text to a temp file and installs it with crontab FILE" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"crontab"} }} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try ctxOf(allo, &tmp, &aw, &mck, false);
try cron.setz(&ctxz, "0 1 * * * /srv/new/x\n", "tag1");
try std.testing.expectEqual(@as(usize, 1), mck.callz("crontab "));
try std.testing.expect(std.mem.endsWith(u8, mck.call.items[0], "cron-tag1.txt"));
try std.testing.expectEqualStrings("0 1 * * * /srv/new/x\n", try fake.readz(allo, &tmp, "zz-tena/as-apps/os-syst/rn-name-upda/tmp/cron-tag1.txt"));
}
test "a failing crontab install is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"crontab"}, .code = 1 }} };
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try ctxOf(allo, &tmp, &aw, &mck, false);
try std.testing.expectError(cron.Erro.CronFail, cron.setz(&ctxz, "x\n", "t"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
