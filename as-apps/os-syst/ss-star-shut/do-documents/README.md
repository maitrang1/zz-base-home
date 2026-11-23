# Startup & Shutdown

Open your whole work setup at login. Close it all cleanly and power off with one command. Windows and Linux.
No cloud, no account.

## What you get
1. Opens your folders, Chrome profiles and VSCode at login.
2. Saves your git work, closes every app politely, then powers off.
3. Any key during the countdown cancels it.
4. Linux only: an optional night guard powers off after the night jobs finish.

## Requirements
- Windows 10 or later: nothing to install.
- Linux Mint Cinnamon (X11, not Wayland): `sudo apt install wmctrl`.

## Quick start
Windows: double-click `ru-shut-wind.bat`, click **Yes** on the admin box, press any key to cancel.
Linux:
1. `sudo apt install wmctrl`
2. `bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-star-linu.sh --dry-run`
3. You see a list of what would open. Run it without `--dry-run` to open them.

## Key behavior
- Nothing is force-killed. An app with unsaved work stays open and shows a warning.
- A missing app or folder is skipped with a warning. The run goes on.
- `--dry-run` (Linux) does nothing but print.

## License
PolyForm Noncommercial 1.0.0: free for personal use, a paid license for commercial use. Full text: LICENSE.

## Next
- Steps for each task: HOW-TO.md
- Every setting: CONFIG.md
- What changed: UPDATE.md
- License text: LICENSE
