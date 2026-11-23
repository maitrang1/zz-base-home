// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the location door: kind names and the reload hint
// Flo: kind from text > no hint for plain files > systemd reload through the mock > plist hint > windows says nothing
// I/O: tmp dir + mock > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const loca = @import("sy-loca-list.zig");
const plan = @import("pl-plan-buil.zig");
const mock = @import("te-mock-runn.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
test "kind names map to kinds, junk maps to null" {
try std.testing.expectEqual(plan.Lkind.link, loca.kindOf("link").?);
try std.testing.expectEqual(plan.Lkind.regv, loca.kindOf("regv").?);
try std.testing.expectEqual(plan.Lkind.cron, loca.kindOf("cron").?);
try std.testing.expect(loca.kindOf("LINK") == null);
try std.testing.expect(loca.kindOf("") == null);
}
test "plain files give no hint and call no tool" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{};
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false, &mck);
ctxz.osy = .{ .wind = false, .caze = false };
try std.testing.expectEqualStrings("", loca.reload(&ctxz, &.{ "/a/b.txt", "/a/c.service.bak" }));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
test "a changed unit file triggers systemctl --user daemon-reload" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"systemctl"} }} };
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false, &mck);
ctxz.osy = .{ .wind = false, .caze = false };
try std.testing.expectEqualStrings("systemd user units reloaded", loca.reload(&ctxz, &.{"/h/.config/systemd/user/a.timer"}));
try std.testing.expectEqualStrings("systemctl --user daemon-reload", mck.call.items[0]);
}
test "a failing or missing systemctl leaves a manual hint, never an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var bad: mock.Mock = .{ .rule = &.{.{ .pref = &.{"systemctl"}, .code = 1 }} };
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false, &bad);
ctxz.osy = .{ .wind = false, .caze = false };
try std.testing.expectEqualStrings("unit files changed: run systemctl daemon-reload", loca.reload(&ctxz, &.{"/x/a.service"}));
var none: mock.Mock = .{};
var ctx2 = try make.makeMock(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false, &none);
ctx2.osy = .{ .wind = false, .caze = false };
try std.testing.expectEqualStrings("unit files changed: run systemctl daemon-reload", loca.reload(&ctx2, &.{"/x/a.mount"}));
}
test "a changed plist gets the launchctl hint; windows gets none for unit files" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var mck: mock.Mock = .{};
var aw: std.Io.Writer.Allocating = .init(allo);
var ctxz = try make.makeMock(allo, &aw.writer, try fake.rootOf(allo, &tmp), .{}, false, &mck);
ctxz.osy = .{ .wind = false, .caze = true };
try std.testing.expectEqualStrings("plist files changed: reload with launchctl bootout + bootstrap", loca.reload(&ctxz, &.{"/Users/me/Library/LaunchAgents/a.plist"}));
ctxz.osy = .{ .wind = true, .caze = true };
try std.testing.expectEqualStrings("", loca.reload(&ctxz, &.{"C:/x/a.service"}));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
