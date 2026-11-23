// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for label packs
// Flo: built-in keys have English + Vietnamese > older config keys still win > owner override wins > unknown key is empty
// I/O: keys > label lists (no leaks)
// Run: zig build test -Dfile=ut-loca-pack-test.zig
// ===================================================================
const std = @import("std"); const pack = @import("ut-loca-pack.zig"); const cfgz = @import("cf-conf-load.zig");
fn hasLab(labs: []const []const u8, want: []const u8) bool { for (labs) |lb| if (std.mem.eql(u8, lb, want)) return true; return false; }
test "every built-in key has an English name and a Vietnamese name (non-ASCII)" { for (pack.PACK) |ent| { try std.testing.expect(ent.labs.len >= 2); var viet = false; var eng = false; for (ent.labs) |lb| { var asc = true; for (lb) |chr| { if (chr >= 0x80) asc = false; } if (asc) eng = true else viet = true; } try std.testing.expect(viet and eng); } }
test "keys are unique and 4-letter words" { for (pack.PACK, 0..) |ent, ix| { try std.testing.expectEqual(@as(usize, 9), ent.key.len); try std.testing.expectEqual(@as(u8, '_'), ent.key[4]); for (pack.PACK[ix + 1 ..]) |oth| try std.testing.expect(!std.mem.eql(u8, ent.key, oth.key)); } }
test "older config lists are reachable by key and owner override wins" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const conf = try cfgz.confParse(aren.allocator(), "{\"labl_over\":{\"popu_dism\":[\"Nope\"],\"post_open\":[\"Compose\"]}}"); try std.testing.expectEqualStrings("Nope", pack.lab(conf, "popu_dism")[0]); try std.testing.expectEqualStrings("Compose", pack.lab(conf, "post_open")[0]); const dflt: cfgz.Conf = .{}; try std.testing.expect(hasLab(pack.lab(dflt, "post_open"), "Create a post")); try std.testing.expect(hasLab(pack.lab(dflt, "frie_addz"), "Thêm bạn bè")); }
test "unknown key is empty; known() works" { const conf: cfgz.Conf = .{}; try std.testing.expectEqual(@as(usize, 0), pack.lab(conf, "zzzz_zzzz").len); try std.testing.expect(pack.known("mark_next")); try std.testing.expect(!pack.known("zzzz_zzzz")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
