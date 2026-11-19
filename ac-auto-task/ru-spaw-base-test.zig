// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for env var expansion
// Flo: fixed env map > expand commands > assert exact text
// I/O: command text + env map > expanded text
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const spaw = @import("ru-spaw-engi.zig");
const tszz = std.testing; const enviExpa = spaw.enviExpa; const cmdzBootUses = spaw.cmdzBootUses; const argvBuil = spaw.argvBuil; const shelPars = spaw.shelPars; const ShelKind = spaw.ShelKind;
fn mapzTest(allo: std.mem.Allocator) !std.process.Environ.Map { var mapz: std.process.Environ.Map = .init(allo); try mapz.put("FOO", "bar"); try mapz.put("USERNAME", "Admin"); try mapz.put("EMPTY", ""); return mapz; }
test "enviExpa substitutes defined vars" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "echo [%FOO%]", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("echo [bar]", resu); }
test "enviExpa leaves an UNDEFINED var exactly as written" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "echo [%NOPE_XYZ%]", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("echo [%NOPE_XYZ%]", resu); }
test "enviExpa honors %% as a literal percent" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "echo 100%% done", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("echo 100% done", resu); }
test "enviExpa leaves a lone trailing percent alone" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "echo 100%", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("echo 100%", resu); }
test "enviExpa does not touch %VAR:~a,b% substring syntax" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "echo %FOO:~0,1%", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("echo %FOO:~0,1%", resu); }
test "enviExpa expands an empty-valued var to nothing" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "echo [%EMPTY%]", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("echo []", resu); }
test "enviExpa preserves quotes, carets and pipes untouched" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const srcz = "dir \"C:\\Program Files\" /b | findstr ^Win"; const resu = try enviExpa(tszz.allocator, srcz, &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings(srcz, resu); }
test "enviExpa handles several vars in one command" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "%FOO%-%USERNAME%-%FOO%", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("bar-Admin-bar", resu); }
test "enviExpa on an empty string" { var mapz = try mapzTest(tszz.allocator); defer mapz.deinit(); const resu = try enviExpa(tszz.allocator, "", &mapz); defer tszz.allocator.free(resu); try tszz.expectEqualStrings("", resu); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
