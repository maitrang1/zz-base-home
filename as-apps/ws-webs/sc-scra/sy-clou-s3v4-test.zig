// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for sy-clou-s3v4: signature vs independent Python HMAC result
// Flo: sign a fixed request > compare hash and signature text > date formatting
// I/O: fixed inputs > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const s3v4 = @import("sy-clou-s3v4.zig");
const CRED: s3v4.Cred = .{ .akey = "AKIDEXAMPLE", .skey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY", .regn = "us-east-1", .host = "examplebucket.s3.amazonaws.com" };
test "signature matches an independent HMAC computation" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const sigz = try s3v4.sigzMake(aren.allocator(), CRED, "PUT", "/dir/te%20st.txt", "list-type=2&prefix=a%2Fb", "hello world", "20130524T000000Z"); try std.testing.expectEqualStrings("b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9", sigz.phsh); try std.testing.expectEqualStrings("AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=f9ae7d8676dcaaca39a73b1c02c5e80f14f9c70ac5f2479c1f76abf7f21dbd86", sigz.auth); }
test "any input change changes the signature" { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const base = try s3v4.sigzMake(aren.allocator(), CRED, "GET", "/a", "", "", "20130524T000000Z"); const meth = try s3v4.sigzMake(aren.allocator(), CRED, "PUT", "/a", "", "", "20130524T000000Z"); const path = try s3v4.sigzMake(aren.allocator(), CRED, "GET", "/b", "", "", "20130524T000000Z"); const body = try s3v4.sigzMake(aren.allocator(), CRED, "GET", "/a", "", "x", "20130524T000000Z"); const dayz = try s3v4.sigzMake(aren.allocator(), CRED, "GET", "/a", "", "", "20130525T000000Z"); for ([_]s3v4.Sigz{ meth, path, body, dayz }) |othe| try std.testing.expect(!std.mem.eql(u8, base.auth, othe.auth)); }
test "UTC date text" { var buf4: [16]u8 = undefined; try std.testing.expectEqualStrings("19700101T000000Z", s3v4.dateNowz(&buf4, 0)); try std.testing.expectEqualStrings("20260921T145308Z", s3v4.dateNowz(&buf4, 1790002388000)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
