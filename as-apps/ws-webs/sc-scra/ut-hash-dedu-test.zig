// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ut-hash-dedu: known digest, path, validity
// Flo: hash known input > compare > build path > validate
// I/O: bytes > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const hash = @import("ut-hash-dedu.zig");
test "sha256 of abc matches the known digest" { const hexz = hash.hashHexz("abc"); try std.testing.expectEqualStrings("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", &hexz); }
test "same bytes same hash, different bytes differ" { try std.testing.expectEqualSlices(u8, &hash.hashHexz("x"), &hash.hashHexz("x")); try std.testing.expect(!std.mem.eql(u8, &hash.hashHexz("x"), &hash.hashHexz("y"))); }
test "path splits ab/cd/hash.gz" { var buff: [96]u8 = undefined; const path = try hash.hashPath(&buff, hash.hashHexz("abc")); try std.testing.expectEqualStrings("ba/78/ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad.gz", path); var tiny: [8]u8 = undefined; try std.testing.expectError(error.NoSpaceLeft, hash.hashPath(&tiny, hash.hashHexz("abc"))); }
test "hashOkay refuses path tricks" { try std.testing.expect(hash.hashOkay(&hash.hashHexz("abc"))); try std.testing.expect(!hash.hashOkay("../../etc/passwd")); try std.testing.expect(!hash.hashOkay("ABCDEF")); try std.testing.expect(!hash.hashOkay("")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
