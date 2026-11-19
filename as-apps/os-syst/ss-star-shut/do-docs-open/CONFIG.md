# Config

## Program
- Windows: `ru-shut-wind.bat` (starts `ru-shut-wind.ps1`) closes apps and shuts down. `ru-star-wind.vbs` opens apps at login.
- Linux: `ru-star-linu.sh`, `ru-shut-linu.sh`, `ct-auto-inst.sh`, `ru-shut-guar.sh`.
- Built with: Windows batch, PowerShell, VBScript, Bash 5. No build step.

## Settings: Linux
File: `aa-conf-main.env` next to the scripts. One `KEY=value` per line. `~` means your home folder. A shell variable of the same name overrides the file.

| Key | Default | Meaning |
|---|---|---|
| WORK_PATH | ~/00_modules | folder to open and git-sync |
| CLOU_PATH | ~/04-clou-base | optional 2nd folder (cloud): file manager + its own VSCode window; empty = skip |
| DOWN_PATH | ~/Downloads | second folder window |
| FILE_MANA | nemo | file manager |
| CHRO_BINA | google-chrome | Chrome command |
| CHRO_DATA | ~/.config/chrome-launchers | folder holding one `launcher-<id>` Chrome data dir per taskbar icon |
| CHRO_PROF | default,p1 | launcher ids to open, in order |
| CODE_BINA | code | VSCode command |
| CMDR_BINA | cmd-run in 04-sche-task/zig-out/bin | cmd-run server; empty = skip. Opens as a Chrome tab only |
| CMDR_PORT | 3030 | cmd-run port; the tab opens in the first CHRO_PROF launcher |
| CMDR_DBGP | 9333 | debug port on the first Chrome launcher so shutdown can close the cmd-run tab first; 0 = off |
| AISV_WDOG | 04-sche-task/00-start/ai-lin-watchdog.sh | starts the local AI server and keeps it up; empty = skip |
| AISV_PORT | 3010 | local AI server port |
| AISV_VENV | 04-sche-task/00-start/ai-vision.env | settings file of the vision server; empty = skip |
| AISV_VPORT | 3011 | vision server port |
| SYNC_BINA | git-sync-safe-guard in 82-document-storage | git sync before closing (skipped if missing) |
| POWE_CMDZ | systemctl poweroff | power-off command; must not be empty |
| COUN_SECO | 9 | cancel countdown, seconds |
| WAIT_SECO | 8 | seconds each app gets to close |
| OPEN_GAPS | 3 | seconds between Chrome windows |
| SKIP_LIST | cinnamon,cinnamon-panel,nemo-desktop,cinnamon-session,Xorg,gnome-shell,plasmashell | programs never closed |
| GUAR_HUBP | 3030 | cmd-run port the night guard asks "is any job running?" |
| GUAR_ARMH | 23 | hour (0-23) of the first tick that arms the guard; later ticks check |
| GUAR_FORC | 2 | hour (0-23) when the guard powers off even if jobs never finish |
| GUAR_STAL | 3 | hours after that hour when an old arm is dropped, not acted on |
| GUAR_SELF | linu-shut-nigh | the guard's own job id; never counted as busy |
| GUAR_TERM | gnome-terminal -- | terminal that runs `ru-shut-linu.sh` (so the cancel key works) |
| GUAR_FLAG | ~/.cmd-run/shutdown-armed | arm flag file |
| GUAR_STAT | ~/.cmd-run/task-state | chain state folder; a chain waiting for its next step counts as a running job |

Allowed: numbers are whole numbers with no leading zero. A wrong key or number, or an empty `POWE_CMDZ`, stops the script and names the line.

## Settings: Windows
Edit the lines at the top of each file with Notepad.

| Setting | File | Default | Meaning |
|---|---|---|---|
| COUN_SECO | `ru-shut-wind.ps1` (line `$CF = @{`) | 9 | seconds of each cancel countdown |
| VSCO_BKUP_WIPE | `ru-shut-wind.ps1` | false | true = VSCode backup folder is renamed `Backups_<date>`, so VSCode stops offering unsaved edits (nothing is deleted) |
| WAIT_CODE · WAIT_APPS · WAIT_ELEC · WAIT_COOL | `ru-shut-wind.ps1` | 10 · 8 · 3 · 3 | seconds to wait for VSCode, each app, Electron, and before cancel exit or shut-down |
| WIFI_NAME · FOLD_LIST · PROF_LIST · CODE_OPEN · EXTR_LIST · WAIT_SECO · PAUS_FOLD | `ru-star-wind.vbs` | see the file | WiFi name, folders, Chrome profiles, VSCode on/off, extra scripts, wait seconds, pause after a folder (ms) |

## Input
- Linux: command flags `--dry-run` · `--auto` · `--remove` · `status` · `shortcuts` · `tick|arm|check|disarm|later <min>` (night guard).
- Windows: none. A key press during a countdown cancels.

## Output
- Console lines with `WARN` for anything skipped. Exit codes: 0 ok · 1 refused or failed · 2 usage.
- Files written: `~/.config/autostart/linux-machine-startup-shutdown.desktop` (renamed to `.off` when switched off); Chrome `Local State` and `Preferences` (exit flags fixed); the arm flag `GUAR_FLAG` (`.done` / `.off` marks beside it).
