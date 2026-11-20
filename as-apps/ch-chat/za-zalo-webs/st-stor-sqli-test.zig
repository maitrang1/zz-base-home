// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for st-stor-sqli: CRUD, nulls, migrations
// Flo: open memory db > insert > select > migrate twice > assert
// I/O: SQL text > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const sqli = @import("st-stor-sqli.zig");
test "insert and read back text, int, null" { var dbzz = try sqli.Db.open(":memory:"); defer dbzz.close(); try dbzz.exec("CREATE TABLE t(a TEXT, b INTEGER, c TEXT);"); var ins = try dbzz.prep("INSERT INTO t VALUES(?,?,?);"); defer ins.fini(); try ins.bindText(1, "he'llo"); try ins.bindInt(2, 42); try ins.bindNull(3); try std.testing.expect(!try ins.step()); try std.testing.expectEqual(@as(i64, 1), dbzz.changes()); var sel = try dbzz.prep("SELECT a,b,c FROM t;"); defer sel.fini(); try std.testing.expect(try sel.step()); try std.testing.expectEqualStrings("he'llo", sel.colText(0)); try std.testing.expectEqual(@as(i64, 42), sel.colInt(1)); try std.testing.expectEqualStrings("", sel.colText(2)); try std.testing.expect(!try sel.step()); }
test "bad sql gives typed error" { var dbzz = try sqli.Db.open(":memory:"); defer dbzz.close(); try std.testing.expectError(error.SqliExec, dbzz.exec("NOT SQL;")); try std.testing.expectError(error.SqliPrep, dbzz.prep("SELECT * FROM nope;")); }
test "migrations run once, in order" { var dbzz = try sqli.Db.open(":memory:"); defer dbzz.close(); const steps = [_][:0]const u8{ "CREATE TABLE a(x);", "CREATE TABLE b(y);" }; try dbzz.migr(std.testing.allocator, &steps); try std.testing.expectEqual(@as(i64, 2), try dbzz.verGet()); try dbzz.migr(std.testing.allocator, &steps); try std.testing.expectEqual(@as(i64, 2), try dbzz.verGet()); const more = [_][:0]const u8{ steps[0], steps[1], "CREATE TABLE d(z);" }; try dbzz.migr(std.testing.allocator, &more); try std.testing.expectEqual(@as(i64, 3), try dbzz.verGet()); }
test "failed migration rolls back and keeps version" { var dbzz = try sqli.Db.open(":memory:"); defer dbzz.close(); const steps = [_][:0]const u8{ "CREATE TABLE a(x);", "CREATE TABLE a(x);" }; try std.testing.expectError(error.SqliExec, dbzz.migr(std.testing.allocator, &steps)); try std.testing.expectEqual(@as(i64, 1), try dbzz.verGet()); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
