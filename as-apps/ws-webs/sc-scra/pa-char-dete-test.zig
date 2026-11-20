// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for pa-char-dete: detect order, conversions
// Flo: detect from header/meta/BOM > convert samples > assert UTF-8 bytes
// I/O: bytes > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const cset = @import("pa-char-dete.zig");
fn conv(ctyp: []const u8, body: []const u8, want: []const u8) !void { const outp = try cset.utf8Conv(std.testing.allocator, cset.charFind(ctyp, body), body); defer std.testing.allocator.free(outp); try std.testing.expectEqualStrings(want, outp); }
test "detect order: BOM, header, meta, default" { try std.testing.expectEqual(cset.Cset.utf8, cset.charFind("text/html; charset=iso-8859-1", "\xEF\xBB\xBFhi")); try std.testing.expectEqual(cset.Cset.w1252, cset.charFind("text/html; charset=ISO-8859-1", "x")); try std.testing.expectEqual(cset.Cset.w1252, cset.charFind("text/html", "<meta charset=\"windows-1252\">")); try std.testing.expectEqual(cset.Cset.w1252, cset.charFind("", "<meta http-equiv=Content-Type content='text/html; charset=latin1'>")); try std.testing.expectEqual(cset.Cset.utf8, cset.charFind("", "<html>")); try std.testing.expectEqual(cset.Cset.unkn, cset.charFind("text/html; charset=shift_jis", "x")); try std.testing.expectEqual(cset.Cset.utf16le, cset.charFind("", "\xFF\xFEa\x00")); }
test "latin1 and cp1252 become UTF-8" { try conv("text/html; charset=iso-8859-1", "caf\xE9", "caf\xC3\xA9"); try conv("text/html; charset=windows-1252", "\x80 \x93q\x94", "\xE2\x82\xAC \xE2\x80\x9Cq\xE2\x80\x9D"); }
test "utf8 passes, BOM stripped, bad bytes replaced" { try conv("", "h\xC3\xA9llo", "h\xC3\xA9llo"); try conv("", "\xEF\xBB\xBFab", "ab"); try conv("", "a\xFFb", "a\xEF\xBF\xBDb"); try conv("", "a\xC3", "a\xEF\xBF\xBD"); try conv("", "a\xE2\x82", "a\xEF\xBF\xBD\xEF\xBF\xBD"); try conv("", "a\xC0\x80b", "a\xEF\xBF\xBD\xEF\xBF\xBDb"); }
test "utf16 le and be convert" { try conv("", "\xFF\xFEh\x00\xE9\x00", "h\xC3\xA9"); try conv("", "\xFE\xFF\x00h\x00\xE9", "h\xC3\xA9"); try std.testing.expectError(error.CharBad, cset.utf8Conv(std.testing.allocator, .utf16le, "\x00\xD8")); }
test "unknown charset: valid utf8 ok, else refused" { try conv("charset=shift_jis", "abc", "abc"); try std.testing.expectError(error.CharUnsupported, cset.utf8Conv(std.testing.allocator, .unkn, "\x82\xA0")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
