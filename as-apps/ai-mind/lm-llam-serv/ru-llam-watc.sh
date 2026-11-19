# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Keep the local AI server (llama-server) listening all session
# Flo: load settings for the role > take the lock > check files > loop: port down > start detached > wait
# I/O: [role: main or visi] (settings aa-conf-main.env) > llama-server running on its port, log in its log file; exit 1 on a missing file
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-watc.sh [visi]
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$dirz/cf-llam-load.sh"
llam_load "${1:-}" || exit 1
lock="${TMPDIR:-/tmp}/aisv-watchdog-$AISV_PORT.lock"
if [[ -f $lock ]] && kill -0 "$(cat "$lock" 2>/dev/null)" 2>/dev/null; then exit 0; fi
echo $$ > "$lock"; trap 'rm -f "$lock"' EXIT
[[ -n $AISV_MODL ]] || { echo "ai server: AISV_MODL is not set" >&2; exit 1; }
for f in "$AISV_BINA" "$AISV_MODL" ${AISV_MMPJ:+"$AISV_MMPJ"}; do [[ -n $f && -e $f ]] || { echo "ai server: missing ${f:-llama-server}" >&2; exit 1; }; done
port_up() { ss -lntH "sport = :$AISV_PORT" 2>/dev/null | grep -q LISTEN && return 0; lsof -ti:"$AISV_PORT" >/dev/null 2>&1; }
start_one() { ( cd "$(dirname "$AISV_BINA")" && LD_LIBRARY_PATH="$PWD${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" setsid nohup "$AISV_BINA" -m "$AISV_MODL" --host "$AISV_HOST" --port "$AISV_PORT" -np "$AISV_SLOT" -c "$AISV_CTXN" -t "$AISV_THRD" ${AISV_MMPJ:+--mmproj "$AISV_MMPJ"} $AISV_XTRA >> "$AISV_LOGF" 2>&1 & ); }
while :; do if ! port_up; then [[ -x $AISV_BINA && -e $AISV_MODL ]] || { echo "ai server: binary or model is gone - watchdog stopping" >&2; exit 1; }; start_one; sleep "$AISV_BOOT"; fi; sleep "$AISV_EVRY"; done
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
