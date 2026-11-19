# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Open the work setup at login (Linux)
# Flo: load config > folders > cmd-run > AI servers > Chrome profiles > cmd-run tab > VSCode
# I/O: [--dry-run] [--verbose] [status] + aa-conf-main.env > apps launched; missing app = WARN, run goes on
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-star-linu.sh
# ===================================================================
set -u
declare -A CF_OPEN=([paus]=1)
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$dirz/cf-conf-load.sh"
source "$dirz/ui-prin-mesg.sh"
dryz=0; vrbz=0; modz=run
for arg in "$@"; do case $arg in --dry-run) dryz=1 ;; --verbose) vrbz=1 ;; status) modz=status ;; *) echo "Use: $0 [--dry-run] [--verbose] [status]" >&2; exit 2 ;; esac; done
conf_load || exit 1
have() { command -v "$1" >/dev/null 2>&1; }
if [[ $modz == status ]]; then conf_show; for app in "$FILE_MANA" "$CHRO_BINA" "$CODE_BINA"; do have "$app" && echo "  found   : $app" || echo "  MISSING : $app"; done; exit 0; fi
launch() { detail "open: $*"; ((dryz)) && return 0; setsid nohup "$@" >/dev/null 2>&1 & }
chrome_win() { local id=$1 cls; shift; [[ $id =~ ^p[0-9]+$ ]] && cls=profile${id#p} || cls=$id; launch "$CHRO_BINA" --user-data-dir="$CHRO_DATA/launcher-$id" --class="$cls" "$@"; }
port_up() { (exec 3<>"/dev/tcp/127.0.0.1/${1:-$CMDR_PORT}") 2>/dev/null; }
gap() { ((dryz)) || sleep "$OPEN_GAPS"; }
open_fold() { local dir; if have "$FILE_MANA"; then for dir in "$WORK_PATH" ${CLOU_PATH:+"$CLOU_PATH"} "$DOWN_PATH"; do if [[ -d $dir ]]; then launch "$FILE_MANA" "$dir"; ((dryz)) || sleep "${CF_OPEN[paus]}"; else echo "    WARN folder missing: $dir"; fi; done; else echo "    WARN file manager not found: $FILE_MANA"; fi; }
open_cmdr() { [[ -n $CMDR_BINA ]] || return 0; if [[ ! -x $CMDR_BINA ]]; then echo "    WARN cmd-run not found: $CMDR_BINA"; elif port_up; then detail "cmd-run already up on :$CMDR_PORT"; else launch "$CMDR_BINA" "$CMDR_PORT"; ((dryz)) || sleep "$OPEN_GAPS"; fi; }
open_aisv() { [[ -n $AISV_WDOG ]] || return 0; if [[ ! -r $AISV_WDOG ]]; then echo "    WARN AI server watchdog not found: $AISV_WDOG"; elif port_up "$AISV_PORT"; then detail "AI server already up on :$AISV_PORT"; else launch bash "$AISV_WDOG"; fi; if [[ -n $AISV_VENV && -r $AISV_VENV ]]; then if port_up "$AISV_VPORT"; then detail "AI vision server already up on :$AISV_VPORT"; else launch bash "$AISV_WDOG" "$AISV_VENV"; fi; fi; }
open_chro() { local profs prof tabz=""; if have "$CHRO_BINA"; then IFS=',' read -ra profs <<< "$CHRO_PROF"; for prof in "${profs[@]}"; do [[ -z $prof ]] && continue; if [[ -d $CHRO_DATA/launcher-$prof ]]; then if [[ -z $tabz && $CMDR_DBGP != 0 ]]; then chrome_win "$prof" --start-maximized --remote-debugging-port="$CMDR_DBGP" --remote-debugging-address=127.0.0.1; else chrome_win "$prof" --start-maximized; fi; gap; [[ -z $tabz ]] && tabz=$prof; else echo "    WARN Chrome launcher missing: $prof"; fi; done; if [[ -n $CMDR_BINA && -n $tabz ]]; then chrome_win "$tabz" "http://127.0.0.1:$CMDR_PORT"; fi; else echo "    WARN Chrome not found: $CHRO_BINA"; fi; }
open_code() { local dir; if have "$CODE_BINA"; then for dir in "$WORK_PATH" ${CLOU_PATH:+"$CLOU_PATH"}; do if [[ -d $dir ]]; then launch "$CODE_BINA" "$dir"; ((dryz)) || sleep "${CF_OPEN[paus]}"; else echo "    WARN folder missing: $dir"; fi; done; else echo "    WARN VSCode not found: $CODE_BINA"; fi; }
banner "Opening your work setup$( ((dryz)) && echo ' (dry-run)') -- please wait"
open_fold; open_cmdr; open_aisv; open_chro; open_code
banner "Done --> all apps opened"
exit 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
