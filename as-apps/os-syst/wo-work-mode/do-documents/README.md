# wo

One small command that keeps your work safe: it checks your device is healthy, saves your unsaved work, tests your backups and can switch the agents off.

## What it does
`wo` runs one job per command. It never changes anything unless you add `--live`. It never prints or reads your secrets.

## Requirements
- Windows, Linux or macOS
- `git` installed
- For the full set of jobs: `gitleaks`, `restic`, `sqlite3`, `tailscale` and `gh` (each job tells you if one is missing)

## Quick start
1. Open a terminal.
2. Run:
`E:\zz-base-home\wo-work-mode\zig-out\bin\wo-work-mode.exe stat`
3. You see the version and when each job last ran:
```
okay	vers	wo-work-mode 0.1.0
skip	wipz	none yet
skip	bkup	none yet
skip	bknt	none yet
skip	dril	none yet
```
4. Check this device:
`E:\zz-base-home\wo-work-mode\zig-out\bin\wo-work-mode.exe doct`

## Key behavior
- Exit code 0 = fine · 3 = something drifted · 4 = a check could not run · 1 = failed · 2 = wrong command.
- Nothing changes until you add `--live`.
- State is kept in `as-apps/os-syst/wo-work-mode` under the tena root (Windows `E:\.zz-base-home-tena`, other systems `~/.zz-base-home-tena`).

## Next
- [HOW-TO.md](HOW-TO.md): every command, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed
