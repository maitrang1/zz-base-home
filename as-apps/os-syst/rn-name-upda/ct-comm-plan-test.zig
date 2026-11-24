// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for rn plan: checks, output, exit codes, no writes
// Flo: pair checks > text run > json run > flagged skips > files untouched
// I/O: tmp dir fake machine > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const plan = @import("ct-comm-plan.zig");
const exit = @import("ct-exit-code.zig");
const cfgz = @import("cf-conf-load.zig");
const fake = @import("te-mach-fake.zig");
const make = @import("te-ctxz-make.zig");
fn args(allo: std.mem.Allocator, root: []const u8, old: []const u8, new: []const u8) ![]const []const u8 { return allo.dupe([]const u8, &.{ try std.fmt.allocPrint(allo, "{s}/{s}", .{ root, old }), try std.fmt.allocPrint(allo, "{s}/{s}", .{ root, new }) }); }
test "pair checks: missing old, existing new, other parent, same name" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "p/taken/x.txt", "x");
try fake.dirz(&tmp, "q");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const p = try std.fmt.allocPrint(allo, "{s}/p", .{root});
const oldp = try std.fmt.allocPrint(allo, "{s}/old", .{p});
try std.testing.expectEqual(plan.Bad.none, plan.checkPair(&ctxz, oldp, try std.fmt.allocPrint(allo, "{s}/fresh", .{p})));
try std.testing.expectEqual(plan.Bad.oldz_miss, plan.checkPair(&ctxz, try std.fmt.allocPrint(allo, "{s}/ghost", .{p}), try std.fmt.allocPrint(allo, "{s}/fresh", .{p})));
try std.testing.expectEqual(plan.Bad.newz_exis, plan.checkPair(&ctxz, oldp, try std.fmt.allocPrint(allo, "{s}/taken", .{p})));
try std.testing.expectEqual(plan.Bad.sibl_only, plan.checkPair(&ctxz, oldp, try std.fmt.allocPrint(allo, "{s}/q/old2", .{root})));
try std.testing.expectEqual(plan.Bad.same_name, plan.checkPair(&ctxz, oldp, oldp));
}
test "case-only rename passes the pair check on every OS" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const got = plan.checkPair(&ctxz, try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), try std.fmt.allocPrint(allo, "{s}/p/OLD", .{root}));
try std.testing.expectEqual(plan.Bad.none, got);
}
test "text run: summary line, item lines, exit okay when nothing is flagged" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "p/doc/a.md", try std.fmt.allocPrint(allo, "ref {s}/p/old ok\n", .{root}));
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const code = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
try std.testing.expectEqual(exit.Code.okay, code);
const outz = aw.written();
try std.testing.expect(std.mem.indexOf(u8, outz, "apply 1 · skip 0 (comp 0, enco 0)") != null);
try std.testing.expect(std.mem.indexOf(u8, outz, "do   safe ") != null);
try std.testing.expect(std.mem.indexOf(u8, outz, "p/doc/a.md:1 fwds") != null);
}
test "a flagged bare name gives exit 3 and a skip line" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "p/n.txt", "the old one\n");
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const code = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
try std.testing.expectEqual(exit.Code.find, code);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "apply 0 · skip 1 (comp 1, enco 0)") != null);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "skip comp ") != null);
}
test "flipping skip_comp_part makes the bare name an apply item and exit okay" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "p/n.txt", "the old one\n");
var conf: cfgz.Conf = .{};
conf.skip_comp_part = false;
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
const code = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
try std.testing.expectEqual(exit.Code.okay, code);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "apply 1 · skip 0") != null);
}
test "json run parses and carries the items" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "p/doc/a.md", try std.fmt.allocPrint(allo, "ref {s}/p/old\n", .{root}));
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, true);
_ = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
const parsed = try std.json.parseFromSliceLeaky(plan.Outz, allo, aw.written(), .{ .ignore_unknown_fields = true });
try std.testing.expectEqual(@as(usize, 1), parsed.items.len);
try std.testing.expectEqual(@as(usize, 1), parsed.summ.appl);
try std.testing.expect(std.mem.endsWith(u8, parsed.new, "p/new"));
}
test "plan writes nothing: files stay byte-identical" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
const body = try std.fmt.allocPrint(allo, "ref {s}/p/old\n", .{root});
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "p/doc/a.md", body);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
_ = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
try std.testing.expectEqualStrings(body, try fake.readz(allo, &tmp, "p/doc/a.md"));
try std.testing.expectEqualStrings("x", try fake.readz(allo, &tmp, "p/old/x.txt"));
try std.testing.expectError(error.FileNotFound, tmp.dir.statFile(std.testing.io, "p/new", .{}));
}
test "the data dir is never scanned" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
try fake.putz(&tmp, "zz-tena/as-apps/os-syst/rn-name-upda/jour.txt", try std.fmt.allocPrint(allo, "{s}/p/old\n", .{root}));
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
const code = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
try std.testing.expectEqual(exit.Code.okay, code);
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "apply 0 · skip 0") != null);
}
test "a failed check returns fail; wrong arg count is a usage error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, .{}, false);
try std.testing.expectEqual(exit.Code.fail, try plan.comm(&ctxz, try args(allo, root, "ghost", "new")));
try std.testing.expectError(exit.Erro.Usag, plan.comm(&ctxz, &.{"only-one"}));
try std.testing.expectError(exit.Erro.Usag, plan.comm(&ctxz, &.{}));
}
test "long lists are cut at plan_line_maxz in text mode" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var tmp = std.testing.tmpDir(.{});
defer tmp.cleanup();
const root = try fake.rootOf(allo, &tmp);
try fake.putz(&tmp, "p/old/x.txt", "x");
const body = try std.fmt.allocPrint(allo, "{s}/p/old\n{s}/p/old\n{s}/p/old\n", .{ root, root, root });
try fake.putz(&tmp, "p/doc/a.md", body);
var conf: cfgz.Conf = .{};
conf.plan_line_maxz = 1;
var aw: std.Io.Writer.Allocating = .init(allo);
const ctxz = try make.make(allo, &aw.writer, root, conf, false);
_ = try plan.comm(&ctxz, try args(allo, root, "p/old", "p/new"));
try std.testing.expect(std.mem.indexOf(u8, aw.written(), "… 2 more (use --json)") != null);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
