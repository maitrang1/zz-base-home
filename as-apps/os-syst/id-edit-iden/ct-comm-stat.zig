// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: ie stat: version, repo, hub, job files, last run (read-only)
// Flo: read config + hub config + job files > ask the hub > last run state > print
// I/O: none > text or JSON on stdout; nothing written
// Run: E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\ie.exe stat
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const stor = @import("st-runz-stor.zig");
const jour = @import("lg-jour-writ.zig");
const jz = @import("tk-jobz-read.zig");
const hub = @import("tk-hubz-conf.zig");
const hz = @import("sy-hubz-chec.zig");
const osys = @import("ut-osys-adap.zig");
pub const CF = .{ .vers = "0.1.0" };
const Outj = struct { ok: bool, cmd: []const u8, exit: u8, vers: []const u8, osys: []const u8, repo: []const u8, data: []const u8, hub_port: u16, hub_data: []const u8, hub_up: bool, job_files: usize, job_ids: usize, step_ids: usize, unresolved: usize, last_run: []const u8, last_state: []const u8 };
pub fn comm(ctxz: *const cx.Ctxz, tail: []const []const u8) !exit.Code {
if (tail.len != 0) return exit.Erro.Usag;
const allo = ctxz.allo;
const jobs = try jz.loadAll(allo, ctxz.iozz, ctxz.repo, ctxz.conf);
const hubz = try hub.load(allo, ctxz.iozz, ctxz.conf, ctxz.repo, ctxz.home);
var nids: usize = 0;
var nstp: usize = 0;
for (jobs) |job| for (job.rows) |row| { nids += 1; if (row.ids) |idsz| nstp += idsz.len; };
const unre = try jz.unresolved(allo, ctxz.iozz, ctxz.repo, ctxz.conf, try jz.calls(allo, jobs));
const upz = hz.snap(ctxz, hubz.port).up;
const data = try ctxz.dirzData();
var lrun: []const u8 = "none";
var lsta: []const u8 = "none";
if (try stor.idLast(ctxz)) |last| {
lrun = last;
const pth = try stor.pthsOf(ctxz, last);
lsta = if (jour.readAll(allo, ctxz.iozz, pth.jfil)) |ents| @tagName(jour.stateOf(ents)) else |_| "unreadable";
}
const open = std.mem.eql(u8, lsta, "open");
const code: exit.Code = if (open) .find else .okay;
const osnm = if (osys.wind) "windows" else "unix";
if (ctxz.ladd.json) {
const outj: Outj = .{ .ok = code == .okay, .cmd = "stat", .exit = @intFromEnum(code), .vers = CF.vers, .osys = osnm, .repo = ctxz.repo, .data = data, .hub_port = hubz.port, .hub_data = hubz.data, .hub_up = upz, .job_files = jobs.len, .job_ids = nids, .step_ids = nstp, .unresolved = unre.len, .last_run = lrun, .last_state = lsta };
try ctxz.outw.print("{s}\n", .{try std.json.Stringify.valueAlloc(allo, outj, .{})});
return code;
}
try ctxz.outw.print("ie {s} · {s} · repo {s}\ndata {s}\nhub port {d} ({s}) · data {s}\njob files {d} · job ids {d} · chain steps {d} · steps without a dispatcher {d}\nlast run {s}: {s}\n", .{ CF.vers, osnm, ctxz.repo, data, hubz.port, if (upz) "up" else "down", hubz.data, jobs.len, nids, nstp, unre.len, lrun, lsta });
if (open) try ctxz.outw.print("open run: ie undo {s} --live --force\n", .{lrun});
return code;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
