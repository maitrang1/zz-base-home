// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for case folding and substring match
// Flo: ASCII > Vietnamese caps > length kept > invalid bytes survive > match any
// I/O: text samples > asserts
// Run: zig build test -Dfile=ut-text-fold-test.zig
// ===================================================================
const std = @import("std"); const fold = @import("ut-text-fold.zig");
test "ascii and Vietnamese capitals fold to lowercase, same byte length" { var buf: [64]u8 = undefined; const out = fold.fold(&buf, "ĐĂNG NHẬP Facebook ƠƯ"); try std.testing.expectEqualStrings("đăng nhập facebook ơư", out); const src = "Bạn Tạm Thời"; try std.testing.expectEqual(src.len, fold.fold(&buf, src).len); }
test "invalid utf8 and tiny buffers do not crash" { var buf: [4]u8 = undefined; const out = fold.fold(&buf, "AB\xff\xfeCDEF"); try std.testing.expect(out.len <= 4); var big: [16]u8 = undefined; const o2 = fold.fold(&big, "A\xffB"); try std.testing.expectEqual(@as(usize, 3), o2.len); }
test "matchAny is case-insensitive and ignores empty needles" { const allo = std.testing.allocator; try std.testing.expect(try fold.matchAny(allo, "Mark As Sold - Red bike", &.{ "nope", "mark as sold" })); try std.testing.expect(try fold.matchAny(allo, "Đánh dấu là đã bán", &.{"ĐÁNH DẤU"})); try std.testing.expect(!try fold.matchAny(allo, "abc", &.{""})); try std.testing.expect(!try fold.matchAny(allo, "abc", &.{})); }
test "hasAny on folded text" { try std.testing.expect(fold.hasAny("hello world", &.{ "zzz", "world" })); try std.testing.expect(!fold.hasAny("hello", &.{ "", "bye" })); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
