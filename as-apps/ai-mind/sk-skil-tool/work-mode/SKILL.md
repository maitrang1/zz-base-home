---
name: work-mode
description: Run the `wo` CLI, the zz-base-home work-mode control. Use for drift checks, WIP snapshots, restore drills, the kill switch, CI or secrets status, or any "work mode" question about the repo.
---
# wo â€” work-mode control (drift Â· snapshot Â· drill Â· kill switch)
1. `wo stat --json` first (read-only).
2. Commands: `stat` Â· `conf` Â· `doct` Â· `wipz` Â· `dril` Â· `kill` Â· `secr init|lend`. Flags: `--conf FILE` Â· `--prof t0|ci` Â· `--json` Â· `--live [--force]`.
3. Writes need `--live`. NEVER add `--live` or `--force` unless the user said so in this turn.
4. Never read or print a secret value.
5. Not a scheduler: jobs go in the `tr` job file.
Exit: 0 ok Â· 1-4 per `ct-exit-code.zig` (safety ladder).
Design: `E:\zz-base-home\do-long-guid\wo-work-mode.txt` Â· App: `E:\zz-base-home\as-apps\os-syst\wo-work-mode\CLAUDE.md`.
