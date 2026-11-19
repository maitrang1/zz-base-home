# Updates

## 2026-11-19 · Old setup carried over
- Windows login now also starts the One-Tap Keys script (`ks-keys-shor`, as admin). It opens your WiFi, Sticky Notes, folders, Chrome profiles and VSCode, then starts the tr scheduler hidden (only if it is not already running) and opens its mini window (only if none is open). Linux does the same with a Chrome tab: no second tr, no second page.
- Windows shutdown saves your work with `wo wipz` first, then closes apps. New `ru-shut-wind.bat -Auto` skips the admin prompt and the countdowns (for scheduler jobs).
- Linux: the AI servers (text and vision) start from the new app `lm-llam-serv`; `AISV_PORT` and `AISV_VPORT` are gone here (ports live in that app's settings), `AISV_VENV` is now the role `visi`.
- Linux: the opener now starts tr (`ac-auto-task`) instead of cmd-run; new setting `CMDR_JOBS` picks this device's jobs file. The night guard asks tr on port 4000.
- New: one private file per device, `aa-conf-main.env`, now git-ignored and untracked. Your WiFi, Chrome profiles, VSCode path and device jobs file live only there; the scripts ship generic defaults. Windows scripts read it too (`WIFI_NAME`, `PROF_LIST`, `VSCO_BINA`, `SYNC_EXEC`, `COUN_SECO`, ...). All `*.env` files are git-ignored.
- Changed: the Chrome debug port that lets shutdown close the `tr` tab is now 8000 (was 9333); set it with `CMDR_DBGP`, `0` = off. The AI servers moved to ports 4004 and 4008 (see the AI server app).
- Changed: Linux shutdown now saves your work with `wo wipz --live` (setting `SYNC_CMDZ`), like Windows. The old `git-sync-safe-guard` and its `SYNC_BINA` setting are gone.
- Changed: the Windows scripts find the repo from where they sit (no fixed `E:` path), and Chrome exit-flag fixing now keeps the file as UTF-8 and leaves a clean file untouched. A missing `aa-conf-main.env` now means defaults on Linux too.
- Changed: a config error now names the file and the line (`config aa-conf-main.env line 1: ...`).
- Tested: 89 of 89 checks on Debian; PowerShell parse, a PowerShell reader check and a VBScript reader check ok.

## 2026-11-18 · One app for Windows and Linux
- Moved here as `ss-star-shut`: the Windows close-and-shut-down and auto-open scripts now sit beside the Linux ones.
- Changed: every file has a new short name (`ru-shut-wind.bat`, `ru-shut-wind.ps1`, `ru-star-wind.vbs`, `ru-*.sh` and others). Update any shortcut or job that used an old name.
- Changed: the license is now PolyForm Noncommercial 1.0.0 (was MIT).
- Added: the night guard is ready to wire as a job in the scheduler, off by default.
- Tested: the Linux scripts pass 76 of 76 checks on Debian after the rename.
- Changed: all scripts rewritten in the repo code style, tests split one file per script. The Windows VSCode backup option now moves the folder aside instead of deleting it; its settings have new names (see CONFIG.md).

## 2026-11-07 · Night guard arms on a late tick
- A busy hub could run the 23:00 tick late and skip arming, so the PC stayed on. The first tick of the 23:00 hour now arms, whatever the minute; a cancelled or finished night is not re-armed.

## 2026-11-07 · Night auto power-off
- One hub job `linu-shut-nigh` arms at 23:00, then powers the PC off once no job is running (checks every 15 minutes, 23:00-02:45 only).
- A job chain that is only pausing between steps counts as running.
- The car-publish chain no longer powers off by itself; the night guard does.
- At 02:00 it powers off even if a job never finishes. Hub down = no power-off.

## 2026-11-07 · Same look as Windows
- Open and close screens now use the same banners and countdown bar as the Windows helpers.
- Per-window lines are hidden; add `--verbose` to see them.

## 2026-11-01 · Power off from the hub
- The cmd-run job `face-cars-sale-publish` ends with step `linux-machine-shutdown`: after the 21-23h run it opens a terminal running `ru-shut-linu.sh` (9 s cancel countdown).

## 2026-10-04 · Safety fixes
- Closing now refuses to run (and powers nothing off) on Wayland, without a reachable X display, or with a wrong power-off command.
- Opening apps no longer hangs until Chrome quits.
- Chrome's "restore pages" fix now waits for Chrome to finish closing.
- Apps that refuse to close (unsaved work) are named before the power-off countdown.
- Autostart reports a failed write instead of saying "installed".

## 2026-10-04 · First release
- Open file manager, Chrome profiles, and VSCode with one command or at login.
- Close all apps safely, fix Chrome's "restore pages" prompt, then power off.
- Preview mode (`--dry-run`) and cancel countdown.

## 2026-11-15 · Moved
- Now lives in `91-iot-integration`; new `ct-auto-inst.sh shortcuts` rebuilds the shutdown icons/launchers after a move.
- New `CLOU_PATH` setting: also opens a cloud folder in the file manager and in VSCode at login.
