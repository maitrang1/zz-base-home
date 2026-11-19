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
var test_iozz_impl = std.Io.Threaded.init_single_threaded;
test "Sess delz drops one tab and leaves the others" { const iozz: std.Io = test_iozz_impl.io(); const allo = tszz.allocator; var sess: cwdz.Sess = .{}; defer sess.dein(allo); try sess.setz(allo, iozz, "t1", "/one"); try sess.setz(allo, iozz, "t2", "/two"); try sess.delz(allo, iozz, "t1"); try tszz.expect((try sess.getz(iozz, "t1")) == null); try tszz.expectEqualStrings("/two", (try sess.getz(iozz, "t2")).?); }
test "Sess delz on an unknown tab is harmless, and a tab can be set again after delz" { const iozz: std.Io = test_iozz_impl.io(); const allo = tszz.allocator; var sess: cwdz.Sess = .{}; defer sess.dein(allo); try sess.delz(allo, iozz, "nope"); try sess.setz(allo, iozz, "t1", "/one"); try sess.delz(allo, iozz, "t1"); try sess.setz(allo, iozz, "t1", "/again"); try tszz.expectEqualStrings("/again", (try sess.getz(iozz, "t1")).?); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
