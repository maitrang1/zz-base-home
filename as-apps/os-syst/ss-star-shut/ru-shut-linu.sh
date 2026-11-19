# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Save work, close apps politely, power off
# Flo: preflight > countdown > save work > tr tab > VSCode > other windows > SIGTERM > Chrome flags > countdown > power off
# I/O: [--dry-run] [--auto] [--verbose] [status] + aa-conf-main.env > apps closed, PC off (any key cancels)
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-linu.sh
# ===================================================================
set -u
declare -A CF_SHUT=([cool]=3 [sigz]=2)
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$dirz/cf-conf-load.sh"
source "$dirz/ui-prin-mesg.sh"
dryz=0; autz=0; vrbz=0; modz=run
for arg in "$@"; do case $arg in --dry-run) dryz=1 ;; --auto) autz=1 ;; --verbose) vrbz=1 ;; status) modz=status ;; *) echo "Use: $0 [--dry-run] [--auto] [--verbose] [status]" >&2; exit 2 ;; esac; done
conf_load || exit 1
have() { command -v "$1" >/dev/null 2>&1; }
if [[ $modz == status ]]; then conf_show; have wmctrl && echo "  found   : wmctrl" || echo "  MISSING : wmctrl (sudo apt install wmctrl)"; have "${SYNC_CMDZ%% *}" && echo "  found   : ${SYNC_CMDZ%% *}" || echo "  MISSING : ${SYNC_CMDZ%% *} (save step skipped)"; exit 0; fi
anc_make() { local pidz=$$; ancs=" "; while [[ $pidz -gt 1 ]]; do ancs+="$pidz "; pidz=$(sed 's/.*) //' "/proc/$pidz/stat" 2>/dev/null | cut -d' ' -f2); [[ $pidz =~ ^[0-9]+$ ]] || break; done; }
skip_proc() { [[ ",$SKIP_LIST," == *",$1,"* ]]; }
proc_name() { cat "/proc/$1/comm" 2>/dev/null; }
win_list() { local id desk pid rest name; wmctrl -lp 2>/dev/null | while read -r id desk pid rest; do [[ $desk == -1 || $pid == 0 ]] && continue; [[ $ancs == *" $pid "* ]] && continue; name=$(proc_name "$pid"); skip_proc "$name" && continue; echo "$id $pid"; done; }
win_gone() { ! wmctrl -l 2>/dev/null | grep -q "^$1 "; }
countdown() { local i; ((autz || dryz)) && return 0; [[ -t 0 ]] || { echo "No terminal for the cancel key. Use --auto for unattended runs." >&2; exit 2; }; banner "$1"; echo "    $2"; echo; for ((i = COUN_SECO; i >= 0; i--)); do bar "$i" "$COUN_SECO"; if read -rs -n1 -t1; then echo; banner "Key Pressed --> SHUT-DOWN CANCELLED"; sleep "${CF_SHUT[cool]}"; return 1; fi; done; echo; }
close_windows() { local filt="${1:-}" id pid name left t i; local -a ids=() pids=(); local -A termd=(); while read -r id pid; do [[ -z $id ]] && continue; name=$(proc_name "$pid"); [[ -n $filt && $name != "$filt" ]] && continue; ids+=("$id"); pids+=("$pid"); detail "close: $id ($name, pid $pid)"; ((dryz)) || wmctrl -ic "$id"; done < <(win_list); ((dryz || ${#ids[@]} == 0)) && return 0; for ((t = 0; t < WAIT_SECO; t++)); do left=0; for id in "${ids[@]}"; do win_gone "$id" || left=1; done; ((left)) || return 0; sleep 1; done; for i in "${!ids[@]}"; do pid=${pids[i]}; win_gone "${ids[i]}" && continue; [[ -n ${termd[$pid]:-} || $ancs == *" $pid "* ]] && continue; kill -0 "$pid" 2>/dev/null || continue; termd[$pid]=1; detail "SIGTERM: pid $pid ($(proc_name "$pid"))"; kill -TERM "$pid" 2>/dev/null; done; sleep "${CF_SHUT[sigz]}"; for id in "${ids[@]}"; do win_gone "$id" || echo "    WARN still open: $id (unsaved work?)"; done; }
close_cmdr_tab() { local ids id; [[ $CMDR_DBGP != 0 ]] && have curl || { detail "skip (debug port off or curl missing)"; return 0; }; ids=$(curl -fs -m 3 "http://127.0.0.1:$CMDR_DBGP/json/list" 2>/dev/null | awk -v p="http://127.0.0.1:$CMDR_PORT" '/"id":/ {split($0, a, "\""); i=a[4]} /"url":/ && index($0, "\"" p) {print i}'); [[ -n $ids ]] || { detail "no tr tab found"; return 0; }; for id in $ids; do detail "close tab: $id"; ((dryz)) || curl -fs -m 3 "http://127.0.0.1:$CMDR_DBGP/json/close/$id" >/dev/null 2>&1; done; ((dryz)) || sleep 1; }
fix_chrome() { local f t; if ! ((dryz)) && have pgrep; then for ((t = 0; t < WAIT_SECO; t++)); do pgrep -x chrome >/dev/null || break; sleep 1; done; pgrep -x chrome >/dev/null && { echo "    WARN Chrome still running, flags not fixed"; return 0; }; fi; for f in "$CHRO_DATA"/launcher-*/"Local State" "$CHRO_DATA"/launcher-*/Default/Preferences "$CHRO_DATA"/launcher-*/Profile\ */Preferences; do [[ -f $f ]] || continue; detail "fix: $f"; ((dryz)) || sed -i 's/"exited_cleanly":false/"exited_cleanly":true/g; s/"exit_type":"Crashed"/"exit_type":"Normal"/g' "$f"; done; }
sync_work() { banner "Saving $WORK_PATH (wo wipz) before EXIT"; if [[ -n $SYNC_CMDZ ]] && have "${SYNC_CMDZ%% *}" && [[ -d $WORK_PATH ]]; then detail "run: $SYNC_CMDZ (in $WORK_PATH)"; if ((dryz)); then :; elif (cd "$WORK_PATH" && $SYNC_CMDZ); then echo "    work saved."; else echo "    save STOPPED (see above)"; fi; else echo "    WARN save skipped (tool or folder missing)"; fi; }
pre_flig() { read -ra pcmd <<< "$POWE_CMDZ"; [[ ${XDG_SESSION_TYPE:-x11} != wayland ]] || { echo "Wayland session: wmctrl cannot see all windows. Log into X11." >&2; exit 1; }; have wmctrl || { echo "wmctrl missing: sudo apt install wmctrl" >&2; exit 1; }; wmctrl -l >/dev/null 2>&1 || { echo "wmctrl cannot reach the X display (DISPLAY unset or no X session): nothing would be closed" >&2; exit 1; }; have "${pcmd[0]}" || { echo "power-off command not found: ${pcmd[0]}" >&2; exit 1; }; }
anc_make
if ((autz || dryz)); then banner "Close all Apps --> SHUT-DOWN the PC$( ((dryz)) && echo ' (dry-run)')"; fi
pre_flig
countdown "Close all Apps --> SHUT-DOWN the PC" "Starting in ${COUN_SECO}s -- Press any key to CANCEL" || exit 0
sync_work
((autz || dryz)) || sleep 2
echo; echo "    closing apps... please... wait a moment."; echo
detail "-- tr tab"; close_cmdr_tab
detail "-- VSCode"; close_windows "$(basename "$CODE_BINA")"
detail "-- other windows"; close_windows
detail "-- Chrome exit flags"; fix_chrome
countdown "Apps Closed --> Shutting Down in ${COUN_SECO}s" "Press any key to CANCEL now" || exit 0
((dryz)) && exit 0
banner "Countdown Done ----> SHUT-DOWN NOW!"
((autz)) || sleep "${CF_SHUT[cool]}"
exec "${pcmd[@]}"
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
