// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-comm-setu and the consent gate: texts, consent flag in the store
// Flo: memory store > consent unset, set > assert; risk texts present
// I/O: store > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const setu = @import("ct-comm-setu.zig"); const ctxz = @import("ct-ctrl-ctxz.zig"); const data = @import("st-stat-data.zig"); const T = std.testing;
test "consent is off by default, on after the date is stored, off for an empty value" { var sto = try data.Stor.open(T.allocator, ":memory:"); defer sto.close(); var aren = std.heap.ArenaAllocator.init(T.allocator); defer aren.deinit(); try T.expect(!ctxz.consentOk(&sto, aren.allocator())); try sto.metaSet("tos_ok", ""); try T.expect(!ctxz.consentOk(&sto, aren.allocator())); try sto.metaSet("tos_ok", "123"); try T.expect(ctxz.consentOk(&sto, aren.allocator())); }
test "risk text exists in both languages and names the account risk" { try T.expect(std.mem.find(u8, setu.RISK_VI, "khóa") != null); try T.expect(std.mem.find(u8, setu.RISK_EN, "locked") != null); try T.expect(!std.mem.eql(u8, setu.RISK_VI, setu.RISK_EN)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
