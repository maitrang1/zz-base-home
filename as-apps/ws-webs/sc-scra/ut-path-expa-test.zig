// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ut-path-expa: tilde forms
// Flo: expand samples > compare
// I/O: path text > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const pexp = @import("ut-path-expa.zig");
fn chek(home: []const u8, path: []const u8, want: []const u8) !void { const gotz = try pexp.pathExpa(std.testing.allocator, home, path); defer std.testing.allocator.free(gotz); try std.testing.expectEqualStrings(want, gotz); }
test "tilde expands, plain paths stay" { const sepz = std.fs.path.sep_str; try chek("/h/me", "~/.zs-scra-data", "/h/me" ++ sepz ++ ".zs-scra-data"); try chek("/h/me", "~", "/h/me"); try chek("/h/me", "/abs/path", "/abs/path"); try chek("", "rela/path", "rela/path"); }
test "bad forms refused" { try std.testing.expectError(error.BadPath, pexp.pathExpa(std.testing.allocator, "/h", "~other/x")); try std.testing.expectError(error.BadPath, pexp.pathExpa(std.testing.allocator, "/h", "")); try std.testing.expectError(error.NoHome, pexp.pathExpa(std.testing.allocator, "", "~/x")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
