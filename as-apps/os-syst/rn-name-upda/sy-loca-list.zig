// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: One door to every non-file location (links, registry, crontab)
// Flo: collect by OS > apply a new value > read the current value > restore an old value > reload hint after unit files change
// I/O: Ctxz + Lref > Lref list, values on the system; every OS tool goes through the runner
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const walk = @import("se-scan-walk.zig");
const plan = @import("pl-plan-buil.zig");
const wind = @import("sy-loca-wind.zig");
const cron = @import("sy-loca-cron.zig");
const link = @import("sy-link-kind.zig");
const unit_exts = [_][]const u8{ ".service", ".timer", ".socket", ".mount", ".path" };
pub fn collect(ctxz: *const cx.Ctxz, targ: walk.Targ, outc: *walk.Outc) !void {
if (!ctxz.conf.loca_on) return;
if (ctxz.osy.wind) try wind.collect(ctxz, targ, outc) else try cron.collect(ctxz, targ, outc);
}
pub fn setz(ctxz: *const cx.Ctxz, kind: plan.Lkind, name: []const u8, value: []const u8, tag: []const u8) !void {
switch (kind) {
.link => try link.setz(ctxz, name, value, tag),
.regv => try wind.setz(ctxz, name, value),
.cron => try cron.setz(ctxz, value, tag),
}
}
pub fn current(ctxz: *const cx.Ctxz, kind: plan.Lkind, name: []const u8) ![]const u8 {
return switch (kind) {
.link => link.currentz(ctxz, name),
.regv => wind.current(ctxz, name),
.cron => cron.current(ctxz),
};
}
pub fn kindOf(text: []const u8) ?plan.Lkind { return std.meta.stringToEnum(plan.Lkind, text); }
pub fn reload(ctxz: *const cx.Ctxz, paths: []const []const u8) []const u8 {
var unit = false;
var plst = false;
for (paths) |path| {
for (unit_exts) |ext| { if (std.mem.endsWith(u8, path, ext)) unit = true; }
if (std.mem.endsWith(u8, path, ".plist")) plst = true;
}
if (unit and !ctxz.osy.wind) {
const outp = ctxz.runn.exec(ctxz.allo, &.{ "systemctl", "--user", "daemon-reload" }, &.{}) catch return "unit files changed: run systemctl daemon-reload";
if (outp.code != 0) return "unit files changed: run systemctl daemon-reload";
return "systemd user units reloaded";
}
if (plst) return "plist files changed: reload with launchctl bootout + bootstrap";
return "";
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
