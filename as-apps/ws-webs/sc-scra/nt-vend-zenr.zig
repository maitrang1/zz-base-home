// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: ZenRows adapter: build GET request, read result
// Flo: encode URL > add js_render / premium_proxy by mode > send > detect vendor error JSON > credits only when the target answered
// I/O: Req + key (ladder) > Rsp (target status, body, credits, redacted vendor error)
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
const CF = .{ .host = "https://api.zenrows.com/v1/" };
pub fn reqBuild(aren: std.mem.Allocator, key: []const u8, req: base.Req) !base.Http { const urle = try base.pctEnc(aren, req.urlz); const flag: []const u8 = switch (req.mode) { .plain => "", .rend => "&js_render=true", .prem => "&js_render=true&premium_proxy=true" }; return .{ .post = false, .urlz = try std.fmt.allocPrint(aren, "{s}?apikey={s}&url={s}{s}", .{ CF.host, key, urle, flag }) }; }
fn errCode(aren: std.mem.Allocator, body: []const u8) ?[]const u8 { if (body.len == 0 or body[0] != '{' or body.len > 4096) return null; const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, body, .{}) catch return null; if (valu != .object) return null; const code = valu.object.get("code") orelse return null; if (code != .string) return null; if (valu.object.get("title") == null and valu.object.get("detail") == null) return null; return code.string; }
pub fn rspRead(aren: std.mem.Allocator, key: []const u8, req: base.Req, back: base.Back) !base.Rsp { if (errCode(aren, back.body)) |code| return .{ .code = back.code, .ctyp = "", .body = "", .cred = 0, .errz = try base.redact(aren, code, key) }; const cred: u32 = if (back.code >= 400) 0 else base.credCost(.zenr, req.mode); return .{ .code = back.code, .ctyp = "text/html", .body = try aren.dupe(u8, back.body), .cred = cred, .errz = "" }; }
pub fn call(aren: std.mem.Allocator, gpaz: std.mem.Allocator, iozz: std.Io, send: base.Send, key: []const u8, req: base.Req) !base.Rsp { const http = try reqBuild(aren, key, req); const back = try send.call(send.ctx, gpaz, iozz, http); defer gpaz.free(back.body); return rspRead(aren, key, req, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
