// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Alerts on a separate channel: Healthchecks ping, Resend email
// Flo: load channel secrets from key files > POST fail ping with text > POST email > count channels that answered > none = error
// I/O: subject + text (breaker, purge, caps) > delivered count; key files healthchecks.url and resend.key
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .mail = "https://api.resend.com/emails", .keyz = 4096 };
pub const Aler = struct { send: base.Send, gpaz: std.mem.Allocator, hcur: []const u8 = "", rkey: []const u8 = "", from: []const u8 = "", toxx: []const u8 = "" };
const Mail = struct { from: []const u8, to: []const []const u8, subject: []const u8, text: []const u8 };
fn one2(self: *const Aler, aren: std.mem.Allocator, iozz: std.Io, htpz: base.Http) bool { _ = aren; const back = self.send.call(self.send.ctx2, self.gpaz, iozz, htpz) catch return false; defer self.gpaz.free(back.body); return back.code >= 200 and back.code < 300; }
pub fn alerSend(self: *const Aler, aren: std.mem.Allocator, iozz: std.Io, subject: []const u8, text: []const u8) !u8 { var okay: u8 = 0; if (self.hcur.len > 0) { const full = try std.fmt.allocPrint(aren, "{s}/fail", .{std.mem.trimEnd(u8, self.hcur, "/")}); const body = try std.fmt.allocPrint(aren, "{s}: {s}", .{ subject, text }); if (one2(self, aren, iozz, .{ .post = true, .urlz = full, .ctyp = "text/plain", .body = body })) okay += 1; } if (self.rkey.len > 0 and self.toxx.len > 0 and self.from.len > 0) { const mail: Mail = .{ .from = self.from, .to = &.{self.toxx}, .subject = subject, .text = text }; const body = try std.json.Stringify.valueAlloc(aren, mail, .{}); if (one2(self, aren, iozz, .{ .post = true, .urlz = CF.mail, .auth = try std.fmt.allocPrint(aren, "Bearer {s}", .{self.rkey}), .ctyp = "application/json", .body = body })) okay += 1; } if (okay == 0) return error.AlertFail; return okay; }
fn keyzOnez(aren: std.mem.Allocator, iozz: std.Io, keyd: []const u8, name: []const u8) []const u8 { const path = std.fs.path.join(aren, &.{ keyd, name }) catch return ""; const raws = std.Io.Dir.cwd().readFileAlloc(iozz, path, aren, .limited(CF.keyz)) catch return ""; return std.mem.trim(u8, std.mem.sliceTo(std.mem.trim(u8, raws, " \t\r\n"), '\n'), " \t\r"); }
pub fn alerLoad(aren: std.mem.Allocator, iozz: std.Io, keyd: []const u8, conf: cfgz.Conf, send: base.Send, gpaz: std.mem.Allocator) Aler { return .{ .send = send, .gpaz = gpaz, .hcur = keyzOnez(aren, iozz, keyd, "healthchecks.url"), .rkey = keyzOnez(aren, iozz, keyd, "resend.key"), .from = conf.aler_mail_from, .toxx = conf.aler_mail_toxx }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
