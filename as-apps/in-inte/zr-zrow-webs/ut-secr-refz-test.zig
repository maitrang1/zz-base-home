// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the saved login file
// Flo: save into a scratch folder > load back > missing, empty and garbage files give NoSecret
// I/O: scratch folder (test) > pass or fail
// Run: cd E:\zz-base-home\as-apps\in-inte\zr-zrow-webs && zig build test -Dfile=ut-secr-refz-test.zig
// ===================================================================
const std = @import("std"); const secr = @import("ut-secr-refz.zig");
fn dirOf(aren: std.mem.Allocator, tmpz: *std.testing.TmpDir) ![]u8 { return std.fmt.allocPrint(aren, ".zig-cache/tmp/{s}/secr", .{tmpz.sub_path}); }
test "save then load gives the same login" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try dirOf(aren.allocator(), &tmpz); try secr.credSave(std.testing.io, aren.allocator(), dir, "me@example.com", "p@ss \"quoted\" \\ w0rd"); const cred = try secr.credLoad(aren.allocator(), std.testing.io, dir); try std.testing.expectEqualStrings("me@example.com", cred.user); try std.testing.expectEqualStrings("p@ss \"quoted\" \\ w0rd", cred.pass); }
test "missing, empty and garbage files give NoSecret" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const dir = try dirOf(aren.allocator(), &tmpz); try std.testing.expectError(error.NoSecret, secr.credLoad(aren.allocator(), std.testing.io, dir)); try secr.credSave(std.testing.io, aren.allocator(), dir, "", ""); try std.testing.expectError(error.NoSecret, secr.credLoad(aren.allocator(), std.testing.io, dir)); try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = try std.fs.path.join(aren.allocator(), &.{ dir, "zr-login.json" }), .data = "not json" }); try std.testing.expectError(error.NoSecret, secr.credLoad(aren.allocator(), std.testing.io, dir)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
