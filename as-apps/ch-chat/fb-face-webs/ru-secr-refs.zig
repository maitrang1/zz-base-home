// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Account secrets as refs: read login data from user-acct.json in the secrets folder (never from the command line, never stored by fb)
// Flo: expand the secrets folder > read user-acct.json (missing or broken = empty) > fields login, pass, newp, firs, last, mail, birt > `fb secret` lists which fields are set, never the values
// I/O: folder path (caller) > task.Secr (arena owned); status text lists field names only
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig"); const cfgz = @import("cf-conf-load.zig");
const CF = .{ .file = "user-acct.json", .maxz = 8192 };
const FIELDS = [_][]const u8{ "login", "pass", "newp", "firs", "last", "mail", "birt" };
pub fn dirOf(allo: std.mem.Allocator, home: []const u8, conf: cfgz.Conf) ![]u8 { return cfgz.pathExpa(allo, home, conf.secr_loca_main); }
pub fn load(aren: std.mem.Allocator, iozz: std.Io, dir: []const u8) task.Secr { if (dir.len == 0) return .{}; const path = std.fs.path.join(aren, &.{ dir, CF.file }) catch return .{}; const byte = std.Io.Dir.cwd().readFileAlloc(iozz, path, aren, .limited(CF.maxz)) catch return .{}; return std.json.parseFromSliceLeaky(task.Secr, aren, byte, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch .{}; }
fn setOf(sc: task.Secr, name: []const u8) bool { if (std.mem.eql(u8, name, "login")) return sc.login.len > 0; if (std.mem.eql(u8, name, "pass")) return sc.pass.len > 0; if (std.mem.eql(u8, name, "newp")) return sc.newp.len > 0; if (std.mem.eql(u8, name, "firs")) return sc.firs.len > 0; if (std.mem.eql(u8, name, "last")) return sc.last.len > 0; if (std.mem.eql(u8, name, "mail")) return sc.mail.len > 0; return sc.birt.len > 0; }
pub fn count(sc: task.Secr) u32 { var cnt: u32 = 0; for (FIELDS) |nm| { if (setOf(sc, nm)) cnt += 1; } return cnt; }
pub fn status(ctx: *task.Ctx, dir: []const u8, json: bool) void { const sc = ctx.secr; var names: std.ArrayList(u8) = .empty; for (FIELDS) |nm| { if (!setOf(sc, nm)) continue; if (names.items.len > 0) names.appendSlice(ctx.aren, ", ") catch {}; names.appendSlice(ctx.aren, nm) catch {}; } if (json) { task.say(ctx, "{{\"file\":\"{s}\",\"set\":{d},\"of\":{d}}}", .{ CF.file, count(sc), FIELDS.len }); return; } task.say(ctx, "secrets folder: {s}", .{dir}); if (count(sc) == 0) { task.say(ctx, "no {s} found or it is empty: create it there with the fields you need ({s}); fb never prints the values", .{ CF.file, "login, pass, newp, firs, last, mail, birt" }); return; } task.say(ctx, "{s}: {d} of {d} fields set ({s}); values are never shown", .{ CF.file, count(sc), FIELDS.len, names.items }); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
