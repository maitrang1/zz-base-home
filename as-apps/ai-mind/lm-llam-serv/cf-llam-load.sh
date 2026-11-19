# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Load and check the AI server settings (text and vision)
# Flo: defaults > aa-conf-main.env > env overrides > expand ~ > pick role > check numbers > find llama-server
# I/O: [role: main or visi] (env AISV_CONF = other file) > globals AISV_*, or exit 1 with a clear message
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/cf-llam-load.sh --check [visi]
# ===================================================================
declare -gA CF_LLAM=([sufz]="BINA MODL MMPJ HOST PORT SLOT CTXN THRD XTRA EVRY BOOT LOGF" [pathz]="BINA MODL MMPJ LOGF" [numz]="PORT SLOT CTXN THRD EVRY BOOT")
llam_dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
llam_keyz() { local suf pre; for pre in AISV VISI; do for suf in ${CF_LLAM[sufz]}; do printf '%s_%s ' "$pre" "$suf"; done; done; }
llam_defa() { AISV_BINA=""; AISV_MODL=""; AISV_MMPJ=""; AISV_HOST=127.0.0.1; AISV_PORT=4004; AISV_SLOT=1; AISV_CTXN=4096; AISV_THRD=4; AISV_XTRA=""; AISV_EVRY=15; AISV_BOOT=5; AISV_LOGF=/dev/null; local suf; for suf in ${CF_LLAM[sufz]}; do printf -v "VISI_$suf" '%s' ""; done; }
llam_read() { local line num=0 key val; while IFS= read -r line || [[ -n $line ]]; do num=$((num + 1)); line=${line%$'\r'}; [[ -z ${line//[[:space:]]/} || $line =~ ^[[:space:]]*# ]] && continue; [[ $line =~ ^([A-Z_]+)=(.*)$ ]] || { echo "config ${1##*/} line $num: bad syntax" >&2; return 1; }; key=${BASH_REMATCH[1]}; val=${BASH_REMATCH[2]}; [[ " $(llam_keyz)" == *" $key "* ]] || { echo "config ${1##*/} line $num: unknown key $key" >&2; return 1; }; val=${val#\"}; val=${val%\"}; printf -v "$key" '%s' "$val"; done < "$1"; }
llam_expa() { local suf pre key val; for pre in AISV VISI; do for suf in ${CF_LLAM[pathz]}; do key=${pre}_$suf; val=${!key}; val=${val/#\~/$HOME}; val=${val//\$\{HOME\}/$HOME}; printf -v "$key" '%s' "$val"; done; done; }
llam_pick() { local suf vis; [[ $1 == visi ]] || return 0; for suf in ${CF_LLAM[sufz]}; do vis=VISI_$suf; [[ -n ${!vis} ]] && printf -v "AISV_$suf" '%s' "${!vis}"; done; return 0; }
llam_chek() { local suf pre key; for pre in AISV VISI; do for suf in ${CF_LLAM[numz]}; do key=${pre}_$suf; [[ -z ${!key} && $pre == VISI ]] && continue; [[ ${!key} =~ ^(0|[1-9][0-9]*)$ ]] || { echo "config: $key must be a whole number without leading zeros, got '${!key}'" >&2; return 1; }; done; done; ((AISV_PORT >= 1 && AISV_PORT <= 65535)) || { echo "config: AISV_PORT must be 1..65535, got '$AISV_PORT'" >&2; return 1; }; }
llam_load() { local role=${1:-main} file=${AISV_CONF:-$llam_dirz/aa-conf-main.env} key; local -A envv=(); [[ $role == main || $role == visi ]] || { echo "config: unknown role '$role' (use main or visi)" >&2; return 1; }; [[ -f $file ]] || file="$llam_dirz/$file"; [[ -r $file ]] || { echo "config: cannot read $file" >&2; return 1; }; for key in $(llam_keyz); do [[ -v $key ]] && envv[$key]=${!key}; done; llam_defa; llam_read "$file" || return 1; for key in "${!envv[@]}"; do printf -v "$key" '%s' "${envv[$key]}"; done; llam_expa; llam_chek || return 1; if [[ $role == visi && -z $VISI_PORT ]]; then echo "config: role visi needs VISI_PORT" >&2; return 1; fi; llam_pick "$role"; [[ -x $AISV_BINA ]] || AISV_BINA=$(command -v llama-server 2>/dev/null || true); return 0; }
llam_show() { local suf key; for suf in ${CF_LLAM[sufz]}; do key=AISV_$suf; printf '  %s = %s\n' "$key" "${!key}"; done; }
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then case "${1:-}" in --check|status) llam_load "${2:-}" || exit 1; echo "config OK (role ${2:-main})"; llam_show; exit 0 ;; *) echo "Use: $0 --check [main|visi]" >&2; exit 2 ;; esac; fi
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
