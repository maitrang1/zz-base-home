// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the hub id check (mock curl)
// Flo: parse ids > down hub = skip > reload seen = okay > old id still listed = bad > armErrors up = bad
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const hz = @import("sy-hubz-chec.zig");
const tk = @import("ut-iden-toke.zig");
const fk = @import("te-fake-repo.zig");
const tc = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const osys = @import("ut-osys-adap.zig");
const CURL = if (osys.wind) "curl.exe" else "curl";
const OLDZ = "{\"ok\":true,\"fileOk\":true,\"armErrorCount\":0,\"tasks\":[{\"id\":\"puls-15mi\",\"ids\":[\"fb-watc\",\"cicd-stat\"],\"plus\":[\"y\",[8]]}]}";
const NEWZ = "{\"ok\":true,\"fileOk\":true,\"armErrorCount\":0,\"tasks\":[{\"id\":\"puls-15mi\",\"ids\":[\"fb-watc\",\"cics-stat\"]}]}";
const BADZ = "{\"ok\":true,\"fileOk\":true,\"armErrorCount\":2,\"tasks\":[{\"id\":\"puls-15mi\",\"ids\":[\"fb-watc\",\"cics-stat\"]}]}";
const PAIRS = [_]tk.Pair{.{ .old = "cicd-stat", .new = "cics-stat" }};
fn ctxOf(arena: *std.heap.ArenaAllocator, tmp: *std.testing.TmpDir, rules: []const mock.Rule, mck: *mock.Mock, wrtr: *std.Io.Writer.Allocating) !@import("ct-ctrl-ctxz.zig").Ctxz {
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
mck.* = .{ .rule = rules };
wrtr.* = .init(allo);
return tc.make(allo, &wrtr.writer, fake, .{}, mck);
}
test "parse: job ids and chain steps, unknown fields ignored, ok false = down" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const sna = try hz.parse(arena.allocator(), OLDZ);
try std.testing.expect(sna.up and sna.fileok);
try std.testing.expect(hz.has(sna, "cicd-stat") and hz.has(sna, "puls-15mi") and !hz.has(sna, "x"));
const dwn = try hz.parse(arena.allocator(), "{\"error\":\"forbidden\"}");
try std.testing.expect(!dwn.up);
try std.testing.expect(std.meta.isError(hz.parse(arena.allocator(), "<html>")));
}
test "hub down (curl fails): snap is down and check skips" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
var mck: mock.Mock = undefined;
var wrtr: std.Io.Writer.Allocating = undefined;
const ctxz = try ctxOf(&arena, &tmp, &.{.{ .pref = &.{CURL}, .code = 7 }}, &mck, &wrtr);
const sna = hz.snap(&ctxz, 4999);
try std.testing.expect(!sna.up);
try std.testing.expectEqual(hz.State.skip, hz.check(&ctxz, 4999, sna, &PAIRS).state);
}
test "curl missing: down, no crash" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
var mck: mock.Mock = undefined;
var wrtr: std.Io.Writer.Allocating = undefined;
const ctxz = try ctxOf(&arena, &tmp, &.{.{ .pref = &.{CURL}, .absn = true }}, &mck, &wrtr);
try std.testing.expect(!hz.snap(&ctxz, 4999).up);
}
test "reload seen: the new id is listed, the old one is gone" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
var mck: mock.Mock = undefined;
var wrtr: std.Io.Writer.Allocating = undefined;
const ctxz = try ctxOf(&arena, &tmp, &.{ .{ .pref = &.{CURL}, .outz = OLDZ, .maxz = 1 }, .{ .pref = &.{CURL}, .outz = NEWZ } }, &mck, &wrtr);
const before = hz.snap(&ctxz, 4999);
try std.testing.expect(before.up);
const resu = hz.check(&ctxz, 4999, before, &PAIRS);
try std.testing.expectEqual(hz.State.okay, resu.state);
}
test "old id still listed after the wait: bad with the id in the note" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
var mck: mock.Mock = undefined;
var wrtr: std.Io.Writer.Allocating = undefined;
const ctxz = try ctxOf(&arena, &tmp, &.{.{ .pref = &.{CURL}, .outz = OLDZ }}, &mck, &wrtr);
const before = hz.snap(&ctxz, 4999);
const resu = hz.check(&ctxz, 4999, before, &PAIRS);
try std.testing.expectEqual(hz.State.bad, resu.state);
try std.testing.expect(std.mem.indexOf(u8, resu.note, "cicd-stat") != null);
}
test "armErrorCount going up is bad even when ids look right" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
var mck: mock.Mock = undefined;
var wrtr: std.Io.Writer.Allocating = undefined;
const ctxz = try ctxOf(&arena, &tmp, &.{ .{ .pref = &.{CURL}, .outz = OLDZ, .maxz = 1 }, .{ .pref = &.{CURL}, .outz = BADZ } }, &mck, &wrtr);
const before = hz.snap(&ctxz, 4999);
try std.testing.expectEqual(hz.State.bad, hz.check(&ctxz, 4999, before, &PAIRS).state);
}
test "an id the hub never had (other device file) is not required" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
var mck: mock.Mock = undefined;
var wrtr: std.Io.Writer.Allocating = undefined;
const ctxz = try ctxOf(&arena, &tmp, &.{.{ .pref = &.{CURL}, .outz = OLDZ }}, &mck, &wrtr);
const before = hz.snap(&ctxz, 4999);
const only = [_]tk.Pair{.{ .old = "zzzz-only", .new = "zzzz-new" }};
try std.testing.expectEqual(hz.State.okay, hz.check(&ctxz, 4999, before, &only).state);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
