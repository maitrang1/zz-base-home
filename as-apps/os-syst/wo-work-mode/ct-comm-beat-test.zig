// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests wo-work-mode beat: url pick, stamp ages, pings, dry-run
// Flo: mock curl + fixed clock > run beat > check argv, facts, exit codes
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const beat = @import("ct-comm-beat.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
fn hasCall(mck: *const mock.Mock, part: []const u8) bool {
for (mck.call.items) |line| { if (std.mem.indexOf(u8, line, part) != null) return true; }
return false;
}
fn urlFile(allo: std.mem.Allocator, home: []const u8, body: []const u8) !void {
try std.Io.Dir.cwd().createDirPath(std.testing.io, home);
try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = try std.fs.path.join(allo, &.{ home, "beat.url" }), .data = body });
}
test "urlPick takes the first https line, refuses http, spaces, quotes and empty" {
try std.testing.expectEqualStrings("https://hc-ping.com/abc", beat.urlPick("https://hc-ping.com/abc\r\nsecond\n").?);
try std.testing.expect(beat.urlPick("http://hc-ping.com/abc") == null);
try std.testing.expect(beat.urlPick("https://a b") == null);
try std.testing.expect(beat.urlPick("https://a\"b") == null);
try std.testing.expect(beat.urlPick("https://") == null);
try std.testing.expect(beat.urlPick("") == null);
}
test "usage: no arguments" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", false, false);
try std.testing.expectError(exit.Erro.Usag, beat.comm(&ctxz, &.{"x"}));
}
test "no url file configured: skip, nothing runs" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, .{}, "h", true, false);
try std.testing.expectEqual(exit.Code.okay, try beat.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
test "missing file and bad url are blocked, no ping" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
var cfgv: cfgz.Conf = .{};
cfgv.beat_urlz_file = "beat.url";
cfgv.beat_chek_list = &.{};
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"curl"} }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try beat.comm(&ctxz, &.{}));
try urlFile(allo, home, "http://insecure\n");
try std.testing.expectEqual(exit.Code.bloc, try beat.comm(&ctxz, &.{}));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
test "alive only (empty check list): live pings the ok url; dry-run pings nothing" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try urlFile(allo, home, "https://hc-ping.com/abc\n");
var cfgv: cfgz.Conf = .{};
cfgv.beat_urlz_file = "beat.url";
cfgv.beat_chek_list = &.{};
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"curl"} }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const dry = make.make(allo, &buff.writer, &mck, cfgv, home, false, false);
try std.testing.expectEqual(exit.Code.okay, try beat.comm(&dry, &.{}));
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
try std.testing.expect(std.mem.indexOf(u8, buff.written(), "would send the ok ping") != null and std.mem.indexOf(u8, buff.written(), "hc-ping") == null);
var buf2: std.Io.Writer.Allocating = .init(allo);
const live = make.make(allo, &buf2.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try beat.comm(&live, &.{}));
try std.testing.expect(hasCall(&mck, "curl -fsS -m 10 --retry 2 https://hc-ping.com/abc") and !hasCall(&mck, "/fail"));
}
test "a fresh stamp pings ok, a stale or missing stamp pings /fail and exits 1" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try urlFile(allo, home, "https://hc-ping.com/abc\n");
var cfgv: cfgz.Conf = .{};
cfgv.beat_urlz_file = "beat.url";
cfgv.beat_chek_list = &.{"docs"};
cfgv.beat_ager_maxz = 3600;
var mck: mock.Mock = .{ .rule = &.{.{ .pref = &.{"curl"} }} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try beat.comm(&ctxz, &.{}));
try std.testing.expect(hasCall(&mck, "https://hc-ping.com/abc/fail") and std.mem.indexOf(u8, buff.written(), "never ran") != null);
try ctxz.stamPut("docs", .{ .when = make.NOWZ - 100, .okay = true, .note = "x" });
var mck2: mock.Mock = .{ .rule = &.{.{ .pref = &.{"curl"} }} };
var buf2: std.Io.Writer.Allocating = .init(allo);
const fresh = make.make(allo, &buf2.writer, &mck2, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.okay, try beat.comm(&fresh, &.{}));
try std.testing.expect(hasCall(&mck2, "curl -fsS -m 10 --retry 2 https://hc-ping.com/abc") and !hasCall(&mck2, "/fail"));
try ctxz.stamPut("docs", .{ .when = make.NOWZ - 7200, .okay = true, .note = "x" });
var mck3: mock.Mock = .{ .rule = &.{.{ .pref = &.{"curl"} }} };
var buf3: std.Io.Writer.Allocating = .init(allo);
const stale = make.make(allo, &buf3.writer, &mck3, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.fail, try beat.comm(&stale, &.{}));
try std.testing.expect(hasCall(&mck3, "/fail") and std.mem.indexOf(u8, buf3.written(), "stale: last good run 7200s ago, limit 3600s") != null);
}
test "curl absent blocks the ping" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const home = try make.homeOf(allo, &tmp);
try urlFile(allo, home, "https://hc-ping.com/abc\n");
var cfgv: cfgz.Conf = .{};
cfgv.beat_urlz_file = "beat.url";
cfgv.beat_chek_list = &.{};
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, home, true, false);
try std.testing.expectEqual(exit.Code.bloc, try beat.comm(&ctxz, &.{}));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
