// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Keep Oracle session cookies after the window closes
// Flo: read all cookies > pick session-only ones of our hosts > write them back with an expiry date > count
// I/O: Ctx (page, conf) > number of cookies made persistent (best effort, values never printed or logged)
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig");
const CF = .{ .secs = 86400 };
const Put = struct { name: []const u8, value: []const u8, domain: []const u8, path: []const u8, secure: bool, httpOnly: bool, sameSite: ?[]const u8 = null, expires: f64 };
pub fn ours(conf_hosts: []const []const u8, dom: []const u8) bool { const bare = std.mem.trimStart(u8, dom, "."); for (conf_hosts) |hst| { if (std.mem.eql(u8, bare, hst)) return true; if (bare.len > hst.len and std.mem.endsWith(u8, bare, hst) and bare[bare.len - hst.len - 1] == '.') return true; } return false; }
fn strOf(obj: std.json.Value, key: []const u8) []const u8 { const val = obj.object.get(key) orelse return ""; return if (val == .string) val.string else ""; }
fn boolOf(obj: std.json.Value, key: []const u8) bool { const val = obj.object.get(key) orelse return false; return val == .bool and val.bool; }
pub fn keep(ctx: *task.Ctx) u32 { if (ctx.conf.sess_keep_dayz == 0) return 0; ctx.page.arm(ctx.conf.brow_time_seco * 1000); const res = ctx.page.call(ctx.aren, "Network.getAllCookies", "") catch return 0; if (res != .object) return 0; const lst = res.object.get("cookies") orelse return 0; if (lst != .array) return 0; const till: f64 = @floatFromInt(@divTrunc(task.nowMs(ctx), 1000) + @as(i64, ctx.conf.sess_keep_dayz) * CF.secs); var cnt: u32 = 0; for (lst.array.items) |ck| { if (ck != .object or !boolOf(ck, "session")) continue; const dom = strOf(ck, "domain"); if (!ours(ctx.conf.sess_keep_host, dom)) continue; const same = strOf(ck, "sameSite"); const put: Put = .{ .name = strOf(ck, "name"), .value = strOf(ck, "value"), .domain = dom, .path = strOf(ck, "path"), .secure = boolOf(ck, "secure"), .httpOnly = boolOf(ck, "httpOnly"), .sameSite = if (same.len > 0) same else null, .expires = till }; const prm = std.json.Stringify.valueAlloc(ctx.aren, put, .{ .emit_null_optional_fields = false }) catch continue; ctx.page.arm(ctx.conf.brow_time_seco * 1000); _ = ctx.page.call(ctx.aren, "Network.setCookie", prm) catch continue; cnt += 1; } return cnt; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
