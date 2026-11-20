// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for pa-pdfz-*: M10 gate, PDF fixtures to exact text
// Flo: build PDFs in code > pdfText > assert text, flags, typed errors, caps, fuzz
// I/O: generated PDFs > pass or fail (no leaks)
// Run: zig build test
// ===================================================================
const std = @import("std"); const pdft = @import("pa-pdfz-text.zig"); const fixt = @import("te-fixt-pdfz.zig");
const allo = std.testing.allocator;
fn runz(data: []const u8) !struct { text: []u8, pages: u32, ocrz: bool, aren: std.heap.ArenaAllocator } { var aren = std.heap.ArenaAllocator.init(allo); errdefer aren.deinit(); const res = try pdft.pdfText(allo, aren.allocator(), data); return .{ .text = try aren.allocator().dupe(u8, res.text), .pages = res.pages, .ocrz = res.ocrz, .aren = aren }; }
fn want(pages: []const []const u8, opt: fixt.Opt, expect: []const u8) !void { const pdf = try fixt.build(allo, pages, opt); defer allo.free(pdf); var got = try runz(pdf); defer got.aren.deinit(); try std.testing.expectEqualStrings(expect, got.text); try std.testing.expect(!got.ocrz); }
test "plain uncompressed page" { try want(&.{"BT /F1 12 Tf 72 700 Td (Hello PDF World) Tj ET"}, .{}, "Hello PDF World"); }
test "flate compressed streams" { try want(&.{"BT /F1 12 Tf 72 700 Td (Compressed text here) Tj ET"}, .{ .flate = true }, "Compressed text here"); }
test "catalog and pages inside an object stream" { try want(&.{"BT /F1 12 Tf 72 700 Td (From object stream) Tj ET"}, .{ .flate = true, .objs = true }, "From object stream"); }
test "ToUnicode CMap: bfchar and bfrange, two-byte codes" { try want(&.{"BT /F1 12 Tf 72 700 Td <00010002> Tj <000300040005> Tj ET"}, .{ .cmap = true }, "HiABC"); try want(&.{"BT /F1 12 Tf 72 700 Td <00010002> Tj ET"}, .{ .cmap = true, .flate = true }, "Hi"); }
test "lines, kerning gaps, escapes and octal" { try want(&.{"BT /F1 12 Tf 72 700 Td (Line one) Tj 0 -14 Td (Line two) Tj ET"}, .{}, "Line one\nLine two"); try want(&.{"BT /F1 12 Tf 72 700 Td [(Hel) -300 (lo) 10 (World)] TJ ET"}, .{}, "Hel loWorld"); try want(&.{"BT /F1 12 Tf 72 700 Td (a\\(b\\)\\101) Tj ET"}, .{}, "a(b)A"); try want(&.{"BT /F1 12 Tf 72 700 Td (one) Tj T* (two) ' ET"}, .{}, "one\ntwo"); }
test "pages come out in tree order, separated" { try want(&.{ "BT /F1 12 Tf 72 700 Td (First page) Tj ET", "BT /F1 12 Tf 72 700 Td (Second page) Tj ET" }, .{}, "First page\n\nSecond page"); }
test "no trailer root: fallback scans all Page objects" { try want(&.{"BT /F1 12 Tf 72 700 Td (Broken trailer) Tj ET"}, .{ .root = false }, "Broken trailer"); }
test "words on separate BT blocks at the same height stay on one line" { try want(&.{"BT /F1 12 Tf 72 700 Td (Hello) Tj ET BT /F1 12 Tf 120 700 Td (World) Tj ET"}, .{}, "Hello World"); }
test "encrypted file is a typed error" { const pdf = try fixt.build(allo, &.{"BT (x) Tj ET"}, .{ .enc = true }); defer allo.free(pdf); var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); try std.testing.expectError(error.Encrypted, pdft.pdfText(allo, aren.allocator(), pdf)); }
test "not a pdf and empty input are typed errors" { var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); try std.testing.expectError(error.BadPdf, pdft.pdfText(allo, aren.allocator(), "<html>hi</html>")); try std.testing.expectError(error.BadPdf, pdft.pdfText(allo, aren.allocator(), "")); try std.testing.expectError(error.BadPdf, pdft.pdfText(allo, aren.allocator(), "%PDF-1.4\nnothing else")); }
test "scanned page (image only) has no text layer: ocr flag set" { const pdf = try fixt.build(allo, &.{"q 612 0 0 792 0 0 cm /Im0 Do Q"}, .{}); defer allo.free(pdf); var got = try runz(pdf); defer got.aren.deinit(); try std.testing.expect(got.ocrz); try std.testing.expectEqual(@as(usize, 0), got.text.len); }
test "inflate bomb is stopped, no crash, no leak, no text" { const zero = try allo.alloc(u8, 20 << 20); defer allo.free(zero); @memset(zero, ' '); const pdf = try fixt.build(allo, &.{zero}, .{ .flate = true }); defer allo.free(pdf); var got = try runz(pdf); defer got.aren.deinit(); try std.testing.expect(got.ocrz); }
test "fuzz: 1000 mutated PDFs stay safe" { const pdf = try fixt.build(allo, &.{ "BT /F1 12 Tf 72 700 Td (Fuzz target text) Tj ET", "BT /F1 12 Tf 72 700 Td <00010002> Tj ET" }, .{ .flate = true, .objs = true, .cmap = true }); defer allo.free(pdf); var prng = std.Random.DefaultPrng.init(0x5eed); const rnd = prng.random(); var cnt: usize = 0; while (cnt < 1000) : (cnt += 1) { const mut = try allo.dupe(u8, pdf); defer allo.free(mut); const flips = rnd.intRangeAtMost(usize, 1, 12); var fix: usize = 0; while (fix < flips) : (fix += 1) mut[rnd.uintLessThan(usize, mut.len)] = rnd.int(u8); const lenz = if (rnd.boolean()) mut.len else rnd.uintLessThan(usize, mut.len) + 1; var aren = std.heap.ArenaAllocator.init(allo); defer aren.deinit(); _ = pdft.pdfText(allo, aren.allocator(), mut[0..lenz]) catch {}; } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
