// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Edge probes: re-exports base, plat, net, type, armz parts
// Flo: arm spec once > poll on own stagger (10s idle/powe, 30s disk/proc/live, 60s tcpr/webs/mail) > sense > off to on fires; unknown never fires; first read is baseline
// I/O: spec per type (tcpr host:port, webs url, disk path<10GB, proc/live name.exe, idle 15m, powe battery; task store) > Prob + due verdict (ticker), or ArmzErro; webs https rejected at arm; mail arms unwired, never fires
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const spawn = @import("spawn"); const netz = std.Io.net;
const evprobbase = @import("ev-prob-base.zig"); const evprobplat = @import("ev-prob-plat.zig"); const evprobnetw = @import("ev-prob-netw.zig"); const evprobtype = @import("ev-prob-type.zig"); const evprobarmz = @import("ev-prob-armz.zig"); 
pub const ArmzErro = evprobbase.ArmzErro; pub const CF = evprobbase.CF; pub const Cond = evprobbase.Cond; pub const Kind = evprobbase.Kind; pub const duraPars = evprobbase.duraPars; pub const sizePars = evprobbase.sizePars; 
pub const battOnzz = evprobplat.battOnzz; pub const freeByte = evprobplat.freeByte; pub const idleMsec = evprobplat.idleMsec; pub const procRunn = evprobplat.procRunn; 
pub const ipzzLiteChec = evprobnetw.ipzzLiteChec; pub const statPars = evprobnetw.statPars; pub const winzConnCond = evprobnetw.winzConnCond; 
pub const Prob = evprobtype.Prob; 
pub const probArmz = evprobarmz.probArmz; pub const probTypeChec = evprobarmz.probTypeChec; 
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
