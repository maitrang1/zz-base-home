// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo-work-mode beat: heartbeat ping, silence raises an outside alarm
// Flo: read ping url file > check stamp ages > live: curl url (ok) or url/fail (stale) > facts
// I/O: Ctxz (dry-run default, --live pings) > facts, exit 0 ok / 1 stale / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const CF = .{ .maxz = 512, .prfx = "https://", .fail = "/fail" };
pub fn urlPick(text: []const u8) ?[]const u8 {
var lines = std.mem.splitScalar(u8, text, '\n');
const line = cx.trim(lines.next() orelse return null);
if (!std.mem.startsWith(u8, line, CF.prfx) or line.len <= CF.prfx.len) return null;
if (std.mem.indexOfAny(u8, line, " \t\"'") != null) return null;
return line;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 0) return exit.Erro.Usag;
var facts: std.ArrayList(fcts.Fact) = .empty;
if (ctxz.conf.beat_urlz_file.len == 0) { try facts.append(ctxz.allo, cx.mkfa("beat", .skip, "beat_urlz_file is empty: no heartbeat set")); return ctxz.emit(facts.items); }
const path = try std.fs.path.join(ctxz.allo, &.{ ctxz.home, ctxz.conf.beat_urlz_file });
const data = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, path, ctxz.allo, .limited(CF.maxz)) catch { try facts.append(ctxz.allo, cx.mkfa("beat", .bloc, try std.fmt.allocPrint(ctxz.allo, "cannot read {s}", .{ctxz.conf.beat_urlz_file}))); return ctxz.emit(facts.items); };
const urlz = urlPick(data) orelse { try facts.append(ctxz.allo, cx.mkfa("beat", .bloc, "the file does not start with a clean https url")); return ctxz.emit(facts.items); };
var good = true;
for (ctxz.conf.beat_chek_list) |name| {
const stam = ctxz.stamGet(name) orelse { try facts.append(ctxz.allo, cx.mkfa(name, .fail, "never ran")); good = false; continue; };
const ager = ctxz.nowz() - stam.when;
if (!stam.okay or ager > ctxz.conf.beat_ager_maxz) { try facts.append(ctxz.allo, cx.mkfa(name, .fail, try std.fmt.allocPrint(ctxz.allo, "stale: last good run {d}s ago, limit {d}s", .{ ager, ctxz.conf.beat_ager_maxz }))); good = false; } else try facts.append(ctxz.allo, cx.mkfa(name, .okay, ""));
}
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("beat", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would send the {s} ping", .{if (good) "ok" else "fail"}))); return ctxz.emit(facts.items); }
const target = if (good) urlz else try std.mem.concat(ctxz.allo, u8, &.{ urlz, CF.fail });
_ = (try ctxz.step(&facts, "ping", &.{ "curl", "-fsS", "-m", "10", "--retry", "2", target }, &.{})) orelse return ctxz.emit(facts.items);
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
