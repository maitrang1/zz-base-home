// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-ctrl-args: flags, values, safety ladder, bad input
// Flo: parse argv samples > compare fields > bad forms
// I/O: string lists > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const args = @import("ct-ctrl-args.zig");
test "command, url and switches" { const got2 = try args.argsRead(&.{ "fetch", "https://a.com/", "--live", "--force", "--json" }, std.testing.allocator); try std.testing.expectEqualStrings("fetch", got2.cmdz); try std.testing.expectEqualStrings("https://a.com/", got2.urlz); try std.testing.expect(got2.live and got2.forc and got2.json); }
test "flags with values" { const got2 = try args.argsRead(&.{ "run", "--seed-file", "s.txt", "--sitemap", "https://a.com/", "--decl", "42", "--conf", "c.json" }, std.testing.allocator); try std.testing.expectEqualStrings("s.txt", got2.seed); try std.testing.expectEqualStrings("https://a.com/", got2.smap); try std.testing.expectEqual(@as(u32, 42), got2.decl); try std.testing.expectEqualStrings("c.json", got2.conf); const expz = try args.argsRead(&.{ "export", "--format", "csv", "--out", "o.csv" }, std.testing.allocator); try std.testing.expectEqualStrings("csv", expz.fmtz); try std.testing.expectEqualStrings("o.csv", expz.outz); }
test "defaults are dry-run, jsonl" { const got2 = try args.argsRead(&.{"status"}, std.testing.allocator); try std.testing.expect(!got2.live and !got2.forc and !got2.json); try std.testing.expectEqualStrings("jsonl", got2.fmtz); }
test "force without live, both kill switches, missing values, unknown flags are refused" { try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "fetch", "u", "--force" }, std.testing.allocator)); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "kill", "--on", "--off" }, std.testing.allocator)); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "run", "--seed-file" }, std.testing.allocator)); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "run", "--decl", "abc" }, std.testing.allocator)); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "run", "--bogus" }, std.testing.allocator)); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "a", "b", "c" }, std.testing.allocator)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
