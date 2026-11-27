// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the job-file and dispatcher readers
// Flo: parse rows > list files > id lookups > callable ids > unresolved ids
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const jz = @import("tk-jobz-read.zig");
const cfgz = @import("cf-conf-load.zig");
const fk = @import("te-fake-repo.zig");
test "parse: ids, run, unknown fields ignored, bad json errors" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const rows = try jz.parse(arena.allocator(), "[{\"id\":\"a\",\"ids\":[\"x\",\"y\"],\"zzz\":{\"q\":1}},{\"id\":\"b\",\"run\":\"echo\"}]");
try std.testing.expectEqual(@as(usize, 2), rows.len);
try std.testing.expectEqual(@as(usize, 2), rows[0].ids.?.len);
try std.testing.expectEqualStrings("echo", rows[1].run.?);
try std.testing.expect(std.meta.isError(jz.parse(arena.allocator(), "[{")));
}
test "files, lookups, callables on the fake repo" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
const conf: cfgz.Conf = .{};
const jobs = try jz.loadAll(allo, std.testing.io, fake.repo, conf);
try std.testing.expectEqual(@as(usize, 2), jobs.len);
try std.testing.expect(std.mem.endsWith(u8, jobs[0].file, "aa-auto-task-li01.json"));
try std.testing.expect(jz.hasIden(jobs, "cicd-stat"));
try std.testing.expect(jz.hasIden(jobs, "puls-15mi"));
try std.testing.expect(!jz.hasIden(jobs, "cicd-stat2"));
try std.testing.expect(jz.isJobId(jobs, "once-aday"));
try std.testing.expect(!jz.isJobId(jobs, "cicd-stat"));
const cal = try jz.calls(allo, jobs);
try std.testing.expectEqual(@as(usize, 6), cal.len);
}
test "unresolved: all known, then one missing from both dispatchers" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
const conf: cfgz.Conf = .{};
const none = try jz.unresolved(allo, std.testing.io, fake.repo, conf, &.{ "fb-watc", "cicd-stat", "scra-sync" });
try std.testing.expectEqual(@as(usize, 1), none.len);
try std.testing.expectEqualStrings("scra-sync", none[0]);
const clean = try jz.unresolved(allo, std.testing.io, fake.repo, conf, &.{ "fb-watc", "home-beat" });
try std.testing.expectEqual(@as(usize, 0), clean.len);
}
test "a missing dispatcher file means everything is unresolved, no crash" {
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const fake = try fk.seed(allo, std.testing.io, try fk.tmpPath(allo, &tmp.sub_path));
var conf: cfgz.Conf = .{};
conf.disp_file_list = &.{"nope/none.bat"};
const outz = try jz.unresolved(allo, std.testing.io, fake.repo, conf, &.{"fb-watc"});
try std.testing.expectEqual(@as(usize, 1), outz.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
