// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Decide if a text match is a whole path or a piece of a word
// Flo: look at the byte before > look at the byte after > allow or reject
// I/O: text + match offset/length + kind > bool
// ===================================================================
const std = @import("std");
const vari = @import("ut-path-vari.zig");
fn nameChar(byte: u8) bool { return std.ascii.isAlphanumeric(byte) or byte == '_' or byte == '-'; }
pub fn okBefore(kind: vari.Kind, text: []const u8, offz: usize) bool {
if (offz == 0) return true;
const prev = text[offz - 1];
if (kind == .urlz) return !std.ascii.isAlphanumeric(prev);
return !(nameChar(prev) or prev == '.' or prev == '/' or prev == '\\');
}
pub fn okAfter(text: []const u8, endz: usize) bool {
if (endz >= text.len) return true;
const next = text[endz];
if (next == '/' or next == '\\') return true;
if (nameChar(next)) return false;
if (next == '.') return endz + 1 >= text.len or !nameChar(text[endz + 1]);
return true;
}
pub fn okMatc(kind: vari.Kind, text: []const u8, offz: usize, lenz: usize) bool { return okBefore(kind, text, offz) and okAfter(text, offz + lenz); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
