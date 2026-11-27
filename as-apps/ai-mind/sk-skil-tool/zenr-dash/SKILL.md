---
name: zenr-dash
description: Run the `zr` CLI, the ZenRows dashboard agent. Use when the user wants to sign up, log in, create API keys, check usage, or fetch a page through ZenRows (zenrows.com) at a human pace.
---
# zr — ZenRows dashboard agent (human pace, own Chrome profile)
1. `zr status --json` first (limits, quiet hours, last stop).
2. `zr jobs` lists jobs (W = ok, X = needs user approval).
3. Default = dry-run preview. `--read` = read only. `--live` = do it. `--live --force` = also approve risky acts.
4. NEVER add `--live` or `--force` unless the user said so in this turn. Show the dry-run first.
5. Credentials: user runs `zr secret` themself (2 lines on stdin). Never ask for or print them.
Commands: `zr run <job> [flags]` (signup, login, key-create, fetch-run…) · `zr ask "<words>"` · `zr plan <routine>` · `zr approve all|1,3` · `zr flow run <routine>` · `zr log --json` · `zr pause|resume` · `zr doctor [job]`.
Raw mode (devs): `--opt "k=v&k=v"` request params, `--text python|node|go|curl` snippet language. Pick account: `--acct <id>|all`.
Exit: 0 ok · 1 fail · 2 usage · 3 page changed · 4 blocked — 4 is normal, report it, never retry in a loop.
Details: `E:\zz-base-home\as-apps\in-inte\zr-zrow-webs\CLAUDE.md` · `zr --help`.
