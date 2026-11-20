// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Decodo adapter: build POST request, read result JSON
// Flo: JSON body {url, headless for render} > Basic auth token > send > read results[0] content + status_code
// I/O: Req + auth token (ladder) > Rsp; ⚠️ premium pool parameter unverified, prem = render
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
const CF = .{ .urlz = "https://scraper-api.decodo.com/v2/scrape" };
const Bodz = struct { url: []const u8, headless: ?[]const u8 = null };
pub fn reqBuild(aren: std.mem.Allocator, key: []const u8, req: base.Req) !base.Http { const bodz: Bodz = .{ .url = req.urlz, .headless = if (req.mode == .plain) null else "html" }; return .{ .post = true, .urlz = CF.urlz, .auth = try std.fmt.allocPrint(aren, "Basic {s}", .{key}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, bodz, .{ .emit_null_optional_fields = false }) }; }
pub fn rspRead(aren: std.mem.Allocator, key: []const u8, req: base.Req, back: base.Back) !base.Rsp { const bad = base.Rsp{ .code = back.code, .ctyp = "", .body = "", .cred = 0, .errz = "badresp" }; const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, back.body, .{}) catch return bad; if (valu != .object) return bad; const list = valu.object.get("results") orelse return bad; if (list != .array or list.array.items.len == 0 or list.array.items[0] != .object) return bad; const first = list.array.items[0].object; const cont = first.get("content") orelse return bad; if (cont != .string) return bad; const stat: u16 = if (first.get("status_code")) |sc| (if (sc == .integer and sc.integer >= 100 and sc.integer < 600) @intCast(sc.integer) else back.code) else back.code; _ = key; const cred: u32 = if (stat >= 400) 0 else base.credCost(.deco, req.mode); return .{ .code = stat, .ctyp = "text/html", .body = cont.string, .cred = cred, .errz = "" }; }
pub fn call(aren: std.mem.Allocator, gpaz: std.mem.Allocator, iozz: std.Io, send: base.Send, key: []const u8, req: base.Req) !base.Rsp { const http = try reqBuild(aren, key, req); const back = try send.call(send.ctx, gpaz, iozz, http); defer gpaz.free(back.body); return rspRead(aren, key, req, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
