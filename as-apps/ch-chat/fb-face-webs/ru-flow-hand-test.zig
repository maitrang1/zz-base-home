// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for hand, stopif, soft goto and error-page retry
// Flo: owner simulated by a page timer > hand waits and alerts once > deadline parks > unsafe page stops > stopif ends early > soft goto skips the login halt > error page = Drift
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// Run: zig build test -Dfile=ru-flow-hand-test.zig
// ===================================================================
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const flow = @import("ru-flow-runz.zig");
var alerts: u32 = 0;
fn hook(_: ?*anyopaque, _: []const u8) void { alerts += 1; }
const MARK = [_][]const u8{"Code accepted"};
const SHOW = "setTimeout(function(){var p=document.createElement('p');p.textContent='Code accepted';document.body.appendChild(p)},1200);1";
fn steps(rig: *rigz.Rig, list: []const flow.Step) !void { var run: flow.Run = .{ .env = rig.env(), .store = &rig.store, .base = rig.base(), .alrt = hook }; try flow.runSteps(&run, list); }
fn nowMs(rig: *rigz.Rig) i64 { return @intCast(std.Io.Clock.real.now(rig.iozz).toMilliseconds()); }
test "hand waits until the marker shows, alerts the owner once, then the next step runs" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); alerts = 0; try steps(&rig, &.{.{ .op = .goto, .text = "/late/" }}); _ = try rig.page.evalVal(rig.aren.allocator(), SHOW); const t0 = nowMs(&rig); try steps(&rig, &.{ .{ .op = .hand, .labs = &MARK, .text = "enter the code" }, .{ .op = .click, .labs = &.{"Go on"} } }); try std.testing.expect(nowMs(&rig) - t0 >= 800); try std.testing.expectEqual(@as(u32, 1), alerts); try std.testing.expect(rig.waitPre("btn|Go on|", 3000)); }
test "hand returns at once when the marker is already there, without an alert" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); alerts = 0; try steps(&rig, &.{.{ .op = .goto, .text = "/late/" }}); try steps(&rig, &.{.{ .op = .hand, .labs = &.{"Late page"}, .text = "x" }}); try std.testing.expectEqual(@as(u32, 0), alerts); }
test "hand gives up at the deadline with WaitTimeout" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); alerts = 0; rig.conf.wait_maxx_secs = 1; try steps(&rig, &.{.{ .op = .goto, .text = "/late/" }}); const t0 = nowMs(&rig); try std.testing.expectError(error.WaitTimeout, steps(&rig, &.{.{ .op = .hand, .labs = &.{"Never shown"}, .text = "x" }})); try std.testing.expect(nowMs(&rig) - t0 >= 900); try std.testing.expectEqual(@as(u32, 1), alerts); }
test "hand stops with Unsafe when Facebook shows a block while it waits" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.wait_maxx_secs = 5; try steps(&rig, &.{.{ .op = .goto, .text = "/blocked", .soft = true }}); try std.testing.expectError(error.Unsafe, steps(&rig, &.{.{ .op = .hand, .labs = &.{"Never shown"}, .text = "x" }})); }
test "stopif ends the step list early when its text is on the page, and does nothing when it is not" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.retr_coun_maxz = 1; try steps(&rig, &.{ .{ .op = .goto, .text = "/late/" }, .{ .op = .stopif, .labs = &.{"Late page"} }, .{ .op = .click, .labs = &.{"Button that is not there"} } }); try std.testing.expectError(error.NoElement, steps(&rig, &.{ .{ .op = .goto, .text = "/late/" }, .{ .op = .stopif, .labs = &.{"Not on this page"} }, .{ .op = .click, .labs = &.{"Button that is not there"} } })); }
test "a normal goto to a login page halts with NeedLogin, a soft goto does not" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try std.testing.expectError(error.NeedLogin, steps(&rig, &.{.{ .op = .goto, .text = "/login" }})); try steps(&rig, &.{.{ .op = .goto, .text = "/login", .soft = true }}); }
test "a short error page is retried then reported as Drift; a normal page is not touched" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.retr_coun_maxz = 1; try std.testing.expectError(error.Drift, steps(&rig, &.{.{ .op = .goto, .text = "/errpage/" }})); try steps(&rig, &.{.{ .op = .goto, .text = "/late/" }}); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
