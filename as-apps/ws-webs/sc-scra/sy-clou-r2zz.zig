// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Cloudflare R2 adapter: S3 endpoint and region for the shared client
// Flo: pick host from config or the vendor default > fixed region rule > build SigV4 credentials
// I/O: Endp config + key pair (sync) > s3v4.Cred
// ===================================================================
const std = @import("std"); const cfgz = @import("cf-conf-load.zig"); const s3v4 = @import("sy-clou-s3v4.zig"); const stor = @import("sy-clou-stor.zig");
pub fn credMake(aren: std.mem.Allocator, endp: cfgz.Endp, pair: stor.Pair) !s3v4.Cred { _ = aren; if (endp.hostz.len == 0) return error.BadConfig; return .{ .akey = pair.akey, .skey = pair.skey, .regn = "auto", .host = endp.hostz }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
