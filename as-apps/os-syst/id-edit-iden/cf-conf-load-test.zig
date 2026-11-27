// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the config loader
// Flo: defaults for missing keys > override > unknown keys ignored > shipped file equals the defaults
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\id-edit-iden\build.zig
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
test "empty object gives every default" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const conf = try cfgz.confParse(arena.allocator(), "{}");
try std.testing.expect(conf.scan_docs_on);
try std.testing.expectEqual(@as(u32, 20), conf.hubz_wait_seco);
try std.testing.expectEqualStrings("ac-auto-task", conf.hubz_dirz);
}
test "override and unknown keys" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const conf = try cfgz.confParse(arena.allocator(), "{\"scan_docs_on\":false,\"hubz_wait_seco\":3,\"zzzz\":1}");
try std.testing.expect(!conf.scan_docs_on);
try std.testing.expectEqual(@as(u32, 3), conf.hubz_wait_seco);
}
test "bad json is an error" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
try std.testing.expect(std.meta.isError(cfgz.confParse(arena.allocator(), "{nope")));
}
test "shipped aa-conf-main.json equals the built-in defaults" {
var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arena.deinit();
const allo = arena.allocator();
const data = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, "aa-conf-main.json", allo, .limited(1 << 20));
const shipped = try cfgz.confParse(allo, data);
const dflt: cfgz.Conf = .{};
inline for (@typeInfo(cfgz.Conf).@"struct".field_names) |name| {
const left = @field(shipped, name);
const righ = @field(dflt, name);
const Tz = @TypeOf(left);
if (Tz == []const u8) try std.testing.expectEqualStrings(righ, left)
else if (Tz == []const []const u8) {
try std.testing.expectEqual(righ.len, left.len);
for (righ, left) |rt, lt| try std.testing.expectEqualStrings(rt, lt);
} else try std.testing.expectEqual(righ, left);
}
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
