// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Turn raw hits into plan items: apply or skip by risk class
// Flo: kind + file risks > class bits > skip flag from config > count the plan
// I/O: Hit kind, path mask, file kind + Conf > Item {clas, mask, skip}; Item list > Summ counts
// ===================================================================
const cfgz = @import("cf-conf-load.zig");
const vari = @import("ut-path-vari.zig");
pub const Clas = enum(u4) { safe, comp, enco, bina, arch, sign, othe, syst, runn, sync, pack, urls, gitz };
pub const Item = struct { path: []const u8, line: u32, offz: usize, lenz: usize, kind: vari.Kind, clas: Clas, mask: u16 = 0, skip: bool, newz: []const u8 };
pub const Summ = struct { appl: usize = 0, skip: usize = 0, comp: usize = 0, enco: usize = 0, risk: usize = 0 };
pub const Decd = struct { clas: Clas, mask: u16, skip: bool };
pub fn bitOf(clas: Clas) u16 { return @as(u16, 1) << @intFromEnum(clas); }
pub fn clasOf(kind: vari.Kind) Clas { return switch (kind) { .nati, .fwds, .rela => .safe, .dbls, .urlz => .enco, .bare => .comp, .u16l => .bina }; }
pub fn skipOf(conf: cfgz.Conf, clas: Clas) bool {
return switch (clas) {
.safe => false,
.comp => conf.skip_comp_part,
.enco => conf.skip_enco_vari,
.bina => conf.skip_bina,
.arch => conf.skip_arch,
.sign => conf.skip_sign_hash,
.othe => conf.skip_othe_user,
.syst => conf.skip_syst_owne,
.runn => conf.skip_runn_proc,
.sync => conf.skip_sync_remo,
.pack => conf.skip_pack_mana,
.urls => conf.skip_urls_exte,
.gitz => conf.skip_gitz_hist,
};
}
pub fn firstOf(mask: u16) Clas {
const order = [_]Clas{ .sign, .arch, .gitz, .syst, .pack, .sync, .othe, .runn, .urls, .bina, .enco, .comp };
for (order) |clas| { if (mask & bitOf(clas) != 0) return clas; }
return .safe;
}
pub fn maskSkip(conf: cfgz.Conf, mask: u16) bool {
inline for (@typeInfo(Clas).@"enum".field_names, 0..) |_, indx| {
const clas: Clas = @enumFromInt(indx);
if (mask & bitOf(clas) != 0 and skipOf(conf, clas)) return true;
}
return false;
}
pub fn decide(conf: cfgz.Conf, pmask: u16, kind: vari.Kind, binz: bool, samz: bool) Decd {
var mask = pmask;
const kcls = clasOf(kind);
if (kcls != .safe) mask |= bitOf(kcls);
if (binz) mask |= bitOf(.bina);
var skip = maskSkip(conf, mask);
if (binz and !samz) skip = true;
return .{ .clas = firstOf(mask), .mask = mask, .skip = skip };
}
pub const Lkind = enum { link, regv, cron };
pub const Lref = struct { kind: Lkind, name: []const u8, oldv: []const u8, newv: []const u8, clas: Clas = .safe, mask: u16 = 0, skip: bool = false };
pub fn summL(lrefs: []const Lref) Summ {
var outz: Summ = .{};
for (lrefs) |lref| {
if (!lref.skip) { outz.appl += 1; continue; }
outz.skip += 1;
switch (lref.clas) { .comp => outz.comp += 1, .enco => outz.enco += 1, .safe => {}, else => outz.risk += 1 }
}
return outz;
}
pub fn summAdd(left: Summ, righ: Summ) Summ { return .{ .appl = left.appl + righ.appl, .skip = left.skip + righ.skip, .comp = left.comp + righ.comp, .enco = left.enco + righ.enco, .risk = left.risk + righ.risk }; }
pub fn summOf(items: []const Item) Summ {
var outz: Summ = .{};
for (items) |item| {
if (!item.skip) { outz.appl += 1; continue; }
outz.skip += 1;
switch (item.clas) { .comp => outz.comp += 1, .enco => outz.enco += 1, .safe => {}, else => outz.risk += 1 }
}
return outz;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
