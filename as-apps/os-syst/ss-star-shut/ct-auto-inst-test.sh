# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for ct-auto-inst.sh: login entry, status, remove
# Flo: fixture > bad arg > install > status > remove > check rename
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ct-auto-inst-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- autostart"
bash "$app/ct-auto-inst.sh" --bogus >/dev/null 2>&1; chk "ct-auto-inst bad arg exits 2" test $? -eq 2
bash "$app/ct-auto-inst.sh" >/dev/null
chk "desktop file written" grep -q "Exec=bash \"$app/ru-star-linu.sh\"" "$XDG_CONFIG_HOME/autostart/linux-machine-startup-shutdown.desktop"
chk "status says ON" bash -c "bash '$app/ct-auto-inst.sh' status | grep -q 'autostart: ON'"
bash "$app/ct-auto-inst.sh" --remove >/dev/null
chk "remove renames to .off" test -f "$XDG_CONFIG_HOME/autostart/linux-machine-startup-shutdown.desktop.off"
chk "remove deletes nothing" test ! -f "$XDG_CONFIG_HOME/autostart/linux-machine-startup-shutdown.desktop"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
