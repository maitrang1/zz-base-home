// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for st-stor-file: atomic write, overwrite, caps
// Flo: tmp dir > write > read back > overwrite > check no .part
// I/O: bytes > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const file = @import("st-stor-file.zig");
fn rootGet(tmpz: *std.testing.TmpDir, buff: []u8, name: []const u8) ![]const u8 { return std.fmt.bufPrint(buff, ".zig-cache/tmp/{s}/{s}", .{ tmpz.sub_path, name }); }
test "write then read back, parent dirs created" { const allo = std.testing.allocator; var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [200]u8 = undefined; const path = try rootGet(&tmpz, &buff, "a/b/state.txt"); try file.fileAtom(allo, std.testing.io, path, "hello"); const back = try file.fileRead(allo, std.testing.io, path, 100); defer allo.free(back); try std.testing.expectEqualStrings("hello", back); try std.testing.expect(file.fileHas(std.testing.io, path)); }
test "overwrite replaces content and leaves no .part" { const allo = std.testing.allocator; var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [200]u8 = undefined; const path = try rootGet(&tmpz, &buff, "s.txt"); try file.fileAtom(allo, std.testing.io, path, "one"); try file.fileAtom(allo, std.testing.io, path, "two2"); const back = try file.fileRead(allo, std.testing.io, path, 100); defer allo.free(back); try std.testing.expectEqualStrings("two2", back); var pbuf: [220]u8 = undefined; const part = try std.fmt.bufPrint(&pbuf, "{s}.part", .{path}); try std.testing.expect(!file.fileHas(std.testing.io, part)); }
test "read over the cap fails, missing file fails" { const allo = std.testing.allocator; var tmpz = std.testing.tmpDir(.{}); defer tmpz.cleanup(); var buff: [200]u8 = undefined; const path = try rootGet(&tmpz, &buff, "big.txt"); try file.fileAtom(allo, std.testing.io, path, "0123456789"); try std.testing.expectError(error.StreamTooLong, file.fileRead(allo, std.testing.io, path, 5)); var nbuf: [200]u8 = undefined; const none = try rootGet(&tmpz, &nbuf, "none.txt"); try std.testing.expectError(error.FileNotFound, file.fileRead(allo, std.testing.io, none, 5)); try std.testing.expect(!file.fileHas(std.testing.io, none)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
