# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Test sh-bins-inst.sh on a scratch dir, never real paths.
# Flo: build fake repo > run installer per case > assert output and files > clean scratch
# I/O: scratch dir (disk) > ok/FAIL lines (stdout); exit 0 all pass, 1 any fail
# Run: bash ~/zz-base-home/as-apps/ai-mind/sk-skil-tool/sh-bins-inst-test.sh
# ===================================================================
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); inst=$here/sh-bins-inst.sh; root=$(mktemp -d); repo=$root/repo; sk=$repo/as-apps/ai-mind/sk-skil-tool; dist=$repo/as-apps/xx/fb-app/zig-out/dist/testdist; bin=$root/bin; skl=$root/skl; st=$root/st; fails=0
mkdir -p "$sk/face-book" "$sk/auto-task" "$dist" "$skl"
printf '{\n"fb":"face-book|as-apps/xx/fb-app",\n"zz":"nope-tool|as-apps/xx/none"\n}\n' > "$sk/so-skil-tool.json"
mkexe() { printf '#!/bin/sh\necho %s\n' "$1" > "$dist/fb"; chmod +x "$dist/fb"; touch -d "$2" "$dist/fb"; }
mkexe help-v1 '2020-01-01 00:00:00'
export ZZ_REPO=$repo ZZ_DIST=testdist ZZ_BIN=$bin ZZ_SKL=$skl ZZ_STATE=$st
run() { out=$(bash "$inst" "$@" 2>&1); rc=$?; }
has() { grep -qxF "$1" <<< "$out"; }
t() { if eval "$2"; then echo "ok $1"; else echo "FAIL $1 rc=$rc out=$(tr '\n' '|' <<< "$out")"; fails=$((fails+1)); fi; }
run --dry; t 'dry changes nothing' '[[ ! -e $bin && ! -e $skl/face-book && $rc -eq 0 ]]'
run; t 'first run copies exe' 'has "copied fb" && [[ -x $bin/fb && $rc -eq 0 ]]'
t 'first run links skills' 'has "linked face-book" && has "linked auto-task" && [[ -L $skl/face-book && -L $skl/auto-task ]]'
t 'missing src is reported' 'has "miss zz"'
t 'baseline hash saved' 'grep -Eq "^fb=[0-9a-f]{64}$" "$st/so-help-hash.txt"'
run; t 'second run is a no-op' '[[ $(wc -l <<< "$out") -eq 2 ]] && has "done copied=0 linked=0 unlinked=0 busy=0 miss=1 drift=0" && [[ $rc -eq 0 ]]'
mkdir -p "$sk/file-rena"; run; t 'new skill folder is linked' 'has "linked file-rena" && [[ -L $skl/file-rena ]]'
mkdir -p "$skl/real-dir" "$sk/real-dir"; run; t 'real folder clash is skipped' 'has "clash real-dir" && [[ ! -L $skl/real-dir ]]'
mv "$sk/real-dir" "$root/moved-real-dir"; mv "$sk/file-rena" "$root/moved-file-rena"; run; t 'dead link is removed' 'has "unlinked file-rena" && [[ ! -e $skl/file-rena && ! -L $skl/file-rena && -d $skl/real-dir ]]'
ln -s "$root/gone-dir" "$skl/foreign"; run; t 'foreign dead link is kept' '[[ -L $skl/foreign ]] && ! has "unlinked foreign"'
unlink "$skl/foreign"; printf '#!/bin/sh\necho local\n' > "$bin/fb"; touch -d '2025-01-01 00:00:00' "$bin/fb"; run; t 'older src never overwrites newer exe' '! has "copied fb" && grep -q local "$bin/fb"'
mkexe help-v2 '2030-01-01 00:00:00'; run --dry; t 'dry run keeps newer exe uncopied' 'has "would copy fb" && ! grep -q help-v2 "$bin/fb"'
run; t 'newer exe is copied' 'has "copied fb"'
t 'help change flags drift' 'has "drift face-book" && [[ $rc -eq 3 ]]'
run; t 'drift stays flagged' 'has "drift face-book" && [[ $rc -eq 3 ]]'
run --ack; t 'ack accepts new help' '! has "drift face-book" && [[ $rc -eq 0 ]]'
run; t 'clean after ack' '! has "drift face-book" && [[ $rc -eq 0 ]]'
run --bad; t 'bad flag exits 2' '[[ $rc -eq 2 ]]'
for l in "$skl"/*; do [[ -L $l ]] && unlink "$l"; done
rm -rf "$root"
[[ $fails -eq 0 ]] || { echo "FAIL total=$fails"; exit 1; }
echo "all ok"
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============