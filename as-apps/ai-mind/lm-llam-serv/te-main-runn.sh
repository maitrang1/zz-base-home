# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Run every *-test.sh and sum the results
# Flo: list tests > run each in its own temp home > add up passed/failed > exit 0 only if none failed
# I/O: none > PASS/FAIL lines + "N passed, M failed", exit 0 or 1
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/te-main-runn.sh
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
passz=0; failz=0
for tst in cf-llam-load-test.sh ru-llam-watc-test.sh ru-llam-stop-test.sh; do out=$(bash "$dirz/$tst" 2>&1); echo "$out" | grep -v "^$" | grep -v "passed, .* failed"; sub=$(grep -a "passed, .* failed" <<< "$out" | tail -1); passz=$((passz + $(sed 's/ passed.*//' <<< "${sub:-0 passed}"))); failz=$((failz + $(sed 's/.*, \([0-9]*\) failed.*/\1/' <<< "${sub:-0 passed, 1 failed}"))); done
echo; echo "$passz passed, $failz failed"
test "$failz" -eq 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
