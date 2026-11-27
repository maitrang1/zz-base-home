# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Sync tool exes, skill links, and flag help drift.
# Flo: read map > copy newer exes > add PATH > link new skills > unlink dead links > hash help > flag drift
# I/O: so-skil-tool.json + repo dist exes (disk) > bin dir, ~/.profile, ~/.claude/skills links, help hashes (disk); exit 0 ok, 3 drift, 2 usage
# Run: bash ~/zz-base-home/as-apps/ai-mind/sk-skil-tool/sh-bins-inst.sh [--dry] [--ack]
# ===================================================================
set -u
CF_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); CF_REPO=${SKIL_REPO:-$(cd "$CF_HERE/../../.." && pwd)}; CF_SRCZ=$CF_REPO/as-apps/ai-mind/sk-skil-tool; CF_DIST=${SKIL_DIST:-linux-x86_64}; CF_BINZ=${SKIL_BINZ:-$HOME/.zz-base-home-bin}; CF_LINK=${SKIL_LINK:-$HOME/.claude/skills}; CF_STAT=${SKIL_STAT:-$HOME/.zz-base-home-tena/as-apps/ai-mind/sk-skil-tool}; CF_MAPZ=$CF_SRCZ/so-skil-tool.json; CF_TIME=10
dryz=0; ackz=0
for argz in "$@"; do case $argz in --dry) dryz=1 ;; --ack) ackz=1 ;; *) echo "sh-bins-inst.sh: bad flag: $argz" >&2; exit 2 ;; esac; done
hash_file() { sha256sum "$1" | cut -d' ' -f1; }
help_hash() { local outz; outz=$(timeout "$CF_TIME" "$1" "$2" 2>&1 </dev/null); [[ $? -ne 124 ]] || return 1; printf %s "$outz" | tr -d '\r' | sha256sum | cut -d' ' -f1; }
cntz_copy=0; cntz_link=0; cntz_dead=0; cntz_busy=0; cntz_miss=0; cntz_drif=0
declare -A skil fold oldz newz; tool_list=()
while IFS='"' read -r _ tool _ valu _; do [[ -n ${valu-} ]] && { tool_list+=("$tool"); skil[$tool]=${valu%%|*}; fold[$tool]=${valu#*|}; }; done < "$CF_MAPZ"
[[ $dryz -eq 1 ]] || mkdir -p "$CF_BINZ" "$CF_LINK"
for tool in "${tool_list[@]}"; do srcz=$CF_REPO/${fold[$tool]}/zig-out/dist/$CF_DIST/$tool; dstz=$CF_BINZ/$tool; [[ -f $srcz ]] || { echo "miss $tool"; cntz_miss=$((cntz_miss+1)); continue; }; if [[ -f $dstz ]] && { [[ ! $srcz -nt $dstz ]] || [[ $(hash_file "$srcz") == $(hash_file "$dstz") ]]; }; then continue; fi; [[ $dryz -eq 0 ]] || { echo "would copy $tool"; continue; }; if cp -p "$srcz" "$dstz.new" && mv -f "$dstz.new" "$dstz"; then echo "copied $tool"; cntz_copy=$((cntz_copy+1)); else rm -f "$dstz.new"; echo "busy $tool"; cntz_busy=$((cntz_busy+1)); fi; done
[[ -n ${SKIL_BINZ-} || $dryz -eq 1 ]] || grep -qsF "$CF_BINZ" "$HOME/.profile" || { echo "export PATH=\"\$PATH:$CF_BINZ\"" >> "$HOME/.profile"; echo "pathed (re-login)"; }
for fldr in "$CF_SRCZ"/*/; do fldr=${fldr%/}; name=$(basename "$fldr"); link=$CF_LINK/$name; if [[ -L $link ]]; then [[ $(readlink "$link") == "$fldr" ]] || echo "clash $name"; continue; fi; [[ ! -e $link ]] || { echo "clash $name"; continue; }; [[ $dryz -eq 0 ]] || { echo "would link $name"; continue; }; ln -s "$fldr" "$link"; echo "linked $name"; cntz_link=$((cntz_link+1)); done
for link in "$CF_LINK"/*; do [[ -L $link ]] || continue; targ=$(readlink "$link"); [[ $targ == "$CF_SRCZ"/* && ! -e $targ ]] || continue; [[ $dryz -eq 0 ]] || { echo "would unlink $(basename "$link")"; continue; }; unlink "$link"; echo "unlinked $(basename "$link")"; cntz_dead=$((cntz_dead+1)); done
file=$CF_STAT/so-help-hash.txt
[[ ! -f $file ]] || while IFS='=' read -r keyz valu; do [[ -z $keyz ]] || oldz[$keyz]=$valu; done < "$file"
for tool in "${tool_list[@]}"; do dstz=$CF_BINZ/$tool; [[ -x $dstz ]] || continue; argz=--help; [[ $tool != za ]] || argz=help; hash=$(help_hash "$dstz" "$argz") || continue; newz[$tool]=$hash; if [[ -n ${oldz[$tool]-} && ${oldz[$tool]} != "$hash" && $ackz -eq 0 ]]; then echo "drift ${skil[$tool]}"; cntz_drif=$((cntz_drif+1)); newz[$tool]=${oldz[$tool]}; fi; done
for keyz in "${!oldz[@]}"; do [[ -n ${newz[$keyz]-} ]] || newz[$keyz]=${oldz[$keyz]}; done
if [[ $dryz -eq 0 ]]; then mkdir -p "$CF_STAT"; for keyz in "${!newz[@]}"; do echo "$keyz=${newz[$keyz]}"; done | sort > "$file.tmp" && mv -f "$file.tmp" "$file"; fi
echo "done copied=$cntz_copy linked=$cntz_link unlinked=$cntz_dead busy=$cntz_busy miss=$cntz_miss drift=$cntz_drif"
[[ $cntz_drif -eq 0 ]] || exit 3
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============