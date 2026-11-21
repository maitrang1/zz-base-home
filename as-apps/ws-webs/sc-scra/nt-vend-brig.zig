// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Bright Data adapter (Web Unlocker): POST /request, raw body
// Flo: JSON body {zone,url,format:raw} > Bearer token > send > body is the page, error code in a header is not visible so 4xx/5xx = no credit
// I/O: Req + token + zone (ladder) > Rsp; ⚠️ billed per request, free tier may not cover Unlocker
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
const CF = .{ .urlz = "https://api.brightdata.com/request" };
const Bodz = struct { zone: []const u8, url: []const u8, format: []const u8, country: ?[]const u8 = null };
pub fn requBuil(aren: std.mem.Allocator, key2: []const u8, zone: []const u8, req2: base.Requ) !base.Http { if (zone.len == 0) return error.BadConfig; if (req2.geoz.len > 0 and !base.geozOkay(req2.geoz)) return error.BadGeo; const ctry = if (req2.geoz.len > 0) try std.ascii.allocLowerString(aren, req2.geoz) else null; return .{ .post = true, .urlz = CF.urlz, .auth = try std.fmt.allocPrint(aren, "Bearer {s}", .{key2}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, Bodz{ .zone = zone, .url = req2.urlz, .format = "raw", .country = ctry }, .{ .emit_null_optional_fields = false }) }; }
pub fn respRead(aren: std.mem.Allocator, req2: base.Requ, back: base.Back) !base.Res2 { const cred: u32 = if (back.code >= 400) 0 else base.credCost(.brig, req2.mode); return .{ .code = back.code, .ctyp = "text/html", .body = try aren.dupe(u8, back.body), .cred = cred, .errz = "" }; }
pub fn call(aren: std.mem.Allocator, gpaz: std.mem.Allocator, iozz: std.Io, send: base.Send, key2: []const u8, zone: []const u8, req2: base.Requ) !base.Res2 { const http = try requBuil(aren, key2, zone, req2); const back = try send.call(send.ctx2, gpaz, iozz, http); defer gpaz.free(back.body); return respRead(aren, req2, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
