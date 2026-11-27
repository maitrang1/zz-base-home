---
name: jobs-rena
description: Run the `ie` CLI to rename a hub (`tr`) job id or chain step id and fix every use (job files, dispatchers, tests, docs, saved state, logs). Undoable. Use for any job-id or step-id rename.
---
# ie â€” rename hub job/step ids and fix all refs
1. `ie stat` first (read-only).
2. `ie plan old=new ...` previews every change. Review it with the user.
3. `ie run old=new ... --live` applies. Without `--live` it is a dry-run. NEVER add `--live` or `--force` unless the user said so in this turn.
4. Undo: `ie undo <id>|last`.
Flags: `--conf FILE` Â· `--json` Â· `--dry-run | --live [--force]` Â· `--map FILE` Â· `--scope all|repo|state` Â· `--no-docs`.
Not for file/folder renames: use `rn`.
Exit: 0 ok Â· 1 fail Â· 2 usage Â· 4 blocked.
Details: `E:\zz-base-home\as-apps\os-syst\id-edit-iden\CLAUDE.md` Â· `ie` (usage).
