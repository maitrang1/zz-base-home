// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ut-uuid-seve: layout, version, order
// Flo: fixed inputs > assert exact text
// I/O: ms + bytes > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const uuid = @import("ut-uuid-seve.zig");
test "exact layout for a known time and zero random" { const out = uuid.uuidSeve(0x0123456789ab, @as([10]u8, @splat(0))); try std.testing.expectEqualStrings("01234567-89ab-7000-8000-000000000000", &out); }
test "version 7 and variant 10 survive all-ones random" { const out = uuid.uuidSeve(1, @as([10]u8, @splat(0xff))); try std.testing.expectEqual(@as(u8, '7'), out[14]); try std.testing.expect(out[19] == '8' or out[19] == '9' or out[19] == 'a' or out[19] == 'b'); try std.testing.expectEqualStrings("00000000-0001-7fff-bfff-ffffffffffff", &out); }
test "later time sorts after earlier time as text" { const one = uuid.uuidSeve(1000, @as([10]u8, @splat(0xff))); const two = uuid.uuidSeve(1001, @as([10]u8, @splat(0))); try std.testing.expect(std.mem.order(u8, &one, &two) == .lt); }
test "negative time clamps to zero" { const out = uuid.uuidSeve(-5, @as([10]u8, @splat(0))); try std.testing.expectEqualStrings("00000000-0000-7000-8000-000000000000", &out); }
test "fresh ids differ" { const one = uuid.uuidNew(std.testing.io, 5); const two = uuid.uuidNew(std.testing.io, 5); try std.testing.expect(!std.mem.eql(u8, &one, &two)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
