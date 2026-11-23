// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the whole-path boundary rules
// Flo: byte before > byte after > combined match check
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const boun = @import("ut-path-boun.zig");
test "before: start of text is fine" { try std.testing.expect(boun.okBefore(.fwds, "/a/old", 0)); }
test "before: name chars, dot and slashes block a plain match" {
try std.testing.expect(!boun.okBefore(.fwds, "x/a/old", 1));
try std.testing.expect(!boun.okBefore(.fwds, "1/a/old", 1));
try std.testing.expect(!boun.okBefore(.fwds, "_/a/old", 1));
try std.testing.expect(!boun.okBefore(.fwds, "-/a/old", 1));
try std.testing.expect(!boun.okBefore(.rela, "./../old", 2));
try std.testing.expect(!boun.okBefore(.fwds, ".old", 1));
try std.testing.expect(!boun.okBefore(.rela, "a/../old", 5));
try std.testing.expect(!boun.okBefore(.rela, "a\\..\\old", 5));
}
test "before: quotes, space, equals, colon and brackets allow a match" {
const chrs = "\"' =:([,;\t\n";
for (chrs) |chr| {
const text = [_]u8{ chr, '/', 'a' };
try std.testing.expect(boun.okBefore(.fwds, &text, 1));
}
}
test "before: a url form only needs a non-alphanumeric before it" {
try std.testing.expect(boun.okBefore(.urlz, "(file:///a", 1));
try std.testing.expect(boun.okBefore(.urlz, "/file:///a", 1));
try std.testing.expect(!boun.okBefore(.urlz, "xfile:///a", 1));
}
test "after: end of text and child separators are fine" {
try std.testing.expect(boun.okAfter("/a/old", 6));
try std.testing.expect(boun.okAfter("/a/old/x", 6));
try std.testing.expect(boun.okAfter("/a/old\\x", 6));
}
test "after: name chars block (old2, old_x, old-x)" {
try std.testing.expect(!boun.okAfter("/a/old2", 6));
try std.testing.expect(!boun.okAfter("/a/olde", 6));
try std.testing.expect(!boun.okAfter("/a/old_x", 6));
try std.testing.expect(!boun.okAfter("/a/old-x", 6));
}
test "after: a dot joined to a name char blocks, a sentence dot allows" {
try std.testing.expect(!boun.okAfter("/a/old.txt", 6));
try std.testing.expect(!boun.okAfter("/a/old._", 6));
try std.testing.expect(boun.okAfter("/a/old. next", 6));
try std.testing.expect(boun.okAfter("/a/old.", 6));
try std.testing.expect(boun.okAfter("/a/old..", 6));
}
test "after: quotes, space, semicolon, colon, brackets allow" {
const chrs = "\"' ;:)],\r\n\t";
for (chrs) |chr| {
const text = [_]u8{ 'o', chr };
try std.testing.expect(boun.okAfter(&text, 1));
}
}
test "okMatc needs both sides" {
try std.testing.expect(boun.okMatc(.fwds, "see /a/old now", 4, 6));
try std.testing.expect(!boun.okMatc(.fwds, "see x/a/old now", 5, 6));
try std.testing.expect(!boun.okMatc(.fwds, "see /a/old2 now", 4, 6));
try std.testing.expect(boun.okMatc(.fwds, "/a/old", 0, 6));
}
test "utf16: the unit before and after decide, by its low byte" {
const pat = "/\x00a\x00";
const ok = "x\x00 \x00" ++ pat ++ " \x00y\x00";
try std.testing.expect(boun.okMatc(.u16l, ok, 4, pat.len));
const bad_before = "x\x00" ++ pat;
try std.testing.expect(!boun.okMatc(.u16l, bad_before, 2, pat.len));
const bad_after = pat ++ "z\x00";
try std.testing.expect(!boun.okMatc(.u16l, bad_after, 0, pat.len));
try std.testing.expect(boun.okMatc(.u16l, pat, 0, pat.len));
}
test "utf16: a big unit (high byte set) is never a name char; sentence dot allowed, dot+name blocked" {
const pat = "/\x00a\x00";
try std.testing.expect(boun.okMatc(.u16l, pat ++ "\x00\x30", 0, pat.len));
try std.testing.expect(boun.okMatc(.u16l, pat ++ ".\x00 \x00", 0, pat.len));
try std.testing.expect(!boun.okMatc(.u16l, pat ++ ".\x00t\x00", 0, pat.len));
try std.testing.expect(boun.okMatc(.u16l, pat ++ "/\x00b\x00", 0, pat.len));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
