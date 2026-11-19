// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for NDJSON event framing
// Flo: write event into fixed buffer > assert JSON escapes, shape, newline
// I/O: fake chunks and exit values > pass or fail
// ===================================================================
const std = @import("std"); const stre = @import("ru-outp-stre.zig"); const tszz = std.testing;
test "chunWrit escapes windows paths and quotes" { var bufz: [512]u8 = undefined; var wrtr: std.Io.Writer = .fixed(&bufz); try stre.outpWrit(&wrtr, "C:\\Users\\x\n\"quoted\""); const outp = wrtr.buffered(); try tszz.expect(std.mem.indexOf(u8, outp, "\\\\Users") != null); try tszz.expect(std.mem.indexOf(u8, outp, "\\\"quoted\\\"") != null); try tszz.expect(std.mem.endsWith(u8, outp, "}\n")); }
test "exitWrit shape" { var bufz: [256]u8 = undefined; var wrtr: std.Io.Writer = .fixed(&bufz); try stre.exitWrit(&wrtr, 0, 1240, "E:\\00_modules"); const outp = wrtr.buffered(); try tszz.expect(std.mem.startsWith(u8, outp, "{\"t\":\"exit\",\"code\":0,\"elapsed\":1240,\"cwd\":")); try tszz.expect(std.mem.endsWith(u8, outp, "}\n")); }
test "beatWrit is one line" { var bufz: [64]u8 = undefined; var wrtr: std.Io.Writer = .fixed(&bufz); try stre.beatWrit(&wrtr); try tszz.expectEqualStrings("{\"t\":\"hb\"}\n", wrtr.buffered()); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
