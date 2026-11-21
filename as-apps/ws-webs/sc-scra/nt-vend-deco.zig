// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Decodo adapter: build POST request, read result JSON
// Flo: JSON body {url, headless for render} > Basic auth token > send > read results[0] content + status_code
// I/O: Req + auth token (ladder) > Rsp; ⚠️ premium pool parameter unverified, prem = render
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig");
const CF = .{ .urlz = "https://scraper-api.decodo.com/v2/scrape" };
const Bodz = struct { url: []const u8, headless: ?[]const u8 = null, geo: ?[]const u8 = null };
pub fn requBuil(aren: std.mem.Allocator, key2: []const u8, req2: base.Requ) !base.Http { const geon: ?[]const u8 = if (req2.geoz.len > 0) (base.geozName(req2.geoz) orelse return error.BadGeo) else null; const bodz: Bodz = .{ .url = req2.urlz, .headless = if (req2.mode == .plai) null else "html", .geo = geon }; return .{ .post = true, .urlz = CF.urlz, .auth = try std.fmt.allocPrint(aren, "Basic {s}", .{key2}), .ctyp = "application/json", .body = try std.json.Stringify.valueAlloc(aren, bodz, .{ .emit_null_optional_fields = false }) }; }
pub fn respRead(aren: std.mem.Allocator, key2: []const u8, req2: base.Requ, back: base.Back) !base.Res2 { const badz = base.Res2{ .code = back.code, .ctyp = "", .body = "", .cred = 0, .errz = "badresp" }; const valu = std.json.parseFromSliceLeaky(std.json.Value, aren, back.body, .{}) catch return badz; if (valu != .object) return badz; const list = valu.object.get("results") orelse return badz; if (list != .array or list.array.items.len == 0 or list.array.items[0] != .object) return badz; const first = list.array.items[0].object; const cont = first.get("content") orelse return badz; if (cont != .string) return badz; const stat: u16 = if (first.get("status_code")) |sczz| (if (sczz == .integer and sczz.integer >= 100 and sczz.integer < 600) @intCast(sczz.integer) else back.code) else back.code; _ = key2; const cred: u32 = if (stat >= 400) 0 else base.credCost(.deco, req2.mode); return .{ .code = stat, .ctyp = "text/html", .body = cont.string, .cred = cred, .errz = "" }; }
pub fn call(aren: std.mem.Allocator, gpaz: std.mem.Allocator, iozz: std.Io, send: base.Send, key2: []const u8, req2: base.Requ) !base.Res2 { const http = try requBuil(aren, key2, req2); const back = try send.call(send.ctx2, gpaz, iozz, http); defer gpaz.free(back.body); return respRead(aren, key2, req2, back); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
