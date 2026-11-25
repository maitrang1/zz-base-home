// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Popups: dismiss harmless dialogs, stop on unknown ones
// Flo: AX snapshot > any dialog? > known by registry: click its close button, verify gone > unknown: UnknownModal
// I/O: session-like value (caller, duck typed) > Res clear or dismissed; permissions denied in the browser
// ===================================================================
const std = @import("std"); const snap = @import("ru-page-snap.zig"); const fnd = @import("ru-labl-find.zig"); const cdp = @import("nt-cdpz-sock.zig");
pub const Res = enum { clear, dismissed };
const PERMS = [_][]const u8{ "notifications", "geolocation", "videoCapture", "audioCapture" };
pub fn check(ses: anytype) !Res { const lst = try ses.nodes(); const role = fnd.roleOf(&ses.reg, "benn_dlgz"); const dlgs = try snap.findAll(ses.aren, lst, if (role.len > 0) role else "dialog", ""); if (dlgs.len == 0) return .clear; if (fnd.findKey(&ses.reg, lst, "benn_dlgz") == null) { ses.logz("warn", "unknown dialog on the page"); return error.UnknownModal; } const btn = fnd.findKey(&ses.reg, lst, "clos_butt") orelse { ses.logz("warn", "known dialog without a close button"); return error.UnknownModal; }; try ses.clickNode(btn); ses.readPause(); const after = try ses.nodes(); if (fnd.findKey(&ses.reg, after, "benn_dlgz") != null) { ses.logz("warn", "dialog did not close"); return error.UnknownModal; } ses.logz("info", "dismissed a known dialog"); return .dismissed; }
pub fn denyPerms(aren: std.mem.Allocator, conn: *cdp.Conn) void { for (PERMS) |nam| { const par = std.fmt.allocPrint(aren, "{{\"permission\":{{\"name\":\"{s}\"}},\"setting\":\"denied\"}}", .{nam}) catch return; _ = conn.callJson(aren, "Browser.setPermission", par, 5000) catch {}; } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
