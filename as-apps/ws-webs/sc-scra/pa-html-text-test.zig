// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for pa-html-text: text, title, entities, hostile input
// Flo: run fixtures and nasty snippets > compare text
// I/O: HTML strings > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const html = @import("pa-html-text.zig"); const fixt = @import("te-fixt-html.zig");
const allo = std.testing.allocator;
fn text(srcz: []const u8, want: []const u8) !void { const gotz = try html.htmlText(allo, srcz); defer allo.free(gotz); try std.testing.expectEqualStrings(want, gotz); }
test "shop fixture: tags, script, style, comments, entities" { try text(fixt.shop, "Blue Widget\nA fine widget.\nShips \"fast\" & free A.\none\ntwo"); }
test "title is decoded and found case-insensitively" { const titl = (try html.htmlTitl(allo, fixt.shop)).?; defer allo.free(titl); try std.testing.expectEqualStrings("Blue Widget \xE2\x80\x93 Shop & Co", titl); const upzz = (try html.htmlTitl(allo, fixt.deny)).?; defer allo.free(upzz); try std.testing.expectEqualStrings("Access Denied", upzz); try std.testing.expect(try html.htmlTitl(allo, "<p>none</p>") == null); }
test "empty page has no text" { try text(fixt.emty, ""); try text("", ""); try text("   \n ", ""); }
test "unclosed and hostile markup does not crash or loop" { try text("<p>a<b", "a"); try text("<script>never closed", ""); try text("a < b & c", "a < b & c"); try text("<div attr=\"x>y\">ok</div>", "ok"); try text("&#xZZ; &#99999999999; &bogus; &amp", "&#xZZ; &#99999999999; &bogus; &amp"); try text("<!-- open comment", ""); }
test "plain text passes untouched, spaces collapse" { try text("hello    world\n\n  again", "hello world again"); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
