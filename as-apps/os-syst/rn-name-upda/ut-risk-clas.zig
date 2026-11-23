// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Flag risky places and files by path and name
// Flo: path parts > git, sync, system, package, other user > file name > signed, archive > class bit mask
// I/O: normalized path + Conf lists + home > u16 mask (one bit per risk class)
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const cfgz = @import("cf-conf-load.zig");
const plan = @import("pl-plan-buil.zig");
fn under(osy: osys.Osys, path: []const u8, list: []const []const u8) bool { for (list) |item| { if (osys.insid(osy, path, item)) return true; } return false; }
fn suffz(osy: osys.Osys, name: []const u8, list: []const []const u8) bool { for (list) |item| { if (osys.hasSuf(osy, name, item)) return true; } return false; }
pub fn pathMask(osy: osys.Osys, conf: cfgz.Conf, home: []const u8, path: []const u8) u16 {
var mask: u16 = 0;
if (std.mem.startsWith(u8, path, "//")) mask |= plan.bitOf(.sync);
var iter = std.mem.splitScalar(u8, path[osys.rootOf(path).len..], '/');
while (iter.next()) |part| {
if (osys.eqlz(osy, part, ".git")) mask |= plan.bitOf(.gitz);
for (conf.risk_sync_list) |item| { if (osys.hasPre(osy, part, item)) mask |= plan.bitOf(.sync); }
}
if (under(osy, path, conf.risk_syst_list)) mask |= plan.bitOf(.syst);
if (under(osy, path, conf.risk_pack_list)) mask |= plan.bitOf(.pack);
for (conf.risk_user_list) |root| {
if (osys.insid(osy, path, root) and !osys.eqlz(osy, path, root) and (home.len == 0 or !osys.insid(osy, path, home))) mask |= plan.bitOf(.othe);
}
const name = osys.baseOf(path);
if (suffz(osy, name, conf.risk_sign_list)) mask |= plan.bitOf(.sign);
if (suffz(osy, name, conf.risk_arch_list)) mask |= plan.bitOf(.arch);
return mask;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
