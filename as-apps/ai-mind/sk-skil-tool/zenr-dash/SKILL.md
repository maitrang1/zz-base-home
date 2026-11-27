---
name: zenr-dash
description: Run the `zr` CLI, the ZenRows dashboard agent. Use when the user wants to sign up, log in, create API keys, check usage, or fetch a page through ZenRows (zenrows.com) at a human pace.
---
# zr â€” ZenRows dashboard agent (human pace, own Chrome profile)
1. `zr status --json` first (limits, quiet hours, last stop).
2. `zr jobs` lists jobs (W = ok, X = needs user approval).
3. Default = dry-run preview. `--read` = read only. `--live` = do it. `--live --force` = also approve risky acts.
4. NEVER add `--live` or `--force` unless the user said so in this turn. Show the dry-run first.
5. Credentials: user runs `zr secret` themself (2 lines on stdin). Never ask for or print them.
Commands: `zr run <job> [flags]` (signup, login, key-create, fetch-runâ€¦) Â· `zr ask "<words>"` Â· `zr plan <routine>` Â· `zr approve all|1,3` Â· `zr flow run <routine>` Â· `zr log --json` Â· `zr pause|resume` Â· `zr doctor [job]`.
Raw mode (devs): `--opt "k=v&k=v"` request params, `--text python|node|go|curl` snippet language. Pick account: `--acct <id>|all`.
Exit: 0 ok Â· 1 fail Â· 2 usage Â· 3 page changed Â· 4 blocked â€” 4 is normal, report it, never retry in a loop.
Details: `E:\zz-base-home\as-apps\in-inte\zr-zrow-webs\CLAUDE.md` Â· `zr --help`.
