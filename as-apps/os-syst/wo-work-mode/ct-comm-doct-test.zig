// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo doct: every check state
// Flo: ISO time parser > each check with a mock runner and scratch state files > output shape
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const doct = @import("ct-comm-doct.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const stat = @import("st-stat-file.zig");
const exit = @import("ct-exit-code.zig");
const NOWZ = make.NOWZ;
fn runOne(allo: std.mem.Allocator, rule: []const mock.Rule, name: []const u8, home: []const u8) !struct { code: exit.Code, text: []const u8 } {
var mck: mock.Mock = .{ .rule = rule };
var buff: std.Io.Writer.Allocating = .init(allo);
const list = try allo.dupe([]const u8, &.{name});
var cfgv: cfgz.Conf = .{};
cfgv.chek_t0_list = list;
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, false, false);
const code = try doct.comm(&ctxz, &.{});
return .{ .code = code, .text = buff.written() };
}
test "ISO time: epoch, leap day, offset, fraction, rejects" {
try std.testing.expectEqual(@as(?i64, 0), doct.isoEpoc("1970-01-01T00:00:00Z"));
try std.testing.expectEqual(@as(?i64, 946684800), doct.isoEpoc("2000-01-01T00:00:00Z"));
try std.testing.expectEqual(@as(?i64, 951868800), doct.isoEpoc("2000-03-01T00:00:00Z"));
try std.testing.expectEqual(@as(?i64, 1709208000), doct.isoEpoc("2024-02-29T12:00:00Z"));
try std.testing.expectEqual(doct.isoEpoc("2026-11-18T03:00:00Z"), doct.isoEpoc("2026-11-18T10:00:00+07:00"));
try std.testing.expectEqual(doct.isoEpoc("2026-11-18T13:00:00Z"), doct.isoEpoc("2026-11-18T10:00:00-03:00"));
try std.testing.expectEqual(@as(?i64, 946684800), doct.isoEpoc("2000-01-01T00:00:00.123456Z"));
try std.testing.expect(doct.isoEpoc("2000-13-01T00:00:00Z") == null);
try std.testing.expect(doct.isoEpoc("2000-01-00T00:00:00Z") == null);
try std.testing.expect(doct.isoEpoc("2000-01-01T24:00:00Z") == null);
try std.testing.expect(doct.isoEpoc("2000-01-01T00:00:00") == null);
try std.testing.expect(doct.isoEpoc("2000-01-01 00:00:00Z") == null);
try std.testing.expect(doct.isoEpoc("2000-01-01T00:00:00Zjunk") == null);
try std.testing.expect(doct.isoEpoc("garbage") == null);
try std.testing.expect(doct.isoEpoc("") == null);
}
test "hook: ok, wrong path = drift, git absent = blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const okay = try runOne(allo, &.{.{ .pref = &.{ "git", "config" }, .outz = "ci-flow-sync\n" }}, "hook", "h");
try std.testing.expectEqual(exit.Code.okay, okay.code);
const bad = try runOne(allo, &.{.{ .pref = &.{ "git", "config" }, .outz = ".githooks\n" }}, "hook", "h");
try std.testing.expectEqual(exit.Code.drif, bad.code);
try std.testing.expect(std.mem.indexOf(u8, bad.text, "hooksPath=.githooks want ci-flow-sync") != null);
const unset = try runOne(allo, &.{.{ .pref = &.{ "git", "config" }, .code = 1 }}, "hook", "h");
try std.testing.expectEqual(exit.Code.drif, unset.code);
const none = try runOne(allo, &.{}, "hook", "h");
try std.testing.expectEqual(exit.Code.bloc, none.code);
}
test "tool: pinned zig version ok, other version drifts, absent blocks" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, &.{.{ .pref = &.{"zig"}, .outz = "0.16.0\n" }}, "tool", "h")).code);
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{.{ .pref = &.{"zig"}, .outz = "0.15.2\n" }}, "tool", "h")).code);
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{.{ .pref = &.{"zig"}, .outz = "0.16.0\n", .code = 1 }}, "tool", "h")).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, &.{}, "tool", "h")).code);
}
test "head: equal ok, different drift, no upstream or no commit blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const same: []const mock.Rule = &.{ .{ .pref = &.{ "git", "rev-parse", "HEAD" }, .outz = "abc\n" }, .{ .pref = &.{ "git", "rev-parse", "@{u}" }, .outz = "abc\n" } };
const diff: []const mock.Rule = &.{ .{ .pref = &.{ "git", "rev-parse", "HEAD" }, .outz = "abc\n" }, .{ .pref = &.{ "git", "rev-parse", "@{u}" }, .outz = "abd\n" } };
const noup: []const mock.Rule = &.{ .{ .pref = &.{ "git", "rev-parse", "HEAD" }, .outz = "abc\n" }, .{ .pref = &.{ "git", "rev-parse", "@{u}" }, .code = 128 } };
const nohd: []const mock.Rule = &.{.{ .pref = &.{ "git", "rev-parse", "HEAD" }, .code = 128 }};
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, same, "head", "h")).code);
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, diff, "head", "h")).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, noup, "head", "h")).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, nohd, "head", "h")).code);
}
test "wipz / bkup age: fresh ok, exactly at limit ok, one second over drifts, missing per check" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{}, "wipz", home)).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, &.{}, "bkup", home)).code);
const dirz = try stat.dirzOf(allo, home, ".wo-work-mode");
try stat.stamWrit(allo, std.testing.io, dirz, try stat.pathOf(allo, dirz, "wipz"), .{ .when = NOWZ - 1800, .okay = true });
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, &.{}, "wipz", home)).code);
try stat.stamWrit(allo, std.testing.io, dirz, try stat.pathOf(allo, dirz, "wipz"), .{ .when = NOWZ - 1801, .okay = true });
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{}, "wipz", home)).code);
try stat.stamWrit(allo, std.testing.io, dirz, try stat.pathOf(allo, dirz, "bkup"), .{ .when = NOWZ - 10, .okay = false });
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{}, "bkup", home)).code);
}
test "dril: age, rto and last result each decide" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, &.{}, "dril", home)).code);
const dirz = try stat.dirzOf(allo, home, ".wo-work-mode");
const path = try stat.pathOf(allo, dirz, "dril");
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = NOWZ - 3024000, .secs = 900, .okay = true });
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, &.{}, "dril", home)).code);
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = NOWZ - 3024001, .secs = 900, .okay = true });
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{}, "dril", home)).code);
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = NOWZ, .secs = 901, .okay = true });
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{}, "dril", home)).code);
try stat.stamWrit(allo, std.testing.io, dirz, path, .{ .when = NOWZ, .secs = 1, .okay = false });
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, &.{}, "dril", home)).code);
}
test "tail: far key ok, boundary 14 days ok, one second short drifts, no expiry ok, junk blocked" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const far: []const mock.Rule = &.{.{ .pref = &.{"tailscale"}, .outz = "{\"Self\":{\"KeyExpiry\":\"2024-06-01T00:00:00Z\"}}" }};
const edge: []const mock.Rule = &.{.{ .pref = &.{"tailscale"}, .outz = "{\"Self\":{\"KeyExpiry\":\"2023-11-28T22:13:20Z\"}}" }};
const shrt: []const mock.Rule = &.{.{ .pref = &.{"tailscale"}, .outz = "{\"Self\":{\"KeyExpiry\":\"2023-11-28T22:13:19Z\"}}" }};
const never: []const mock.Rule = &.{.{ .pref = &.{"tailscale"}, .outz = "{\"Self\":{}}" }};
const junk: []const mock.Rule = &.{.{ .pref = &.{"tailscale"}, .outz = "not json" }};
const down: []const mock.Rule = &.{.{ .pref = &.{"tailscale"}, .code = 1 }};
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, far, "tail", "h")).code);
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, edge, "tail", "h")).code);
try std.testing.expectEqual(exit.Code.drif, (try runOne(allo, shrt, "tail", "h")).code);
try std.testing.expectEqual(exit.Code.okay, (try runOne(allo, never, "tail", "h")).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, junk, "tail", "h")).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, down, "tail", "h")).code);
try std.testing.expectEqual(exit.Code.bloc, (try runOne(allo, &.{}, "tail", "h")).code);
}
test "unknown check name fails loudly; drift beats blocked in one run; --json shape" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
try std.testing.expectEqual(exit.Code.fail, (try runOne(allo, &.{}, "nope", "h")).code);
var mck: mock.Mock = .{ .rule = &.{ .{ .pref = &.{ "git", "config" }, .outz = "wrong\n" } } };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.chek_t0_list = &.{ "hook", "tool" };
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, "h", false, true);
try std.testing.expectEqual(exit.Code.drif, try doct.comm(&ctxz, &.{}));
try std.testing.expect(std.mem.startsWith(u8, buff.written(), "{\"code\":3,\"facts\":[{\"name\":\"hook\""));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
