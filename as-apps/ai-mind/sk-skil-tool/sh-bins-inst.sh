# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Install tool exes to PATH and link skills for Claude.
# Flo: find dist exes > copy to bin dir > add bin to PATH > link skill dirs
# I/O: repo dist exes + skill dirs (disk) > bin dir, shell rc, ~/.claude/skills links (disk)
# Run: bash ~/zz-base-home/as-apps/ai-mind/sk-skil-tool/sh-bins-inst.sh
# ===================================================================
set -eu
CF_REPO="${ZZ_REPO:-$HOME/zz-base-home}"; CF_BIN="$HOME/.zz-base-home-bin"; CF_SKL="$HOME/.claude/skills"; CF_SRC="$CF_REPO/as-apps/ai-mind/sk-skil-tool"
mkdir -p "$CF_BIN" "$CF_SKL"
find "$CF_REPO" -path '*/zig-out/dist/linux-x86_64/*' -type f -perm -u+x ! -path '*/zz-dele-auto/*' ! -name 'auto-task' ! -name 'cmd-run' | while read -r f; do cp -f "$f" "$CF_BIN/"; echo "copied $(basename "$f")"; done
grep -qs "$CF_BIN" "$HOME/.profile" || { echo "export PATH=\"\$PATH:$CF_BIN\"" >> "$HOME/.profile"; echo "PATH updated (re-login)"; }
for d in "$CF_SRC"/*/; do n=$(basename "$d"); [ -e "$CF_SKL/$n" ] || { ln -s "${d%/}" "$CF_SKL/$n"; echo "linked $n"; }; done
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============