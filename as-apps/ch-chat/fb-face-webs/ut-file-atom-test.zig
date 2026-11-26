// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the whole-or-nothing file write
// Flo: temp dir > write twice > read back > no .part left
// I/O: temp dirs only
// Run: zig build test -Dfile=ut-file-atom-test.zig
// ===================================================================
const std = @import("std"); const atom = @import("ut-file-atom.zig");
const allo = std.testing.allocator;
test "put creates, then replaces, and leaves no part file" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const path = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}/a.json", .{tmpz.sub_path}); defer allo.free(path); try atom.put(allo, std.testing.io, path, "one"); try atom.put(allo, std.testing.io, path, "two2"); const got = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, path, allo, .limited(64)); defer allo.free(got); try std.testing.expectEqualStrings("two2", got); const part = try std.fmt.allocPrint(allo, "{s}.part", .{path}); defer allo.free(part); try std.testing.expectError(error.FileNotFound, std.Io.Dir.cwd().statFile(std.testing.io, part, .{})); }
test "a stale part file from a killed write never shows as the real file" { var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); const path = try std.fmt.allocPrint(allo, ".zig-cache/tmp/{s}/b.json", .{tmpz.sub_path}); defer allo.free(path); const part = try std.fmt.allocPrint(allo, "{s}.part", .{path}); defer allo.free(part); try std.Io.Dir.cwd().writeFile(std.testing.io, .{ .sub_path = part, .data = "half" }); try std.testing.expectError(error.FileNotFound, std.Io.Dir.cwd().statFile(std.testing.io, path, .{})); try atom.put(allo, std.testing.io, path, "full"); const got = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, path, allo, .limited(64)); defer allo.free(got); try std.testing.expectEqualStrings("full", got); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
