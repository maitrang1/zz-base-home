// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for config defaults, JSON file and skip keys
// Flo: defaults = file > partial override > unknown keys > bad path > all skip keys default true
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const filz = @embedFile("aa-conf-main.json");
test "built-in defaults equal aa-conf-main.json" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const fromFile = try cfgz.confParse(allo, filz);
const dflt: cfgz.Conf = .{};
const left = try std.json.Stringify.valueAlloc(allo, fromFile, .{});
const righ = try std.json.Stringify.valueAlloc(allo, dflt, .{});
try std.testing.expectEqualStrings(righ, left);
}
test "every skip key defaults to true except enco_vari (D12)" {
const dflt: cfgz.Conf = .{};
try std.testing.expect(dflt.skip_bina and dflt.skip_arch and dflt.skip_sign_hash and dflt.skip_othe_user);
try std.testing.expect(dflt.skip_syst_owne and dflt.skip_runn_proc and dflt.skip_sync_remo and dflt.skip_pack_mana);
try std.testing.expect(dflt.skip_comp_part and dflt.skip_urls_exte and dflt.skip_gitz_hist);
try std.testing.expect(!dflt.skip_enco_vari);
}
test "a partial file overrides only what it names" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const conf = try cfgz.confParse(arna.allocator(), "{\"skip_comp_part\": false, \"scan_maxz\": 7}");
try std.testing.expect(!conf.skip_comp_part);
try std.testing.expect(conf.skip_gitz_hist);
try std.testing.expectEqual(@as(u64, 7), conf.scan_maxz);
try std.testing.expectEqual(@as(u32, 96), conf.scan_deep);
}
test "unknown keys are ignored, bad JSON is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const conf = try cfgz.confParse(arna.allocator(), "{\"zzzz_none\": 1}");
try std.testing.expect(conf.skip_bina);
try std.testing.expectError(error.SyntaxError, cfgz.confParse(arna.allocator(), "{not json"));
}
test "an explicit missing path is an error" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectError(error.FileNotFound, cfgz.confLoad(arna.allocator(), std.testing.io, ".zig-cache/no-such-conf.json"));
}
test "config is looked up next to the exe first, then the app root above zig-out/bin, then repo-relative; never the bare cwd" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const cand = try cfgz.candList(arna.allocator(), "X/rn/zig-out/bin");
try std.testing.expectEqual(@as(usize, 3), cand.len);
try std.testing.expect(std.mem.startsWith(u8, cand[0], "X"));
try std.testing.expect(std.mem.endsWith(u8, cand[0], "aa-conf-main.json"));
try std.testing.expect(std.mem.indexOf(u8, cand[1], "..") != null);
try std.testing.expectEqualStrings("as-apps/os-syst/rn-name-upda/aa-conf-main.json", cand[2]);
const none = try cfgz.candList(arna.allocator(), null);
try std.testing.expectEqual(@as(usize, 1), none.len);
}
test "default skip list holds the pseudo dirs" {
const dflt: cfgz.Conf = .{};
var hasProc = false;
var hasGit = false;
for (dflt.scan_skip_list) |item| { if (std.mem.eql(u8, item, "/proc")) hasProc = true; if (std.mem.eql(u8, item, ".git/objects")) hasGit = true; }
try std.testing.expect(hasProc and hasGit);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
