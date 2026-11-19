// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for static asset gzip
// Flo: gzip fixed text > decompress with std > assert smaller and equal
// I/O: repeated text (fake) > pass or fail
// ===================================================================
const std = @import("std"); const cach = @import("sv-stat-cach.zig"); const tszz = std.testing;
test "gzip round-trips through the std decompressor" { const gpaz = tszz.allocator; const srcz = "hello hello hello hello auto-task " ** 64; const gzzz = try cach.gzip(gpaz, srcz); defer gpaz.free(gzzz); try tszz.expect(gzzz.len < srcz.len); var inpt: std.Io.Reader = .fixed(gzzz); var wind: [std.compress.flate.max_window_len]u8 = undefined; var deco: std.compress.flate.Decompress = .init(&inpt, .gzip, &wind); const back = try deco.reader.allocRemaining(gpaz, .unlimited); defer gpaz.free(back); try tszz.expectEqualStrings(srcz, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
