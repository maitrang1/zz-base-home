// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Exit-code ladder shared by every wo command
// Flo: name each code > exit with one
// I/O: Code enum > process exit status
// ===================================================================
const std = @import("std");
pub const Code = enum(u8) { okay = 0, fail = 1, usag = 2, drif = 3, bloc = 4 };
pub const Erro = error{Usag};
pub fn exitz(code: Code) noreturn { std.process.exit(@intFromEnum(code)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
