// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for wo-work-mode conf: valid JSON that round-trips
// Flo: run conf with a changed value > parse the output back > compare
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const comm = @import("ct-comm-conf.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const exit = @import("ct-exit-code.zig");
test "conf prints the live settings as JSON that parses back identically" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var cfgv: cfgz.Conf = .{};
cfgv.dril_rtoz_maxz = 123;
cfgv.wipz_remo_list = &.{ "orig", "mirr" };
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
const ctxz = make.make(allo, &buff.writer, &mck, cfgv, "h", false, false);
try std.testing.expectEqual(exit.Code.okay, try comm.comm(&ctxz, &.{}));
const back = try cfgz.confParse(allo, buff.written());
try std.testing.expectEqual(@as(i64, 123), back.dril_rtoz_maxz);
try std.testing.expectEqual(@as(usize, 2), back.wipz_remo_list.len);
try std.testing.expectEqualStrings("mirr", back.wipz_remo_list[1]);
try std.testing.expectEqualStrings(cfgv.hook_path_main, back.hook_path_main);
try std.testing.expectEqual(cfgv.kill_step_list.len, back.kill_step_list.len);
try std.testing.expectEqual(@as(usize, 0), mck.call.items.len);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
