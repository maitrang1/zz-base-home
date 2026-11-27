---
name: file-rena
description: Run the `rn` CLI to rename a file or folder and fix every reference to it across the whole machine (any OS). Undoable. Use for any rename or move that other files point to.
---
# rn — rename + fix all refs
1. `rn stat` first (read-only).
2. `rn plan OLD NEW` previews every change. Review it with the user.
3. `rn runz OLD NEW --live` applies. Without `--live` it is a dry-run. NEVER add `--live` or `--force` unless the user said so in this turn.
4. Undo: `rn undo <id>|last`.
Flags: `--conf FILE` · `--json` · `--live [--force]`.
Hub job/step ids: use `ie`, not `rn`.
Never delete: renames only (repo rule: moves go to `zz-dele-auto/`).
Details: `E:\zz-base-home\as-apps\os-syst\rn-name-upda\CLAUDE.md` · `rn` (usage).
