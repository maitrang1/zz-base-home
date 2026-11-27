// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo-work-mode doct: read-only drift checks, exit 3 on drift
// Flo: pick check list by profile > run each check > emit facts > fold to one exit code
// I/O: Ctxz + args > one fact per check on stdout, exit 0 ok / 3 drift / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const isoz = @import("ti-isoz-epoc.zig");
const vers = @import("ut-vers-comp.zig");
const host = @import("ob-host-fact.zig");
const CF = .{ .daysec = 86400, .esuDevi = 3, .esuMsaz = 5 };
pub const isoEpoc = isoz.isoEpoc;
fn chekHook(ctxz: *const cx.Ctxz) !fcts.Fact {
const outp = (try ctxz.tool(&.{ "git", "config", "core.hooksPath" }, &.{})) orelse return cx.mkfa("hook", .bloc, "git absent");
const got = cx.trim(outp.outz);
if (outp.code == 0 and std.mem.eql(u8, got, ctxz.conf.hook_path_main)) return cx.mkfa("hook", .okay, got);
return cx.mkfa("hook", .drif, try std.fmt.allocPrint(ctxz.allo, "hooksPath={s} want {s}", .{ got, ctxz.conf.hook_path_main }));
}
fn chekHead(ctxz: *const cx.Ctxz) !fcts.Fact {
const head = (try ctxz.tool(&.{ "git", "rev-parse", "HEAD" }, &.{})) orelse return cx.mkfa("head", .bloc, "git absent");
if (head.code != 0) return cx.mkfa("head", .bloc, "no commit yet");
const upst = (try ctxz.tool(&.{ "git", "rev-parse", "@{u}" }, &.{})) orelse return cx.mkfa("head", .bloc, "git absent");
if (upst.code != 0) return cx.mkfa("head", .bloc, "no upstream");
if (std.mem.eql(u8, cx.trim(head.outz), cx.trim(upst.outz))) return cx.mkfa("head", .okay, "HEAD = upstream");
return cx.mkfa("head", .drif, "HEAD differs from upstream");
}
fn chekTool(ctxz: *const cx.Ctxz) !fcts.Fact {
const outp = (try ctxz.tool(&.{ "zig", "version" }, &.{})) orelse return cx.mkfa("tool", .bloc, "zig absent");
const got = cx.trim(outp.outz);
if (outp.code == 0 and std.mem.eql(u8, got, ctxz.conf.zigz_vers_pinz)) return cx.mkfa("tool", .okay, try std.fmt.allocPrint(ctxz.allo, "zig {s}", .{got}));
return cx.mkfa("tool", .drif, try std.fmt.allocPrint(ctxz.allo, "zig {s} want {s}", .{ got, ctxz.conf.zigz_vers_pinz }));
}
fn chekAger(ctxz: *const cx.Ctxz, name: []const u8, maxz: i64, nomo: []const u8, nost: fcts.Stat) !fcts.Fact {
const stam = ctxz.stamGet(name) orelse return cx.mkfa(name, nost, nomo);
const ager = ctxz.nowz() - stam.when;
if (!stam.okay) return cx.mkfa(name, .drif, "last run failed");
if (ager > maxz) return cx.mkfa(name, .drif, try std.fmt.allocPrint(ctxz.allo, "age {d}s > {d}s", .{ ager, maxz }));
return cx.mkfa(name, .okay, try std.fmt.allocPrint(ctxz.allo, "age {d}s", .{ager}));
}
fn chekDril(ctxz: *const cx.Ctxz) !fcts.Fact {
const stam = ctxz.stamGet("dril") orelse return cx.mkfa("dril", .bloc, "no drill yet");
const ager = ctxz.nowz() - stam.when;
if (!stam.okay) return cx.mkfa("dril", .drif, "last drill failed");
if (ager > ctxz.conf.dril_ager_maxz) return cx.mkfa("dril", .drif, try std.fmt.allocPrint(ctxz.allo, "age {d}s > {d}s", .{ ager, ctxz.conf.dril_ager_maxz }));
if (stam.secs > ctxz.conf.dril_rtoz_maxz) return cx.mkfa("dril", .drif, try std.fmt.allocPrint(ctxz.allo, "rto {d}s > {d}s", .{ stam.secs, ctxz.conf.dril_rtoz_maxz }));
return cx.mkfa("dril", .okay, try std.fmt.allocPrint(ctxz.allo, "age {d}s rto {d}s", .{ ager, stam.secs }));
}
fn chekTail(ctxz: *const cx.Ctxz) !fcts.Fact {
const outp = (try ctxz.tool(&.{ "tailscale", "status", "--json" }, &.{})) orelse return cx.mkfa("tail", .bloc, "tailscale absent");
if (outp.code != 0) return cx.mkfa("tail", .bloc, "tailscale not running");
const root = std.json.parseFromSliceLeaky(std.json.Value, ctxz.allo, outp.outz, .{}) catch return cx.mkfa("tail", .bloc, "tailscale output is not JSON");
if (root != .object) return cx.mkfa("tail", .bloc, "tailscale output has no object");
const selz = root.object.get("Self") orelse return cx.mkfa("tail", .bloc, "tailscale has no Self");
if (selz != .object) return cx.mkfa("tail", .bloc, "tailscale Self is not an object");
const keyz = selz.object.get("KeyExpiry") orelse return cx.mkfa("tail", .okay, "key never expires");
if (keyz != .string) return cx.mkfa("tail", .okay, "key never expires");
const expi = isoEpoc(keyz.string) orelse return cx.mkfa("tail", .bloc, "KeyExpiry not parsable");
const left = @divFloor(expi - ctxz.nowz(), CF.daysec);
if (left < ctxz.conf.tail_days_minz) return cx.mkfa("tail", .drif, try std.fmt.allocPrint(ctxz.allo, "key expires in {d} days (min {d})", .{ left, ctxz.conf.tail_days_minz }));
return cx.mkfa("tail", .okay, try std.fmt.allocPrint(ctxz.allo, "key expires in {d} days", .{left}));
}
fn chekVers(ctxz: *const cx.Ctxz, name: []const u8, argv: []const []const u8, minz: []const u8, tool: []const u8) !fcts.Fact {
const outp = (try ctxz.tool(argv, &.{})) orelse return cx.mkfa(name, .bloc, try std.fmt.allocPrint(ctxz.allo, "{s} absent", .{tool}));
if (outp.code != 0) return cx.mkfa(name, .bloc, try std.fmt.allocPrint(ctxz.allo, "{s} version failed", .{tool}));
const got = vers.firstTok(outp.outz);
const ordr = vers.versComp(got, minz) orelse return cx.mkfa(name, .bloc, try std.fmt.allocPrint(ctxz.allo, "{s} version not parsable", .{tool}));
if (ordr == .lt) return cx.mkfa(name, .drif, try std.fmt.allocPrint(ctxz.allo, "{s} {s} below floor {s}", .{ tool, got, minz }));
return cx.mkfa(name, .okay, try std.fmt.allocPrint(ctxz.allo, "{s} {s} >= {s}", .{ tool, got, minz }));
}
fn chekLock(ctxz: *const cx.Ctxz) !fcts.Fact {
const outp = (try ctxz.tool(&.{ "tailscale", "lock", "status", "--json" }, &.{})) orelse return cx.mkfa("lock", .bloc, "tailscale absent");
if (outp.code != 0) return cx.mkfa("lock", .bloc, "tailscale not running");
const root = std.json.parseFromSliceLeaky(std.json.Value, ctxz.allo, outp.outz, .{}) catch return cx.mkfa("lock", .bloc, "lock status is not JSON");
if (root != .object) return cx.mkfa("lock", .bloc, "lock status has no object");
const enab = root.object.get("Enabled") orelse return cx.mkfa("lock", .bloc, "lock status has no Enabled");
if (enab == .bool and enab.bool) return cx.mkfa("lock", .okay, "Tailnet Lock on");
return cx.mkfa("lock", .drif, "Tailnet Lock off");
}
fn chekCpuz(ctxz: *const cx.Ctxz) !fcts.Fact {
const note = try std.fmt.allocPrint(ctxz.allo, "built for {s}", .{ctxz.cpum});
if (host.cpuOkay(ctxz.cpum, ctxz.conf.cpuz_okay_list)) return cx.mkfa("cpuz", .okay, note);
return cx.mkfa("cpuz", .drif, try std.fmt.allocPrint(ctxz.allo, "{s}: not a baseline CPU model (R20), rebuild with -Dcpu=baseline", .{note}));
}
fn chekPatc(ctxz: *const cx.Ctxz) !fcts.Fact {
const hosv = try host.patcLast(ctxz, ctxz.ostg);
switch (hosv) {
.when => |when| {
const days = @divFloor(ctxz.nowz() - when, CF.daysec);
if (days > ctxz.conf.patc_days_maxz) return cx.mkfa("patc", .drif, try std.fmt.allocPrint(ctxz.allo, "last OS patch {d} days ago > {d}", .{ days, ctxz.conf.patc_days_maxz }));
return cx.mkfa("patc", .okay, try std.fmt.allocPrint(ctxz.allo, "last OS patch {d} days ago", .{days}));
},
.unkn => |why| return cx.mkfa("patc", .bloc, why),
else => return cx.mkfa("patc", .skip, "n/a"),
}
}
fn chekEsus(ctxz: *const cx.Ctxz) !fcts.Fact {
const hosv = try host.esusCode(ctxz, ctxz.ostg);
switch (hosv) {
.valu => |valu| {
if (valu == CF.esuDevi or valu == CF.esuMsaz) return cx.mkfa("esus", .okay, try std.fmt.allocPrint(ctxz.allo, "ESU enrolled (ESUEligibility {d})", .{valu}));
return cx.mkfa("esus", .drif, try std.fmt.allocPrint(ctxz.allo, "ESU not enrolled (ESUEligibility {d})", .{valu}));
},
.unkn => |why| return cx.mkfa("esus", .bloc, why),
else => return cx.mkfa("esus", .skip, "n/a: not Windows"),
}
}
fn chekRun(ctxz: *const cx.Ctxz, name: []const u8) !fcts.Fact {
if (std.mem.eql(u8, name, "hook")) return chekHook(ctxz);
if (std.mem.eql(u8, name, "head")) return chekHead(ctxz);
if (std.mem.eql(u8, name, "tool")) return chekTool(ctxz);
if (std.mem.eql(u8, name, "wipz")) return chekAger(ctxz, "wipz", ctxz.conf.wipz_ager_maxz, "never pushed", .drif);
if (std.mem.eql(u8, name, "sync")) return chekAger(ctxz, "sync", ctxz.conf.sync_ager_maxz, "never synced", .drif);
if (std.mem.eql(u8, name, "bkup")) return chekAger(ctxz, "bkup", ctxz.conf.bkup_ager_maxz, "no backup job yet", .bloc);
if (std.mem.eql(u8, name, "bknt")) return chekAger(ctxz, "bknt", ctxz.conf.bknt_ager_maxz, "no nightly copy yet", .bloc);
if (std.mem.eql(u8, name, "dril")) return chekDril(ctxz);
if (std.mem.eql(u8, name, "tail")) return chekTail(ctxz);
if (std.mem.eql(u8, name, "tsfl")) return chekVers(ctxz, "tsfl", &.{ "tailscale", "version" }, ctxz.conf.tail_vers_minz, "tailscale");
if (std.mem.eql(u8, name, "clfl")) return chekVers(ctxz, "clfl", &.{ "claude", "--version" }, ctxz.conf.clau_vers_minz, "claude");
if (std.mem.eql(u8, name, "lock")) return chekLock(ctxz);
if (std.mem.eql(u8, name, "cpuz")) return chekCpuz(ctxz);
if (std.mem.eql(u8, name, "patc")) return chekPatc(ctxz);
if (std.mem.eql(u8, name, "esus")) return chekEsus(ctxz);
return cx.mkfa(name, .fail, "unknown check name in config");
}
fn chekAcpt(ctxz: *const cx.Ctxz, name: []const u8) !fcts.Fact {
const fact = try chekRun(ctxz, name);
if (fact.stat != .drif and fact.stat != .bloc) return fact;
for (ctxz.conf.doct_acpt_list) |acpt| if (std.mem.eql(u8, acpt, name)) return cx.mkfa(name, .okay, try std.fmt.allocPrint(ctxz.allo, "accepted risk: {s}", .{fact.note}));
return fact;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
_ = args;
const list = if (std.mem.eql(u8, ctxz.prof, "ci")) ctxz.conf.chek_ci_list else if (std.mem.eql(u8, ctxz.prof, "box")) ctxz.conf.chek_box_list else ctxz.conf.chek_t0_list;
var facts: std.ArrayList(fcts.Fact) = .empty;
for (list) |name| try facts.append(ctxz.allo, try chekAcpt(ctxz, name));
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
