// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Turn raw hits into plan items: apply or skip by class
// Flo: kind > class > skip flag from config > count the plan
// I/O: Hit kind + Conf > Item {class, skip}; Item list > Summ counts
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const vari = @import("ut-path-vari.zig");
pub const Clas = enum { safe, comp, enco };
pub const Item = struct { path: []const u8, line: u32, offz: usize, lenz: usize, kind: vari.Kind, clas: Clas, skip: bool, newz: []const u8 };
pub const Summ = struct { appl: usize = 0, skip: usize = 0, comp: usize = 0, enco: usize = 0 };
pub fn clasOf(kind: vari.Kind) Clas { return switch (kind) { .nati, .fwds, .rela => .safe, .dbls, .urlz => .enco, .bare => .comp }; }
pub fn skipOf(conf: cfgz.Conf, clas: Clas) bool { return switch (clas) { .safe => false, .comp => conf.skip_comp_part, .enco => conf.skip_enco_vari }; }
pub fn summOf(items: []const Item) Summ {
var outz: Summ = .{};
for (items) |item| {
if (!item.skip) { outz.appl += 1; continue; }
outz.skip += 1;
switch (item.clas) { .comp => outz.comp += 1, .enco => outz.enco += 1, .safe => {} }
}
return outz;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
