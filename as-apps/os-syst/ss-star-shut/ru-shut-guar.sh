# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Night helper: power off once no hub job runs
# Flo: tick > arm (first minutes of arm hour) or check > flag stale or hub down = skip > forced hour or idle = shut down
# I/O: tick|arm|check|disarm|status|later <min> + env GUARD_NOW GUARD_POLL GUARD_DRY > flag file GUAR_FLAG, visible terminal runs ru-shut-linu.sh
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-guar.sh check
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$dirz/cf-conf-load.sh"
conf_load || exit 1
nowz=${GUARD_NOW:-$(date +%s)}
stmp() { date -d "@$1" '+%F %T'; }
force_at() { local day t; day=$(date -d "@$1" +%F); t=$(date -d "$day $(printf '%02d' "$GUAR_FORC"):00" +%s); ((t > $1)) || t=$(date -d "$day +1 day $(printf '%02d' "$GUAR_FORC"):00" +%s); echo "$t"; }
busy_ids() { local body q id cf nxt out=""; body=$(curl -fs -m 5 "http://127.0.0.1:$GUAR_HUBP/tasks") || return 1; q=${body#*\"queue\":\{}; q=${q%%]\}*}; while read -r id; do [[ -z $id || ",$GUAR_SELF," == *",$id,"* ]] && continue; out+="$id "; done < <(grep -o '"id":"[^"]*"' <<< "$q" | cut -d'"' -f4); for cf in "$GUAR_STAT"/*.chain; do [[ -r $cf ]] || continue; read -r _ _ _ nxt _ < "$cf"; [[ $nxt =~ ^[0-9]+$ ]] || continue; ((nxt / 1000 + 300 > nowz)) && out+="$(basename "$cf" .chain) "; done; echo "${out% }"; }
recent_mark() { local m t; for m in "$GUAR_FLAG.off" "$GUAR_FLAG.done"; do [[ -r $m ]] || continue; t=$(<"$m"); [[ $t =~ ^[0-9]+$ ]] || continue; ((nowz - t < 43200)) && return 0; done; return 1; }
shut_down() { echo "shutdown: $1"; mv "$GUAR_FLAG" "$GUAR_FLAG.done" 2>/dev/null; export DISPLAY=${DISPLAY:-:0} XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}; setsid nohup $GUAR_TERM bash "$dirz/ru-shut-linu.sh" >/dev/null 2>&1 & }
g_tick() { local hmz hhz armh; armh=$(printf '%02d' "$GUAR_ARMH"); hmz=$(date -d "@$nowz" +%H%M); hhz=${hmz:0:2}; if [[ $hmz =~ ^${armh}(0[0-9]|1[0-4])$ ]]; then cmd=arm; elif [[ $hhz == "$armh" && ! -r $GUAR_FLAG ]] && ! recent_mark; then cmd=arm; else cmd=check; fi; }
g_arm() { mkdir -p "$(dirname "$GUAR_FLAG")" && echo "$nowz" > "$GUAR_FLAG"; echo "armed at $(stmp "$nowz"), forced off at $(stmp "$(force_at "$nowz")")"; }
g_disarm() { mv "$GUAR_FLAG" "$GUAR_FLAG.off" 2>/dev/null && echo "disarmed" || echo "was not armed"; }
g_stat() { local armz; if [[ -r $GUAR_FLAG ]]; then armz=$(<"$GUAR_FLAG"); echo "armed at $(stmp "$armz"), forced off at $(stmp "$(force_at "$armz")")"; else echo "not armed"; fi; }
g_chek() { local armz forz busy; [[ -r $GUAR_FLAG ]] || { echo "skip: not armed"; exit 0; }; armz=$(<"$GUAR_FLAG"); [[ $armz =~ ^[0-9]+$ ]] || { echo "skip: bad flag file"; exit 0; }; forz=$(force_at "$armz"); if ((nowz > forz + GUAR_STAL * 3600)); then mv "$GUAR_FLAG" "$GUAR_FLAG.off"; echo "skip: arm is stale, disarmed"; exit 0; fi; busy=$(busy_ids) || { echo "skip: hub not answering on :$GUAR_HUBP"; exit 0; }; if ((nowz >= forz)); then shut_down "forced hour ${GUAR_FORC}h reached (busy: ${busy:-none})"; elif [[ -z $busy ]]; then shut_down "all jobs idle"; else echo "wait: busy: $busy (forced off at $(stmp "$forz"))"; fi; }
g_late() { local minz=${1:-} busy; [[ $minz =~ ^[0-9]+$ ]] || { echo "Use: $0 later <minutes>" >&2; exit 2; }; echo "$(date +%T) wait ${minz} min, then until the hub is idle"; ((minz > 0)) && sleep $((minz * 60)); while :; do [[ -n ${GUARD_NOW:-} ]] || nowz=$(date +%s); if ! busy=$(busy_ids); then echo "$(date +%T) hub not answering on :$GUAR_HUBP: nothing to wait for"; break; fi; [[ -z $busy ]] && { echo "$(date +%T) hub idle"; break; }; echo "$(date +%T) wait: busy: $busy"; sleep "${GUARD_POLL:-60}"; done; if [[ -n ${GUARD_DRY:-} ]]; then echo "dry: would run ru-shut-linu.sh$( ((minz > 0)) && echo ' --auto')"; exit 0; fi; if ((minz > 0)); then exec bash "$dirz/ru-shut-linu.sh" --auto; else exec bash "$dirz/ru-shut-linu.sh"; fi; }
cmd=${1:-}
[[ $cmd == tick ]] && g_tick
case "$cmd" in arm) g_arm ;; disarm) g_disarm ;; status) g_stat ;; check) g_chek ;; later) g_late "${2:-}" ;; *) echo "Use: $0 tick|arm|check|disarm|status|later <min>" >&2; exit 2 ;; esac
exit 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
