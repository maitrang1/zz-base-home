// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Zalo-like simulator page for tests: embeds markup + two scripts
// Flo: embed html, core js, more js > join into one page text
// I/O: allocator (caller) > html text for te-mock-page.start
// ===================================================================
const std = @import("std");
const CF = .{ .markup = @embedFile("ht-zsim-main.html"), .core = @embedFile("js-zsim-core.js"), .more = @embedFile("js-zsim-more.js") };
pub fn html(allo: std.mem.Allocator) ![]u8 { return std.fmt.allocPrint(allo, "{s}<script>{s}\n{s}</script>", .{ CF.markup, CF.core, CF.more }); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
