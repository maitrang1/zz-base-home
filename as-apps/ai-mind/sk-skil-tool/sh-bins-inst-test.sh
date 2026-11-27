# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Test sh-bins-inst.sh on a scratch dir, never real paths.
# Flo: build fake repo > run installer per case > assert output and files > clean scratch
# I/O: scratch dir (disk) > ok/FAIL lines (stdout); exit 0 all pass, 1 any fail
# Run: bash ~/zz-base-home/as-apps/ai-mind/sk-skil-tool/sh-bins-inst-test.sh
# ===================================================================
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); inst=$here/sh-bins-inst.sh; root=$(mktemp -d); repo=$root/repo; srcz=$repo/as-apps/ai-mind/sk-skil-tool; dist=$repo/as-apps/xx/fb-app/zig-out/dist/testdist; binz=$root/bin; link=$root/link; stat=$root/stat; fail=0
mkdir -p "$srcz/face-book" "$srcz/auto-task" "$dist" "$link"
printf '{\n"fb":"face-book|as-apps/xx/fb-app",\n"zz":"nope-tool|as-apps/xx/none"\n}\n' > "$srcz/so-skil-tool.json"
mkexe() { printf '#!/bin/sh\necho %s\n' "$1" > "$dist/fb"; chmod +x "$dist/fb"; touch -d "$2" "$dist/fb"; }
mkexe help-v1 '2020-01-01 00:00:00'
export SKIL_REPO=$repo SKIL_DIST=testdist SKIL_BINZ=$binz SKIL_LINK=$link SKIL_STAT=$stat
runz() { outz=$(bash "$inst" "$@" 2>&1); code=$?; }
hasz() { grep -qxF "$1" <<< "$outz"; }
chek() { if eval "$2"; then echo "ok $1"; else echo "FAIL $1 code=$code out=$(tr '\n' '|' <<< "$outz")"; fail=$((fail+1)); fi; }
runz --dry; chek 'dry changes nothing' '[[ ! -e $binz && ! -e $link/face-book && $code -eq 0 ]]'
runz; chek 'first run copies exe' 'hasz "copied fb" && [[ -x $binz/fb && $code -eq 0 ]]'
chek 'first run links skills' 'hasz "linked face-book" && hasz "linked auto-task" && [[ -L $link/face-book && -L $link/auto-task ]]'
chek 'missing src is reported' 'hasz "miss zz"'
chek 'baseline hash saved' 'grep -Eq "^fb=[0-9a-f]{64}$" "$stat/so-help-hash.txt"'
chek 'path step skipped for a custom bin dir' '! grep -q "^pathed" <<< "$outz"'
runz; chek 'second run is a no-op' '[[ $(wc -l <<< "$outz") -eq 2 ]] && hasz "done copied=0 linked=0 unlinked=0 busy=0 miss=1 drift=0" && [[ $code -eq 0 ]]'
mkdir -p "$srcz/file-rena"; runz; chek 'new skill folder is linked' 'hasz "linked file-rena" && [[ -L $link/file-rena ]]'
mkdir -p "$link/real-dir" "$srcz/real-dir"; runz; chek 'real folder clash is skipped' 'hasz "clash real-dir" && [[ ! -L $link/real-dir ]]'
mkdir -p "$root/elsewhere" "$srcz/jct-clash"; ln -s "$root/elsewhere" "$link/jct-clash"; runz; chek 'foreign-target link clash is skipped' 'hasz "clash jct-clash" && [[ $(readlink "$link/jct-clash") == "$root/elsewhere" ]]'; mv "$srcz/jct-clash" "$root/moved-jct-clash"
mkdir -p "$srcz/dead-clash"; ln -s "$root/gone2" "$link/dead-clash"; runz; chek 'dead foreign link on a skill name is a clash, not a crash' 'hasz "clash dead-clash" && [[ $code -eq 0 ]]'; mv "$srcz/dead-clash" "$root/moved-dead-clash"
mv "$srcz/real-dir" "$root/moved-real-dir"; mv "$srcz/file-rena" "$root/moved-file-rena"; runz; chek 'dead link is removed' 'hasz "unlinked file-rena" && [[ ! -e $link/file-rena && ! -L $link/file-rena && -d $link/real-dir ]]'
ln -s "$root/gone-dir" "$link/foreign"; runz; chek 'foreign dead link is kept' '[[ -L $link/foreign ]] && ! hasz "unlinked foreign"'
unlink "$link/foreign"; printf '#!/bin/sh\necho local\n' > "$binz/fb"; touch -d '2025-01-01 00:00:00' "$binz/fb"; runz; chek 'older src never overwrites newer exe' '! hasz "copied fb" && grep -q local "$binz/fb"'
mkexe help-v2 '2030-01-01 00:00:00'; runz --dry; chek 'dry run keeps newer exe uncopied' 'hasz "would copy fb" && ! grep -q help-v2 "$binz/fb"'
runz; chek 'newer exe is copied' 'hasz "copied fb"'
chek 'help change flags drift' 'hasz "drift face-book" && [[ $code -eq 3 ]]'
runz; chek 'drift stays flagged' 'hasz "drift face-book" && [[ $code -eq 3 ]]'
runz --ack; chek 'ack accepts new help' '! hasz "drift face-book" && [[ $code -eq 0 ]]'
runz; chek 'clean after ack' '! hasz "drift face-book" && [[ $code -eq 0 ]]'
runz --bad; chek 'bad flag exits 2' '[[ $code -eq 2 ]]'
for item in "$link"/*; do [[ -L $item ]] && unlink "$item"; done
rm -rf "$root"
[[ $fail -eq 0 ]] || { echo "FAIL total=$fail"; exit 1; }
echo "all ok"
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============