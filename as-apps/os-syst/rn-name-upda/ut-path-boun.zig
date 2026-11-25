// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tell a whole-path match from a word piece
// Flo: look at the byte before > look at the byte after > allow or reject (utf16 looks at the low byte of each unit)
// I/O: text + match offset/length + kind > bool
// ===================================================================
const std = @import("std");
const vari = @import("ut-path-vari.zig");
fn nameChar(byte: u8) bool { return std.ascii.isAlphanumeric(byte) or byte == '_' or byte == '-'; }
fn befoByte(kind: vari.Kind, prev: u8) bool {
if (kind == .urlz) return !std.ascii.isAlphanumeric(prev);
return !(nameChar(prev) or prev == '.' or prev == '/' or prev == '\\');
}
fn afteByte(next: u8, nex2: ?u8) bool {
if (next == '/' or next == '\\') return true;
if (nameChar(next)) return false;
if (next == '.') return nex2 == null or !nameChar(nex2.?);
return true;
}
pub fn okBefore(kind: vari.Kind, text: []const u8, offz: usize) bool {
if (kind == .u16l) {
if (offz < 2) return true;
return text[offz - 1] != 0 or befoByte(.nati, text[offz - 2]);
}
if (offz == 0) return true;
return befoByte(kind, text[offz - 1]);
}
pub fn okAfter(text: []const u8, endz: usize) bool {
if (endz >= text.len) return true;
return afteByte(text[endz], if (endz + 1 < text.len) text[endz + 1] else null);
}
pub fn okAfterU16(text: []const u8, endz: usize) bool {
if (endz + 1 >= text.len) return true;
if (text[endz + 1] != 0) return true;
return afteByte(text[endz], if (endz + 3 < text.len and text[endz + 3] == 0) text[endz + 2] else null);
}
pub fn okMatc(kind: vari.Kind, text: []const u8, offz: usize, lenz: usize) bool {
if (kind == .u16l) return okBefore(kind, text, offz) and okAfterU16(text, offz + lenz);
return okBefore(kind, text, offz) and okAfter(text, offz + lenz);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
