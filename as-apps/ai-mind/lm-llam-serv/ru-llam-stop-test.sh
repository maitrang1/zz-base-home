# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for ru-llam-stop.sh: watchdog, lock safety, port owner
# Flo: fixture > stop a real watchdog > stale lock > foreign port owner
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-stop-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- llam-stop"
bash "$app/ru-llam-watc.sh" & wp=$!; kids="$wp"; sleep 1.2
bash "$app/ru-llam-stop.sh"; chk "stop exits 0" test $? -eq 0; sleep 0.4
chk "watchdog is gone" bash -c "! kill -0 $wp 2>/dev/null"
chk "lock is gone" test ! -e "$TMPDIR/aisv-watchdog-$port.lock"
wait "$wp" 2>/dev/null
sleep 60 & sp=$!; kids="$sp"; echo "$sp" > "$TMPDIR/aisv-watchdog-$port.lock"
out=$(bash "$app/ru-llam-stop.sh" 2>&1); chk "stale lock: foreign pid not killed" kill -0 "$sp"
chk "stale lock: says so" grep -q "not a watchdog" <<< "$out"
chk "stale lock: file removed" test ! -e "$TMPDIR/aisv-watchdog-$port.lock"
kill "$sp" 2>/dev/null; wait "$sp" 2>/dev/null
if command -v python3 >/dev/null 2>&1 && command -v ss >/dev/null 2>&1; then python3 -m http.server "$port" --bind 127.0.0.1 >/dev/null 2>&1 & hp=$!; kids="$hp"; sleep 1; out=$(bash "$app/ru-llam-stop.sh" 2>&1); chk "other port owner left running" kill -0 "$hp"; chk "other port owner is named" grep -q "left running" <<< "$out"; kill "$hp" 2>/dev/null; wait "$hp" 2>/dev/null; fi
AISV_CONF="$tmpz/none.env" bash "$app/ru-llam-stop.sh" >/dev/null 2>&1; chk "bad settings file exits 1" test $? -eq 1
chk "unknown role exits 1" bash -c "! bash '$app/ru-llam-stop.sh' bogus >/dev/null 2>&1"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
