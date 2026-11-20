// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-ctrl-args: flags, values, safety ladder, bad input
// Flo: parse argv samples > compare fields > bad forms
// I/O: string lists > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const args = @import("ct-ctrl-args.zig");
test "command, url and switches" { const got = try args.argsRead(&.{ "fetch", "https://a.com/", "--live", "--force", "--json" }); try std.testing.expectEqualStrings("fetch", got.cmdz); try std.testing.expectEqualStrings("https://a.com/", got.urlz); try std.testing.expect(got.live and got.forc and got.json); }
test "flags with values" { const got = try args.argsRead(&.{ "run", "--seed-file", "s.txt", "--sitemap", "https://a.com/", "--decl", "42", "--conf", "c.json" }); try std.testing.expectEqualStrings("s.txt", got.seed); try std.testing.expectEqualStrings("https://a.com/", got.smap); try std.testing.expectEqual(@as(u32, 42), got.decl); try std.testing.expectEqualStrings("c.json", got.conf); const exp = try args.argsRead(&.{ "export", "--format", "csv", "--out", "o.csv" }); try std.testing.expectEqualStrings("csv", exp.fmtz); try std.testing.expectEqualStrings("o.csv", exp.outz); }
test "defaults are dry-run, jsonl" { const got = try args.argsRead(&.{"status"}); try std.testing.expect(!got.live and !got.forc and !got.json); try std.testing.expectEqualStrings("jsonl", got.fmtz); }
test "force without live, both kill switches, missing values, unknown flags are refused" { try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "fetch", "u", "--force" })); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "kill", "--on", "--off" })); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "run", "--seed-file" })); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "run", "--decl", "abc" })); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "run", "--bogus" })); try std.testing.expectError(error.BadUsage, args.argsRead(&.{ "a", "b", "c" })); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
