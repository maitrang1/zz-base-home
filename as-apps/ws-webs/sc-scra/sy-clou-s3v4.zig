// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: AWS Signature V4 signer for S3-compatible object stores
// Flo: hash body > canonical request (host, content hash, date) > string to sign > HMAC key chain > Authorization value
// I/O: credentials + method + encoded path + sorted query + body + UTC date text (caller) > Sig (auth header, content hash)
// ===================================================================
const std = @import("std"); const Hmac = std.crypto.auth.hmac.sha2.HmacSha256; const Sha = std.crypto.hash.sha2.Sha256;
pub const Cred = struct { akey: []const u8, skey: []const u8, regn: []const u8, host: []const u8 };
pub const Sig = struct { auth: []const u8, phsh: []const u8 };
fn hex(aren: std.mem.Allocator, raws: []const u8) ![]u8 { const outp = try aren.alloc(u8, raws.len * 2); return @constCast(std.fmt.bufPrint(outp, "{x}", .{raws}) catch unreachable); }
fn hmac(key: []const u8, msg: []const u8) [Hmac.mac_length]u8 { var outp: [Hmac.mac_length]u8 = undefined; Hmac.create(&outp, msg, key); return outp; }
pub fn sigMake(aren: std.mem.Allocator, cred: Cred, meth: []const u8, path: []const u8, query: []const u8, body: []const u8, date: []const u8) !Sig { var dig: [Sha.digest_length]u8 = undefined; Sha.hash(body, &dig, .{}); const phsh = try hex(aren, &dig); const canon = try std.fmt.allocPrint(aren, "{s}\n{s}\n{s}\nhost:{s}\nx-amz-content-sha256:{s}\nx-amz-date:{s}\n\nhost;x-amz-content-sha256;x-amz-date\n{s}", .{ meth, path, query, cred.host, phsh, date, phsh }); var cdig: [Sha.digest_length]u8 = undefined; Sha.hash(canon, &cdig, .{}); const scope = try std.fmt.allocPrint(aren, "{s}/{s}/s3/aws4_request", .{ date[0..8], cred.regn }); const sts = try std.fmt.allocPrint(aren, "AWS4-HMAC-SHA256\n{s}\n{s}\n{x}", .{ date, scope, cdig }); const seed = try std.fmt.allocPrint(aren, "AWS4{s}", .{cred.skey}); const kdat = hmac(seed, date[0..8]); const kreg = hmac(&kdat, cred.regn); const ksrv = hmac(&kreg, "s3"); const ksig = hmac(&ksrv, "aws4_request"); const sig = hmac(&ksig, sts); return .{ .phsh = phsh, .auth = try std.fmt.allocPrint(aren, "AWS4-HMAC-SHA256 Credential={s}/{s}, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature={x}", .{ cred.akey, scope, sig }) }; }
pub fn dateNow(buff: *[16]u8, mill: i64) []const u8 { const secs: u64 = @intCast(@max(@divFloor(mill, 1000), 0)); const eps: std.time.epoch.EpochSeconds = .{ .secs = secs }; const yday = eps.getEpochDay().calculateYearDay(); const mday = yday.calculateMonthDay(); const dsec = eps.getDaySeconds(); return std.fmt.bufPrint(buff, "{d:0>4}{d:0>2}{d:0>2}T{d:0>2}{d:0>2}{d:0>2}Z", .{ yday.year, mday.month.numeric(), mday.day_index + 1, dsec.getHoursIntoDay(), dsec.getMinutesIntoHour(), dsec.getSecondsIntoMinute() }) catch ""; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
