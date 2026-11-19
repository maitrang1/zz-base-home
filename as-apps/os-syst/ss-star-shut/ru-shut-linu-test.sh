# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for ru-shut-linu.sh with fake apps, fake power-off
# Flo: fixture > dry-run > refusals > cancel key > real close > check each effect
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-linu-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- shut-linu"
bash "$app/ru-shut-linu.sh" --bogus >/dev/null 2>&1; chk "ru-shut-linu bad arg exits 2" test $? -eq 2
: > "$logz"
printf '"exit_type":"Crashed","exited_cleanly":false' > "$tmpz/chrome/launcher-p3/Profile 3/Preferences"
printf '"exited_cleanly":false' > "$tmpz/chrome/launcher-p3/Local State"
sumz=$(cksum "$tmpz/chrome/launcher-p3/Profile 3/Preferences" "$tmpz/chrome/launcher-p3/Local State")
bash "$app/ru-shut-linu.sh" --dry-run > "$tmpz/c1.txt"
chk "dry-run closes nothing" test ! -s "$logz"
chk "dry-run lists editor" grep -q "close: 0x01" "$tmpz/c1.txt"
chk "dry-run kills nothing" kill -0 "$slpz"
chk "dry-run edits no file" test "$(cksum "$tmpz/chrome/launcher-p3/Profile 3/Preferences" "$tmpz/chrome/launcher-p3/Local State")" == "$sumz"
SYNC_CMDZ=/nonexistent/tool bash "$app/ru-shut-linu.sh" --dry-run > "$tmpz/c3.txt" 2>&1; chk "missing save tool warns and goes on" grep -q "WARN save skipped" "$tmpz/c3.txt"
touch "$tmpz/nox"; bash "$app/ru-shut-linu.sh" --auto >/dev/null 2>&1; rc=$?; rm -f "$tmpz/nox"
chk "no X display refused" test $rc -eq 1
XDG_SESSION_TYPE=wayland bash "$app/ru-shut-linu.sh" --auto >/dev/null 2>&1; chk "wayland refused" test $? -eq 1
POWE_CMDZ=no-such-poweroff-cmd bash "$app/ru-shut-linu.sh" --auto >/dev/null 2>&1; chk "missing power cmd refused" test $? -eq 1
chk "refusals did nothing" test ! -s "$logz"
if command -v script >/dev/null 2>&1; then (sleep 0.4; printf x) | script -qec "bash '$app/ru-shut-linu.sh'" /dev/null >/dev/null 2>&1; rc=$?; chk "cancel key stops run" test $rc -eq 0; chk "cancel did nothing" test ! -s "$logz"; fi
bash "$app/ru-shut-linu.sh" --auto > "$tmpz/c2.txt" 2>&1
chk "work save called in the work folder" grep -q "sync wipz --live @$HOME/work" "$logz"
chk "editor window closed" grep -q "wmctrl -ic 0x01" "$logz"
chk "own ancestor skipped" bash -c "! grep -q 'wmctrl -ic 0x02' '$logz'"
chk "panel window skipped" bash -c "! grep -q 'wmctrl -ic 0x03' '$logz'"
chk "stuck app got SIGTERM" bash -c "sleep 0.5; ! kill -0 $slpz 2>/dev/null"
chk "survivor window warned" grep -q "WARN still open: 0x01" "$tmpz/c2.txt"
chk "poweroff called once" test "$(grep -c '^systemctl poweroff' "$logz")" -eq 1
chk "Preferences fixed" grep -q '"exit_type":"Normal","exited_cleanly":true' "$tmpz/chrome/launcher-p3/Profile 3/Preferences"
chk "Local State fixed" grep -q '"exited_cleanly":true' "$tmpz/chrome/launcher-p3/Local State"
chk "no tty without --auto" bash -c "bash '$app/ru-shut-linu.sh' </dev/null >/dev/null 2>&1; test \$? -eq 2"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
