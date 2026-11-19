// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Probe consts, kinds, conditions, size and time parse
// Flo: consts > enums > parse size/duration strings
// I/O: spec text > bytes or ms, Kind/Cond tags
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const spawn = @import("spawn"); const netz = std.Io.net;
pub const CF = .{ .poll_fast_msec = 10_000, .poll_midz_msec = 30_000, .poll_slow_msec = 60_000, .http_head_maxz = 2048, .conn_time_msec = 3000 };
pub const ArmzErro = error{ NeedsSpec, BadPort, BadHost, BadUrl, BadSize, BadDuration, BadProc, BadPowerSpec, NotProbeType };
pub const Kind = enum { aliv, disk, emai, idle, powe, proc, tcpz, webz };
pub const Cond = enum { unkn, offz, onzz };
pub fn sizePars(spec: []const u8) ?u64 { if (spec.len == 0) return null; var endz: usize = 0; while (endz < spec.len and std.ascii.isDigit(spec[endz])) endz += 1; if (endz == 0) return null; const numb = std.fmt.parseInt(u64, spec[0..endz], 10) catch return null; const unit = std.mem.trim(u8, spec[endz..], " \t"); var mult: u64 = 1; if (unit.len == 0) { mult = 1; } else if (std.ascii.eqlIgnoreCase(unit, "b")) { mult = 1; } else if (std.ascii.eqlIgnoreCase(unit, "k") or std.ascii.eqlIgnoreCase(unit, "kb")) { mult = 1024; } else if (std.ascii.eqlIgnoreCase(unit, "m") or std.ascii.eqlIgnoreCase(unit, "mb")) { mult = 1024 * 1024; } else if (std.ascii.eqlIgnoreCase(unit, "g") or std.ascii.eqlIgnoreCase(unit, "gb")) { mult = 1024 * 1024 * 1024; } else if (std.ascii.eqlIgnoreCase(unit, "t") or std.ascii.eqlIgnoreCase(unit, "tb")) { mult = 1024 * 1024 * 1024 * 1024; } else { return null; } const prod = @mulWithOverflow(numb, mult); if (prod[1] != 0) return null; return prod[0]; }
pub fn duraPars(spec: []const u8) ?u64 { if (spec.len == 0) return null; var endz: usize = 0; while (endz < spec.len and std.ascii.isDigit(spec[endz])) endz += 1; if (endz == 0) return null; const numb = std.fmt.parseInt(u64, spec[0..endz], 10) catch return null; const unit = std.mem.trim(u8, spec[endz..], " \t"); var mult: u64 = 60_000; if (unit.len == 0) { mult = 60_000; } else if (std.ascii.eqlIgnoreCase(unit, "s")) { mult = 1000; } else if (std.ascii.eqlIgnoreCase(unit, "m")) { mult = 60_000; } else if (std.ascii.eqlIgnoreCase(unit, "h")) { mult = 3_600_000; } else { return null; } const prod = @mulWithOverflow(numb, mult); if (prod[1] != 0) return null; if (prod[0] == 0) return null; return prod[0]; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
