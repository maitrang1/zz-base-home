---
name: zalo-chat
description: Run the `za` CLI, the Zalo Web agent. Use when the user wants to read, reply, send, remind, forward, manage friends or groups, or do any task in Zalo (chat.zalo.me) for them.
---
# za — Zalo Web agent (human pace, own browser profile per account)
1. `za status --json` and `za caps --json` first (halted? sends left this hour/day).
2. Default = dry-run preview. `--read` = look only. `--live` = act. `--live --force` = bulk, group, forward.
3. NEVER add `--live` or `--force` unless the user said so in this turn. Show the dry-run first.
4. Never read or print login data; `za secret` lists accounts with masked phones only.
Commands: `za run <job> [words] [flags]` (jobs: `za matrix --json`) · `za plan '<item>' ...` · `za approve all|<ids>` · `za go [--live]` · `za flow list|run <name>` · `za watch [--live]` · `za log --json` · `za pause|stop|resume` · `za retry <id>` · `za undo last`.
Pick account: `--acct <id>|all`.
Exit: 0 ok · 1 fail · 2 usage · 3 finding · 4 blocked — 4 is normal, report it, never retry in a loop.
First run: `za setup`, `za login` (user scans the QR once).
Details: `E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\CLAUDE.md` · `za help`.
