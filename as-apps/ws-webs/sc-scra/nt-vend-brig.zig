// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Bright Data adapter (Web Unlocker): POST /request, raw body
// Flo: JSON body {zone,url,format:raw} > Bearer token > send > body is the page, error code in a header is not visible so 4xx/5xx = no credit
// I/O: Req + token + zone (ladder) > Rsp; ⚠️ billed per request, free tier may not cover Unlocker
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
const CF = .{ .urlz = "https://api.brightdata.com/request" };
const Bodz = struct { zone: []const u8, url: []const u8, format: []const u8 };
pub fn reqBuild(aren: std.mem.Allocator, key: []const u8, zone: []const u8, req: base.Req) !base.Http { if (zone.len == 0) return error.BadConfig; return .{ .post = true, .urlz = CF.urlz, .auth = try std.fmt.allocPrint(aren, "Bearer {s}", .{key}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, Bodz{ .zone = zone, .url = req.urlz, .format = "raw" }, .{}) }; }
pub fn rspRead(aren: std.mem.Allocator, req: base.Req, back: base.Back) !base.Rsp { const cred: u32 = if (back.code >= 400) 0 else base.credCost(.brig, req.mode); return .{ .code = back.code, .ctyp = "text/html", .body = try aren.dupe(u8, back.body), .cred = cred, .errz = "" }; }
pub fn call(aren: std.mem.Allocator, gpaz: std.mem.Allocator, iozz: std.Io, send: base.Send, key: []const u8, zone: []const u8, req: base.Req) !base.Rsp { const http = try reqBuild(aren, key, zone, req); const back = try send.call(send.ctx, gpaz, iozz, http); defer gpaz.free(back.body); return rspRead(aren, req, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
