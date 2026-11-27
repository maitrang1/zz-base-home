---
name: face-book
description: Run the `fb` CLI, the Facebook WebUI agent. Use when the user wants to post, reply, accept friends, manage Marketplace listings, read notifications or inbox, or do any task on facebook.com for them.
---
# fb â€” Facebook agent (human pace, own Chrome profile)
1. `fb status --json` first (caps, quiet hours, last stop).
2. `fb jobs` lists jobs (W = ok, X = needs user approval).
3. Default = dry-run preview. `--read` = look only. `--live` = real. `--live --force` = also approve risky jobs.
4. NEVER add `--live` or `--force` unless the user said so in this turn. Show the dry-run first.
5. Never print secrets: `fb secret --json` shows field names only.
Commands: `fb run <job> [flags]` Â· `fb ask "<words>"` Â· `fb plan <flow>` Â· `fb approve all|1,3` Â· `fb flow run <flow>` Â· `fb read <noti|requests|birthdays|inbox|market-inbox|msgr-requests>` Â· `fb ledger` Â· `fb log --json` Â· `fb pause|resume` Â· `fb doctor [job]`.
Flags: --text --to --url --title --price --desc --group --photo --opt --date --time --catg --cond --loca --max N --conf <file> --acct <id>|all --head --yes.
Exit: 0 ok Â· 1 fail Â· 2 usage Â· 3 page changed Â· 4 blocked (quiet hours, cap, challenge, approval, rest) â€” 4 is normal, report it, never retry in a loop.
First run or login: `fb setup`, `fb login` (needs the user at the browser).
Details: `E:\zz-base-home\as-apps\ch-chat\fb-face-webs\CLAUDE.md` Â· `fb --help`.
