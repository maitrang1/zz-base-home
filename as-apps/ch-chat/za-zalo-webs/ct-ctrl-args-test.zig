// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-ctrl-args: ladder flags, words, errors
// Flo: feed argv > assert Args or error
// I/O: strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const targ = @import("ct-ctrl-args.zig"); const T = std.testing;
fn pz(argv: []const []const u8) !targ.Args { return targ.parse(T.allocator, argv); }
test "no args means help in dry mode" { const arg = try targ.parse(T.allocator, &.{}); try T.expectEqualStrings("help", arg.cmd); try T.expect(arg.mode == .dry); try T.expect(!arg.json and !arg.mock); }
test "words after the command stay in order, flags can sit anywhere" { var aren = std.heap.ArenaAllocator.init(T.allocator); defer aren.deinit(); const arg = try targ.parse(aren.allocator(), &.{ "run", "--json", "send", "Mom", "--dry", "hi there" }); try T.expectEqualStrings("run", arg.cmd); try T.expectEqual(@as(usize, 3), arg.rest.len); try T.expectEqualStrings("hi there", arg.rest[2]); try T.expect(arg.json and arg.mode == .dry); }
test "ladder: read, dry default, live, live plus force" { var aren = std.heap.ArenaAllocator.init(T.allocator); defer aren.deinit(); try T.expect((try targ.parse(aren.allocator(), &.{ "run", "--read" })).mode == .read); try T.expect((try targ.parse(aren.allocator(), &.{"run"})).mode == .dry); try T.expect((try targ.parse(aren.allocator(), &.{ "run", "--live" })).mode == .live); try T.expect((try targ.parse(aren.allocator(), &.{ "run", "--live", "--force" })).mode == .force); }
test "force alone and read with live are usage errors" { var aren = std.heap.ArenaAllocator.init(T.allocator); defer aren.deinit(); try T.expectError(error.BadUsage, targ.parse(aren.allocator(), &.{ "run", "--force" })); try T.expectError(error.BadUsage, targ.parse(aren.allocator(), &.{ "run", "--read", "--live" })); }
test "unknown flag and dangling --conf are usage errors, conf value is taken" { var aren = std.heap.ArenaAllocator.init(T.allocator); defer aren.deinit(); try T.expectError(error.BadUsage, targ.parse(aren.allocator(), &.{ "run", "--nope" })); try T.expectError(error.BadUsage, targ.parse(aren.allocator(), &.{ "run", "--conf" })); const arg = try targ.parse(aren.allocator(), &.{ "status", "--conf", "x.json", "--mock" }); try T.expectEqualStrings("x.json", arg.conf); try T.expect(arg.mock); try T.expectEqual(@as(usize, 0), arg.rest.len); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
