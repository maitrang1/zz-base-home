# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Stop the AI server watchdog, then its llama-server
# Flo: load settings > stop the watchdog from its lock > TERM only a llama-server on the port
# I/O: [role: main or visi] > watchdog and llama-server stopped; any other port owner is left running with a note
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-stop.sh [visi]
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$dirz/cf-llam-load.sh"
llam_load "${1:-}" || exit 1
lock="${TMPDIR:-/tmp}/aisv-watchdog-$AISV_PORT.lock"
if [[ -f $lock ]]; then wid=$(cat "$lock" 2>/dev/null); if [[ $wid =~ ^[0-9]+$ ]] && tr '\0' ' ' < "/proc/$wid/cmdline" 2>/dev/null | grep -q -E 'ru-llam-watc|ai-lin-watchdog'; then kill "$wid" 2>/dev/null; else echo "lock $lock names pid '$wid', not a watchdog - left running" >&2; fi; rm -f "$lock"; fi
for pid in $(ss -lptnH "sport = :$AISV_PORT" 2>/dev/null | sed -n 's/.*pid=\([0-9]*\).*/\1/p' | sort -u); do case "$(ps -o comm= -p "$pid" 2>/dev/null)" in *llama-server*) kill -TERM "$pid" 2>/dev/null; sleep 1; kill -0 "$pid" 2>/dev/null && echo "WARN llama-server $pid still up after TERM (no KILL is sent)" >&2 ;; *) echo "port $AISV_PORT is used by '$(ps -o comm= -p "$pid")' (pid $pid) - left running" >&2 ;; esac; done
exit 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
