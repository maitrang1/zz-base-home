// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the notify channels
// Flo: file channel appends lines > unknown config is rejected > toast channel is never used in tests
// I/O: scratch folder (no OS popups, no leaks)
// Run: zig build test -Dfile=ru-noti-send-test.zig
// ===================================================================
const std = @import("std"); const noti = @import("ru-noti-send.zig"); const cfgz = @import("cf-conf-load.zig");
const allo = std.testing.allocator;
test "file channel appends one line per alert, keeps order" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{tmpz.sub_path}); defer allo.free(dir); var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); var conf: cfgz.Conf = .{}; conf.noti_chai_orde = &.{"file"}; try std.testing.expect(noti.send(allo, std.testing.io, aren.allocator(), conf, dir, 1000, "fb needs you: log in")); try std.testing.expect(noti.send(allo, std.testing.io, aren.allocator(), conf, dir, 2000, "fb stopped: wait 24 hours")); const pth = try std.fmt.allocPrint(allo, "{s}/alerts.txt", .{dir}); defer allo.free(pth); const txt = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, pth, allo, .limited(4096)); defer allo.free(txt); try std.testing.expectEqualStrings("1000 fb needs you: log in\n2000 fb stopped: wait 24 hours\n", txt); }
test "no channels means nothing is sent" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}", .{tmpz.sub_path}); defer allo.free(dir); var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); var conf: cfgz.Conf = .{}; conf.noti_chai_orde = &.{}; try std.testing.expect(!noti.send(allo, std.testing.io, aren.allocator(), conf, dir, 1, "x")); }
test "config only accepts known channels" { var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); try std.testing.expectError(error.BadConfig, cfgz.confParse(aren.allocator(), "{\"noti_chai_orde\":[\"sms\"]}")); _ = try cfgz.confParse(aren.allocator(), "{\"noti_chai_orde\":[\"file\"]}"); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
