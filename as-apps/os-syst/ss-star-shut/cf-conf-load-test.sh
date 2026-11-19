# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for cf-conf-load.sh: keys, numbers, env override
# Flo: fixture > good config > unknown key > bad numbers > empty power cmd > override
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/cf-conf-load-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- conf-load"
chk "good config passes" bash "$app/cf-conf-load.sh" --check
printf 'BOGU_KEYZ=1\n' > "$tmpz/bad1.env"; out=$(bash "$app/cf-conf-load.sh" --check "$tmpz/bad1.env" 2>&1); rc=$?
chk "unknown key refused" test $rc -eq 1
chk "error names line 1" grep -q "line 1" <<< "$out"
printf 'COUN_SECO=abc\n' > "$tmpz/bad2.env"; chk "bad number refused" bash -c "! bash '$app/cf-conf-load.sh' --check '$tmpz/bad2.env' >/dev/null 2>&1"
printf 'COUN_SECO=09\n' > "$tmpz/bad3.env"; chk "leading zero refused" bash -c "! bash '$app/cf-conf-load.sh' --check '$tmpz/bad3.env' >/dev/null 2>&1"
printf 'POWE_CMDZ=\n' > "$tmpz/bad4.env"; chk "empty power cmd refused" bash -c "! bash '$app/cf-conf-load.sh' --check '$tmpz/bad4.env' >/dev/null 2>&1"
chk "env overrides file" bash -c "COUN_SECO=7 bash '$app/cf-conf-load.sh' --check | grep -q 'COUN_SECO = 7'"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
