// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for cd token and separator matching
// Flo: feed cd command strings > assert token match > assert separator strip
// I/O: Fixed cmd strings > pass or fail
// ===================================================================
const std = @import("std"); const cwdz = @import("ru-sess-cwdz.zig");
const tszz = std.testing; const cdzzTokeEndz = cwdz.cdzzTokeEndz; const sepaStri = cwdz.sepaStri;
test "cdzzTokeEndz recognizes forms" { try tszz.expect(cdzzTokeEndz("cd") != null); try tszz.expect(cdzzTokeEndz("cd E:\\00_modules") != null); try tszz.expect(cdzzTokeEndz("cd /d E:\\00_modules") != null); try tszz.expect(cdzzTokeEndz("pushd E:\\00_modules") != null); try tszz.expect(cdzzTokeEndz("cdrom") == null); try tszz.expect(cdzzTokeEndz("git status") == null); }
test "sepaStri removes leading joins" { try tszz.expectEqualStrings("npm start", sepaStri("&& npm start")); try tszz.expectEqualStrings("npm start", sepaStri("; npm start")); try tszz.expectEqualStrings("npm start", sepaStri("npm start")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
