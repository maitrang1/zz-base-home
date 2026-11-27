# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Sync tool exes, skill links, and flag help drift.
# Flo: read map > copy newer exes > link new skills > unlink dead links > hash help > flag drift
# I/O: so-skil-tool.json + repo dist exes (disk) > bin dir, ~/.claude/skills links, help hashes (disk); exit 0 ok, 3 drift, 2 usage
# Run: bash ~/zz-base-home/as-apps/ai-mind/sk-skil-tool/sh-bins-inst.sh [--dry] [--ack]
# ===================================================================
set -u
CF_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); CF_REPO=${ZZ_REPO:-$(cd "$CF_HERE/../../.." && pwd)}; CF_SRC=$CF_REPO/as-apps/ai-mind/sk-skil-tool; CF_DIST=${ZZ_DIST:-linux-x86_64}; CF_BIN=${ZZ_BIN:-$HOME/.zz-base-home-bin}; CF_SKL=${ZZ_SKL:-$HOME/.claude/skills}; CF_STATE=${ZZ_STATE:-$HOME/.zz-base-home-tena/as-apps/ai-mind/sk-skil-tool}; CF_MAP=$CF_SRC/so-skil-tool.json; CF_TMO=10
dry=0; ack=0
for a in "$@"; do case $a in --dry) dry=1 ;; --ack) ack=1 ;; *) echo "sh-bins-inst.sh: bad flag: $a" >&2; exit 2 ;; esac; done
hsh() { sha256sum "$1" | cut -d' ' -f1; }
helphash() { local out; out=$(timeout "$CF_TMO" "$1" "$2" 2>&1 </dev/null); [[ $? -ne 124 ]] || return 1; printf %s "$out" | tr -d '\r' | sha256sum | cut -d' ' -f1; }
c_copied=0; c_linked=0; c_unlinked=0; c_busy=0; c_miss=0; c_drift=0
declare -A skl dir old new
while IFS='"' read -r _ t _ v _; do [[ -n ${v-} ]] && { skl[$t]=${v%%|*}; dir[$t]=${v#*|}; }; done < "$CF_MAP"
[[ $dry -eq 1 ]] || mkdir -p "$CF_BIN" "$CF_SKL"
for t in "${!skl[@]}"; do s=$CF_REPO/${dir[$t]}/zig-out/dist/$CF_DIST/$t; d=$CF_BIN/$t; [[ -f $s ]] || { echo "miss $t"; c_miss=$((c_miss+1)); continue; }; if [[ -f $d ]] && { [[ ! $s -nt $d ]] || [[ $(hsh "$s") == $(hsh "$d") ]]; }; then continue; fi; [[ $dry -eq 0 ]] || { echo "would copy $t"; continue; }; if cp -p "$s" "$d.new" && mv -f "$d.new" "$d"; then echo "copied $t"; c_copied=$((c_copied+1)); else rm -f "$d.new"; echo "busy $t"; c_busy=$((c_busy+1)); fi; done
for f in "$CF_SRC"/*/; do f=${f%/}; n=$(basename "$f"); l=$CF_SKL/$n; if [[ -L $l ]]; then [[ $(readlink "$l") == "$f" ]] || echo "clash $n"; continue; fi; [[ ! -e $l ]] || { echo "clash $n"; continue; }; [[ $dry -eq 0 ]] || { echo "would link $n"; continue; }; ln -s "$f" "$l"; echo "linked $n"; c_linked=$((c_linked+1)); done
for l in "$CF_SKL"/*; do [[ -L $l ]] || continue; g=$(readlink "$l"); [[ $g == "$CF_SRC"/* && ! -e $g ]] || continue; [[ $dry -eq 0 ]] || { echo "would unlink $(basename "$l")"; continue; }; unlink "$l"; echo "unlinked $(basename "$l")"; c_unlinked=$((c_unlinked+1)); done
sf=$CF_STATE/so-help-hash.txt
[[ ! -f $sf ]] || while IFS='=' read -r k v; do [[ -z $k ]] || old[$k]=$v; done < "$sf"
for t in "${!skl[@]}"; do d=$CF_BIN/$t; [[ -x $d ]] || continue; a=--help; [[ $t != za ]] || a=help; h=$(helphash "$d" "$a") || continue; new[$t]=$h; if [[ -n ${old[$t]-} && ${old[$t]} != "$h" && $ack -eq 0 ]]; then echo "drift ${skl[$t]}"; c_drift=$((c_drift+1)); new[$t]=${old[$t]}; fi; done
for k in "${!old[@]}"; do [[ -n ${new[$k]-} ]] || new[$k]=${old[$k]}; done
if [[ $dry -eq 0 ]]; then mkdir -p "$CF_STATE"; for k in "${!new[@]}"; do echo "$k=${new[$k]}"; done | sort > "$sf.tmp" && mv -f "$sf.tmp" "$sf"; fi
echo "done copied=$c_copied linked=$c_linked unlinked=$c_unlinked busy=$c_busy miss=$c_miss drift=$c_drift"
[[ $c_drift -eq 0 ]] || exit 3
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============