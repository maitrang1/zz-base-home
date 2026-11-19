# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Shared test fixture: temp home, fake apps, helpers
# Flo: temp dir > fake apps + wmctrl > test config > copy scripts > chk helpers
# I/O: sourced by every *-test.sh > vars app tmpz logz wins slpz, fns chk fini
# Run: source ~/zz-base-home/as-apps/os-syst/ss-star-shut/te-base-fixt.sh
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tmpz=$(mktemp -d); slpz=""; hubz=""; pass=0; fail=0
trap 'kill $slpz $hubz 2>/dev/null; mv "$tmpz" "$tmpz.done" 2>/dev/null' EXIT
ok() { echo "PASS  $1"; pass=$((pass + 1)); }
bad() { echo "FAIL  $1"; fail=$((fail + 1)); }
chk() { local name=$1; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }
fini() { echo; echo "$pass passed, $fail failed"; test "$fail" -eq 0; }
fix_make() { local cmd; export HOME="$tmpz/home" XDG_CONFIG_HOME="$tmpz/home/.config" XDG_SESSION_TYPE=x11; app="$tmpz/app"; mkdir -p "$HOME/Downloads" "$HOME/work" "$tmpz/bin" "$app" "$tmpz/chrome/launcher-p3/Profile 3" "$tmpz/chrome/launcher-p2"; logz="$tmpz/calls.log"; wins="$tmpz/wins.txt"; : > "$logz"; sleep 300 & slpz=$!; printf '%s\n' "0x01 0 $slpz host editor" "0x02 0 $$ host mine" "0x03 -1 99 host panel" > "$wins"; for cmd in nemo google-chrome code systemctl cmd-run; do printf '#!/usr/bin/env bash\necho "%s $*" >> "%s"\n' "$cmd" "$logz" > "$tmpz/bin/$cmd"; done; printf 'sleep 8\n' >> "$tmpz/bin/google-chrome"; printf '#!/usr/bin/env bash\nexit 1\n' > "$tmpz/bin/pgrep"; printf '#!/usr/bin/env bash\n[[ -e "%s/nox" ]] && exit 1\ncase "$1" in\n  -lp) cat "%s" ;;\n  -l)  awk \x27{print $1, $2, $4, $5}\x27 "%s" ;;\n  -ic) echo "wmctrl -ic $2" >> "%s"; [[ $2 == 0x02 ]] && sed -i "/^0x02 /d" "%s" ;;\nesac\n' "$tmpz" "$wins" "$wins" "$logz" "$wins" > "$tmpz/bin/wmctrl"; printf '#!/usr/bin/env bash\necho "sync $* @$PWD" >> "%s"\n' "$logz" > "$tmpz/bin/git-sync-safe-guard"; chmod +x "$tmpz/bin/"*; export PATH="$tmpz/bin:$PATH"; printf '%s\n' "WORK_PATH=$HOME/work" "DOWN_PATH=$HOME/Downloads" "CHRO_DATA=$tmpz/chrome" "CHRO_PROF=p3,p2,p99" "SYNC_CMDZ=$tmpz/bin/git-sync-safe-guard wipz --live" "CMDR_BINA=$tmpz/bin/cmd-run" "CMDR_PORT=39030" "COUN_SECO=1" "WAIT_SECO=1" "OPEN_GAPS=0" > "$app/aa-conf-main.env"; cp "$dirz"/*.sh "$app/"; }
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
