// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for the auto-run command line
// Flo: build command for ids > assert quoting and refusal
// I/O: root + id > shell command or null
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const stor = @import("tk-task-stor.zig");
const tszz = std.testing; const Task = stor.Task; const Reje = stor.Reje; const vali = stor.vali; const norm = stor.norm; const chaiFind = stor.chaiFind; const idenVali = stor.idenVali; const autoRunz = stor.autoRunz;
fn testJson(allo: std.mem.Allocator, text: []const u8) std.json.Value { return std.json.parseFromSliceLeaky(std.json.Value, allo, text, .{}) catch unreachable; }
test "autoRunz builds the cmds command and rejects unsafe ids" { const allo = tszz.allocator; const wind = builtin.os.tag == .windows; const gotz = (try autoRunz(allo, if (wind) "E:\\hub" else "/hub", "git-sync-01")).?; defer allo.free(gotz); try tszz.expectEqualStrings(if (wind) "E:\\hub\\ba-cmds-wind.bat git-sync-01" else "bash /hub/sh-cmds-linu.sh git-sync-01", gotz); for ([_][]const u8{ "", "a b", "a;b", "a&b", "a'b", "a$b", "a|b", "a\"b", "a`b" }) |badz| { try tszz.expect((try autoRunz(allo, if (wind) "E:\\hub" else "/hub", badz)) == null); } }
test "autoRunz quotes a script path that has a space" { const allo = tszz.allocator; const wind = builtin.os.tag == .windows; const gotz = (try autoRunz(allo, if (wind) "E:\\my hub" else "/my hub", "x")).?; defer allo.free(gotz); try tszz.expectEqualStrings(if (wind) "\"E:\\my hub\\ba-cmds-wind.bat\" x" else "bash '/my hub/sh-cmds-linu.sh' x", gotz); }
test "jobzFileSet accepts a plain json name and refuses paths, dots and other types" { const tkb = @import("tk-stor-base.zig"); const keep = tkb.jobzFile; defer tkb.jobzFile = keep; try tszz.expect(tkb.jobzFileSet("aa-auto-task-li01.json")); try tszz.expectEqualStrings("aa-auto-task-li01.json", tkb.jobzFile); try tszz.expect(!tkb.jobzFileSet("")); try tszz.expect(!tkb.jobzFileSet("x.txt")); try tszz.expect(!tkb.jobzFileSet("sub/a.json")); try tszz.expect(!tkb.jobzFileSet("a..b.json")); try tszz.expectEqualStrings("aa-auto-task-li01.json", tkb.jobzFile); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
