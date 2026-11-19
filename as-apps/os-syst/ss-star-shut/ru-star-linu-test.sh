# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for ru-star-linu.sh with fake apps
# Flo: fixture > bad arg > dry-run > status > real run > check each launch
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-star-linu-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- star-linu"
bash "$app/ru-star-linu.sh" --bogus >/dev/null 2>&1; chk "ru-star-linu bad arg exits 2" test $? -eq 2
: > "$logz"; bash "$app/ru-star-linu.sh" --dry-run > "$tmpz/o1.txt"
chk "dry-run opens nothing" test ! -s "$logz"
chk "dry-run lists 7 opens" test "$(grep -c '    open:' "$tmpz/o1.txt")" -eq 7
chk "status finds nemo" bash -c "bash '$app/ru-star-linu.sh' status | grep -q 'found   : nemo'"
SECONDS=0; bash "$app/ru-star-linu.sh" > "$tmpz/o2.txt"; took=$SECONDS; sleep 1
chk "returns while Chrome runs" test "$took" -lt 6
chk "file manager called" grep -q "nemo $HOME/work" "$logz"
chk "chrome p3 called" grep -q "google-chrome --user-data-dir=$tmpz/chrome/launcher-p3 --class=profile3 --start-maximized" "$logz"
chk "chrome p2 called" grep -q "google-chrome --user-data-dir=$tmpz/chrome/launcher-p2 --class=profile2" "$logz"
chk "missing profile warned" grep -q "WARN Chrome launcher missing: p99" "$tmpz/o2.txt"
chk "cmd-run started on port" grep -q "cmd-run 39030" "$logz"
chk "cmd-run opens as chrome tab" grep -q "launcher-p3 --class=profile3 http://127.0.0.1:39030" "$logz"
chk "no electron panel" bash -c "! grep -qi 'electron\\|open-mini\\|ui-mini' '$logz' '$tmpz/o2.txt'"
chk "vscode called" grep -q "code $HOME/work" "$logz"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
