# Config

## Program
- Windows: `ru-shut-wind.bat` (starts `ru-shut-wind.ps1`) closes apps and shuts down. `ru-star-wind.vbs` opens apps at login.
- Linux: `ru-star-linu.sh`, `ru-shut-linu.sh`, `ct-auto-inst.sh`, `ru-shut-guar.sh`.
- Built with: Windows batch, PowerShell, VBScript, Bash 5. No build step.

## Settings: Linux
File: `aa-conf-main.env` next to the scripts. One `KEY=value` per line. `~` means your home folder. A shell variable of the same name overrides the file.

| Key | Default | Meaning |
|---|---|---|
| WORK_PATH | ~/zz-base-home | folder to open and save |
| CLOU_PATH | ~/04-clou-base | optional 2nd folder (cloud): file manager + its own VSCode window; empty = skip |
| DOWN_PATH | ~/Downloads | second folder window |
| FILE_MANA | nemo | file manager |
| CHRO_BINA | google-chrome | Chrome command |
| CHRO_DATA | ~/.config/chrome-launchers | folder holding one `launcher-<id>` Chrome data dir per taskbar icon |
| CHRO_PROF | default | launcher ids to open, in order |
| CODE_BINA | code | VSCode command |
| CMDR_BINA | auto-task in ac-auto-task/zig-out/bin | tr scheduler; empty = skip. Opens as a Chrome tab only |
| CMDR_PORT | 4000 | tr port; the tab opens in the first CHRO_PROF launcher |
| CMDR_JOBS | empty | tr jobs file for this device (plain name, e.g. aa-auto-task-mydevice.json); empty = default aa-auto-task.json |
| CMDR_DBGP | 9333 | debug port on the first Chrome launcher so shutdown can close the tr tab first; 0 = off |
| AISV_WDOG | empty (skip) | `ru-llam-watc.sh` of the AI server app (`ai-mind/lm-llam-serv`): starts llama-server and keeps it up. Its models and ports live in that app's `aa-conf-main.env` |
| AISV_VENV | empty (skip) | role of the second server: `visi` starts the vision server with the same watchdog |
| SYNC_CMDZ | `mise exec -- wo wipz --live` (wo found next to this app) | command run in WORK_PATH before apps close, saves your work to a private backup branch; full paths, no `~`; empty = skip; a missing tool only warns |
| POWE_CMDZ | systemctl poweroff | power-off command; must not be empty |
| COUN_SECO | 9 | cancel countdown, seconds |
| WAIT_SECO | 8 | seconds each app gets to close |
| OPEN_GAPS | 3 | seconds between Chrome windows |
| SKIP_LIST | cinnamon,cinnamon-panel,nemo-desktop,cinnamon-session,Xorg,gnome-shell,plasmashell | programs never closed |
| GUAR_HUBP | 4000 | tr port the night guard asks "is any job running?" |
| GUAR_ARMH | 23 | hour (0-23) of the first tick that arms the guard; later ticks check |
| GUAR_FORC | 2 | hour (0-23) when the guard powers off even if jobs never finish |
| GUAR_STAL | 3 | hours after that hour when an old arm is dropped, not acted on |
| GUAR_SELF | linu-shut-nigh | the guard's own job id; never counted as busy |
| GUAR_TERM | gnome-terminal -- | terminal that runs `ru-shut-linu.sh` (so the cancel key works) |
| GUAR_FLAG | ~/.ac-auto-task/shutdown-armed | arm flag file |
| GUAR_STAT | ~/.ac-auto-task/task-state | chain state folder; a chain waiting for its next step counts as a running job |

Allowed: numbers are whole numbers with no leading zero. A wrong key or number, or an empty `POWE_CMDZ`, stops the script and names the line.

## Settings: Windows
Edit the lines at the top of each file with Notepad, or put your own values in `aa-conf-main.env` (see One private file per device below).

| Setting | File | Default | Meaning |
|---|---|---|---|
| COUN_SECO | `ru-shut-wind.ps1` (line `$CF = @{`) | 9 | seconds of each cancel countdown |
| VSCO_BKUP_WIPE | `ru-shut-wind.ps1` | false | true = VSCode backup folder is renamed `Backups_<date>`, so VSCode stops offering unsaved edits (nothing is deleted) |
| WAIT_CODE · WAIT_APPS · WAIT_ELEC · WAIT_COOL | `ru-shut-wind.ps1` | 10 · 8 · 3 · 3 | seconds to wait for VSCode, each app, Electron, and before cancel exit or shut-down |
| WIFI_NAME · FOLD_LIST · PROF_LIST · CODE_OPEN · STIC_APPID · TR_EXEC · TR_PORT · EXTR_LIST · WAIT_SECO · PAUS_FOLD | `ru-star-wind.vbs` | see the file | WiFi name, folders (`%VAR%` allowed), Chrome profiles, VSCode on/off, Sticky Notes app id (empty = skip), tr exe (empty = skip; started hidden on `TR_PORT` 4000 only if it does not answer; the mini window opens only if none is open), extra scripts, wait seconds, pause after a folder (ms) |
| SYNC_EXEC · SYNC_ARGS | `ru-shut-wind.ps1` | mise + `wo wipz --live` | command that saves your work before apps close; missing tool = warning, shut-down goes on |

## One private file per device
File: `aa-conf-main.env` next to the scripts, for both Windows and Linux. It is git-ignored (`*.env`) and not tracked, so your WiFi, Chrome profiles and paths never reach git. A missing file or key = the defaults inside the scripts. A shell variable of the same name still wins.
- Windows login reads: `WIFI_NAME` · `PROF_LIST` (comma list, e.g. `Profile 3, Profile 2`) · `VSCO_BINA` (VSCode exe, tried first).
- Windows shutdown reads: any single-value setting of the table above, e.g. `SYNC_EXEC` · `COUN_SECO` · `VSCO_BKUP_WIPE=true`. Other keys are ignored.
- Linux reads every key of its table and accepts the Windows keys without using them.
- Windows reads the file as plain ASCII text: keep WiFi, profile and path values free of accents.
- The repo folder, `tr` exe and the keys script are found from where `ru-star-wind.vbs` sits; nothing to set.

## Input
- Linux: command flags `--dry-run` · `--auto` · `--remove` · `status` · `shortcuts` · `tick|arm|check|disarm|later <min>` (night guard).
- Windows: `ru-shut-wind.bat -Auto` = no admin prompt and no countdowns (for tr jobs). A key press during a countdown cancels.

## Output
- Console lines with `WARN` for anything skipped. Exit codes: 0 ok · 1 refused or failed · 2 usage.
- Files written: `~/.config/autostart/linux-machine-startup-shutdown.desktop` (renamed to `.off` when switched off); Chrome `Local State` and `Preferences` (exit flags fixed); the arm flag `GUAR_FLAG` (`.done` / `.off` marks beside it).
