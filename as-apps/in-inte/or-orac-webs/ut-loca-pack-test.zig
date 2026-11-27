// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the label registry and path table
// Flo: check key shape, uniqueness, override order, every catalog key and path resolves
// I/O: none (pure) > pass or fail
// Run: cd E:\zz-base-home\as-apps\in-inte\or-orac-webs && zig build test -Dfile=ut-loca-pack-test.zig
// ===================================================================
const std = @import("std"); const pack = @import("ut-loca-pack.zig"); const cfgz = @import("cf-conf-load.zig"); const jobs = @import("ru-jobs-tabl.zig");
test "keys are unique, 4+4 letters with underscore, every key has a label" { for (pack.PACK, 0..) |ent, ix| { try std.testing.expectEqual(@as(usize, 9), ent.key.len); try std.testing.expectEqual(@as(u8, '_'), ent.key[4]); try std.testing.expect(ent.labs.len >= 1); for (pack.PACK[ix + 1 ..]) |oth| try std.testing.expect(!std.mem.eql(u8, ent.key, oth.key)); } }
test "path keys are unique and start with a slash" { for (pack.PATHS, 0..) |pth, ix| { try std.testing.expect(pth.path[0] == '/'); for (pack.PATHS[ix + 1 ..]) |oth| try std.testing.expect(!std.mem.eql(u8, pth.key, oth.key)); } }
test "owner override wins, unknown key is empty" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const conf = try cfgz.confParse(aren.allocator(), "{\"labl_over\":{\"popu_dism\":[\"Nope\"]},\"path_over\":{\"p_keys\":\"/keys\"}}"); try std.testing.expectEqualStrings("Nope", pack.lab(conf, "popu_dism")[0]); try std.testing.expectEqualStrings("/keys", pack.pathOf(conf, "p_keys")); const dflt: cfgz.Conf = .{}; try std.testing.expectEqual(@as(usize, 0), pack.lab(dflt, "zzzz_zzzz").len); try std.testing.expect(pack.known("regi_subm")); try std.testing.expect(!pack.known("zzzz_zzzz")); }
test "every key and path a catalog job names exists" { const dflt: cfgz.Conf = .{}; for (jobs.JOBS) |jb| { if (jb.path.len > 0) try std.testing.expect(pack.pathOf(dflt, jb.path).len > 0); for (jb.steps) |tpl| { if (tpl.key.len > 0) { if (!pack.known(tpl.key)) std.debug.print("missing label key: {s} in job {s}\n", .{ tpl.key, jb.name }); try std.testing.expect(pack.known(tpl.key)); } } } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
