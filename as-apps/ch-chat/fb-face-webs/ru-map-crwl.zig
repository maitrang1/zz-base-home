// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read-only site map: record every control at human pace
// Flo: seeds > per page: quiet hours + help cap + halt checks (task.visit) > read title, controls, links > write one JSON per page + index in <stat>/map/<date>/ > queue allowed links (depth and page caps) ; never clicks, never types
// I/O: config map_* keys (caller) > files in <stat>/map/<date>/ (redacted); returns the page count; errors Halted NeedLogin Unsafe CapHit QuietHour
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig"); const snap = @import("ru-snap-main.zig"); const priv = @import("ru-safe-priv.zig"); const pace = @import("ru-huma-pace.zig");
const CF = .{ .dir = "map", .ctl_max = 400, .jsl = "Array.from(document.querySelectorAll('a[href]')).map(function(a){return a.getAttribute('href')})", .ttl = "document.title", .lang = "document.documentElement.lang||''" };
const ROLES = [_][]const u8{ "button", "link", "menuitem", "menuitemcheckbox", "menuitemradio", "textbox", "searchbox", "checkbox", "switch", "combobox", "radio", "tab", "option", "spinbutton", "slider" };
const DENY = [_][]const u8{ "logout", "delete", "remove", "confirm", "ajax", "/dialog", "action", "unsubscribe", "deactivate", ".php?" };
pub const Ctl = struct { r: []const u8, n: []const u8 };
pub const PageMap = struct { path: []const u8, title: []const u8, lang: []const u8, ctl: []const Ctl };
pub const Idx = struct { path: []const u8, title: []const u8, nctl: usize, file: []const u8 };
fn roleOk(role: []const u8) bool { for (ROLES) |rl| { if (std.mem.eql(u8, rl, role)) return true; } return false; }
pub fn dayStr(aren: std.mem.Allocator, ms: i64) ![]u8 { const secs: u64 = @intCast(@max(@divFloor(ms, 1000), 0)); const es = std.time.epoch.EpochSeconds{ .secs = secs }; const yd = es.getEpochDay().calculateYearDay(); const md = yd.calculateMonthDay(); return std.fmt.allocPrint(aren, "{d:0>4}-{d:0>2}-{d:0>2}", .{ yd.year, md.month.numeric(), md.day_index + 1 }); }
fn cleanPath(base: []const u8, href: []const u8) ?[]const u8 { var raw = href; if (std.mem.startsWith(u8, raw, base)) raw = raw[base.len..]; if (raw.len == 0 or raw[0] != '/') return null; const cut = std.mem.findAny(u8, raw, "?#") orelse raw.len; return raw[0..cut]; }
pub fn allowed(conf: @import("cf-conf-load.zig").Conf, path: []const u8) bool { if (path.len == 0 or path[0] != '/') return false; for (DENY) |bad| { if (std.mem.find(u8, path, bad) != null) return false; } for (conf.map_allo_list) |pre| { if (std.mem.startsWith(u8, path, pre)) return true; } return false; }
fn seen(list: []const []const u8, path: []const u8) bool { for (list) |ite| { if (std.mem.eql(u8, ite, path)) return true; } return false; }
fn links(ctx: *task.Ctx) []const []const u8 { return task.jsList(ctx, CF.jsl) catch &.{}; }
fn slug(ctx: *task.Ctx, idx: usize, path: []const u8) ![]u8 { const nm = try snap.safeName(ctx.aren, if (path.len > 1) path[1..] else "home"); return std.fmt.allocPrint(ctx.aren, "{d:0>3}-{s}.json", .{ idx, nm[0..@min(nm.len, 40)] }); }
fn controls(ctx: *task.Ctx) ![]const Ctl { const rows = try snap.axRows(ctx); var out: std.ArrayList(Ctl) = .empty; for (rows) |rw| { if (!roleOk(rw.r) or out.items.len >= CF.ctl_max) continue; var dup = false; for (out.items) |ex| { if (std.mem.eql(u8, ex.r, rw.r) and std.mem.eql(u8, ex.n, rw.n)) dup = true; } if (!dup) try out.append(ctx.aren, .{ .r = rw.r, .n = rw.n }); } return out.items; }
fn writeIdx(ctx: *task.Ctx, dir: []const u8, idx: []const Idx) !void { const body = try std.json.Stringify.valueAlloc(ctx.aren, idx, .{}); const path = try std.fs.path.join(ctx.aren, &.{ dir, "index.json" }); try std.Io.Dir.cwd().writeFile(ctx.iozz, .{ .sub_path = path, .data = body }); }
pub fn mapRun(ctx: *task.Ctx) !u32 { const day = try dayStr(ctx.aren, task.nowMs(ctx)); const dir = try std.fs.path.join(ctx.aren, &.{ ctx.statd, CF.dir, day }); try std.Io.Dir.cwd().createDirPath(ctx.iozz, dir);
var queue: std.ArrayList([]const u8) = .empty; var depth: std.ArrayList(u32) = .empty; var done: std.ArrayList([]const u8) = .empty; var idxs: std.ArrayList(Idx) = .empty;
for (ctx.conf.map_seed_list) |sd| { if (!seen(queue.items, sd)) { try queue.append(ctx.aren, sd); try depth.append(ctx.aren, 0); } }
var head: usize = 0; var stop: ?anyerror = null;
while (head < queue.items.len and idxs.items.len < ctx.conf.map_page_maxx) : (head += 1) { const path = queue.items[head]; if (seen(done.items, path)) continue; if (!allowed(ctx.conf, path)) continue; task.gate(ctx, .help) catch |err| { stop = err; break; };
task.visit(ctx, path) catch |err| { if (err == error.NoElement or err == error.Drift) { task.say(ctx, "skipped {s} ({s})", .{ path, @errorName(err) }); continue; } stop = err; break; };
ctx.page.arm(ctx.conf.brow_time_seco * 1000); const title = ctx.page.evalStr(ctx.aren, CF.ttl) catch ""; const lang = ctx.page.evalStr(ctx.aren, CF.lang) catch ""; const ctl = try controls(ctx);
const pm: PageMap = .{ .path = path, .title = try priv.redact(ctx.aren, title), .lang = lang, .ctl = ctl }; const file = try slug(ctx, idxs.items.len + 1, path); const body = try std.json.Stringify.valueAlloc(ctx.aren, pm, .{}); const fp = try std.fs.path.join(ctx.aren, &.{ dir, file }); try std.Io.Dir.cwd().writeFile(ctx.iozz, .{ .sub_path = fp, .data = body });
try ctx.store.actAdd("help", path, task.nowMs(ctx)); try done.append(ctx.aren, path); try idxs.append(ctx.aren, .{ .path = path, .title = pm.title, .nctl = ctl.len, .file = file }); task.say(ctx, "mapped {s}: {d} controls", .{ path, ctl.len });
const dep = depth.items[head]; if (dep < ctx.conf.map_deep_maxx) { for (links(ctx)) |href| { const lp = cleanPath(ctx.conf.base_urlz_main, href) orelse continue; if (!allowed(ctx.conf, lp) or seen(queue.items, lp)) continue; try queue.append(ctx.aren, lp); try depth.append(ctx.aren, dep + 1); } } }
try writeIdx(ctx, dir, idxs.items); task.say(ctx, "site map: {d} pages in {s}", .{ idxs.items.len, dir }); if (stop) |err| { if (idxs.items.len == 0 or (err != error.CapHit and err != error.QuietHour)) return err; task.say(ctx, "stopped early: {s}", .{@errorName(err)}); } return @intCast(idxs.items.len); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
