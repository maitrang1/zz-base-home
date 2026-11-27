---
name: work-mode
description: Run the `wo` CLI, the zz-base-home work-mode control. Use for drift checks, WIP snapshots, restore drills, the kill switch, CI or secrets status, or any "work mode" question about the repo.
---
# wo — work-mode control (drift · snapshot · drill · kill switch)
1. `wo stat --json` first (read-only).
2. Commands: `stat` · `conf` · `doct` · `wipz` · `dril` · `kill` · `secr init|lend`. Flags: `--conf FILE` · `--prof t0|ci` · `--json` · `--live [--force]`.
3. Writes need `--live`. NEVER add `--live` or `--force` unless the user said so in this turn.
4. Never read or print a secret value.
5. Not a scheduler: jobs go in the `tr` job file.
Exit: 0 ok · 1-4 per `ct-exit-code.zig` (safety ladder).
Design: `E:\zz-base-home\do-long-guid\wo-work-mode.txt` · App: `E:\zz-base-home\as-apps\os-syst\wo-work-mode\CLAUDE.md`.
