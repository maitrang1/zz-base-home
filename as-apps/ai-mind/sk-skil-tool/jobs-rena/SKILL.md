---
name: jobs-rena
description: Run the `ie` CLI to rename a hub (`tr`) job id or chain step id and fix every use (job files, dispatchers, tests, docs, saved state, logs). Undoable. Use for any job-id or step-id rename.
---
# ie — rename hub job/step ids and fix all refs
1. `ie stat` first (read-only).
2. `ie plan old=new ...` previews every change. Review it with the user.
3. `ie run old=new ... --live` applies. Without `--live` it is a dry-run. NEVER add `--live` or `--force` unless the user said so in this turn.
4. Undo: `ie undo <id>|last` previews; add `--live` to apply. A crashed run blocks `run` until `ie undo <id> --live --force` closes it (`ie stat` shows it).
Flags: `--conf FILE` · `--json` · `--dry-run | --live [--force]` · `--map FILE` · `--scope all|repo|state` · `--no-docs`.
Not for file/folder renames: use `rn`.
Exit: 0 ok · 1 fail · 2 usage · 3 finding (leftover or hub mismatch: read the output) · 4 blocked.
Details: `E:\zz-base-home\as-apps\os-syst\id-edit-iden\CLAUDE.md` · `ie` (usage).
