// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: ZenRows adapter: build GET request, read result
// Flo: encode URL > add js_render / premium_proxy by mode > send > detect vendor error JSON > credits only when the target answered
// I/O: Req + key (ladder) > Rsp (target status, body, credits, redacted vendor error)
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
const CF = .{ .host = "https://api.zenrows.com/v1/" };
pub fn reqBuild(aren: std.mem.Allocator, key: []const u8, req: base.Req) !base.Http { const urle = try base.pctEnc(aren, req.urlz); const geoz = req.geoz.len > 0; if (geoz and !base.geoOk(req.geoz)) return error.BadGeo; const jsrn = req.mode != .plain; const prem = req.mode == .prem or geoz; var flag: std.ArrayList(u8) = .empty; if (jsrn) try flag.appendSlice(aren, "&js_render=true"); if (prem) try flag.appendSlice(aren, "&premium_proxy=true"); if (geoz) try flag.print(aren, "&proxy_country={s}", .{req.geoz}); if (jsrn and req.wait > 0) try flag.print(aren, "&wait={d}", .{req.wait}); if (jsrn and req.sele.len > 0) try flag.print(aren, "&wait_for={s}", .{try base.pctEnc(aren, req.sele)}); return .{ .post = false, .urlz = try std.fmt.allocPrint(aren, "{s}?apikey={s}&url={s}{s}", .{ CF.host, key, urle, flag.items }) }; }
fn errCode(aren: std.mem.Allocator, body: []const u8) ?[]const u8 { if (body.len == 0 or body[0] != '{' or body.len > 4096) return null; const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, body, .{}) catch return null; if (valu != .object) return null; const code = valu.object.get("code") orelse return null; if (code != .string) return null; if (valu.object.get("title") == null and valu.object.get("detail") == null) return null; return code.string; }
pub fn rspRead(aren: std.mem.Allocator, key: []const u8, req: base.Req, back: base.Back) !base.Rsp { if (errCode(aren, back.body)) |code| return .{ .code = back.code, .ctyp = "", .body = "", .cred = 0, .errz = try base.redact(aren, code, key) }; const cred: u32 = if (back.code >= 400) 0 else base.credReq(.zenr, req); return .{ .code = back.code, .ctyp = "text/html", .body = try aren.dupe(u8, back.body), .cred = cred, .errz = "" }; }
pub fn call(aren: std.mem.Allocator, gpaz: std.mem.Allocator, iozz: std.Io, send: base.Send, key: []const u8, req: base.Req) !base.Rsp { const http = try reqBuild(aren, key, req); const back = try send.call(send.ctx, gpaz, iozz, http); defer gpaz.free(back.body); return rspRead(aren, key, req, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
