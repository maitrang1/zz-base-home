# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Add, switch off or check the login entry
# Flo: pick action > write .desktop (5s delay) or rename to .off or report > result
# I/O: none | --remove | status | shortcuts > autostart .desktop file, launchers
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ct-auto-inst.sh
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dest="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
file="$dest/linux-machine-startup-shutdown.desktop"
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
shut_list() { printf '%s\n' "Shut_Down|bash $dirz/ru-shut-guar.sh later 0|system-shutdown|Wait until no hub job runs, then close apps + shutdown (9s cancel)" "Shut_01hr|bash $dirz/ru-shut-guar.sh later 60|time|In 1 hour, once no hub job runs: close apps + shutdown" "Shut_02h|bash $dirz/ru-shut-guar.sh later 120|time|In 2 hours, once no hub job runs: close apps + shutdown"; }
shortcuts() { local nam cmd ico com f tty n=0; while IFS='|' read -r nam cmd ico com; do [[ -z $nam ]] && continue; for f in "$HOME/Desktop/$nam.desktop" "$apps/$nam.desktop"; do [[ $f == "$apps/"* || -f $f ]] || continue; mkdir -p "$(dirname "$f")"; tty=false; [[ $cmd == *"later 0" ]] && tty=true; printf '[Desktop Entry]\nName=%s\nExec=%s\nComment=%s\nTerminal=%s\nIcon=%s\nType=Application\n' "$nam" "$cmd" "$com" "$tty" "$ico" > "$f" && n=$((n+1)); done; done < <(shut_list); echo "shortcuts written: $n"; }
inst_file() { mkdir -p "$dest" && printf '[Desktop Entry]\nType=Application\nName=Open work apps\nComment=linux-machine-startup-shutdown\nExec=bash "%s/ru-star-linu.sh"\nTerminal=false\nX-GNOME-Autostart-Delay=5\n' "$dirz" > "$file" || { echo "cannot write $file" >&2; exit 1; }; echo "installed: $file"; }
inst_off() { if [[ ! -f $file ]]; then echo "nothing to remove"; elif mv -f "$file" "$file.off"; then echo "switched off: $file.off"; else echo "cannot rename $file" >&2; exit 1; fi; }
inst_stat() { if [[ -f $file ]]; then echo "autostart: ON  ($file)"; elif [[ -f $file.off ]]; then echo "autostart: OFF ($file.off)"; else echo "autostart: not installed"; fi; }
case "${1:-}" in "") inst_file ;; --remove) inst_off ;; shortcuts) shortcuts ;; status) inst_stat ;; *) echo "Use: $0 [--remove|status|shortcuts]" >&2; exit 2 ;; esac
exit 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
