# How to use zr

Commands below use `C:\zz\zr.exe`. Use your own path.

## Save your login
1. Run: `printf 'you@example.com\nyour-password\n' | C:\zz\zr.exe secret`
2. It prints `saved`. It never prints your password.

## Turn on real runs
1. Run: `C:\zz\zr.exe setup`
2. Log in by hand in the window if it asks.
3. Read the risk note. Then run: `C:\zz\zr.exe setup --yes`

## Sign up a new account
1. Save the login you want (see above).
2. Run: `C:\zz\zr.exe run signup --live`
3. Open your mailbox. Copy the 6-digit code.
4. Run: `C:\zz\zr.exe run verify-email --text 123456 --live`
5. Run: `C:\zz\zr.exe run login --live`

## Make an API key
1. Run: `C:\zz\zr.exe run key-create --title my-key --live`
2. Limit its credits: `C:\zz\zr.exe run key-cap --price 500 --live`

## Get a web page
1. Plain words: `C:\zz\zr.exe ask "get https://example.com as text" --live`
2. Devs: `C:\zz\zr.exe run fetch-run --url https://example.com --opt "js_render=true&premium_proxy=true" --text python --live`

## Look at your account
| Want | Command |
|---|---|
| Credits used | `zr run usage-view --live` |
| Plan | `zr run plan-view --live` |
| Invoices | `zr run invoice-list --live` |
| Request history | `zr run logs-view --live` |

## Do a risky act
Pay, cancel, delete, remove: add `--force`.
1. Preview: `C:\zz\zr.exe run plan-change --opt Business`
2. Do it: `C:\zz\zr.exe run plan-change --opt Business --live --force`

## Run a routine
1. List: `C:\zz\zr.exe jobs`
2. Plan: `C:\zz\zr.exe plan zero-start`
3. Approve: `C:\zz\zr.exe approve all`
4. Run: `C:\zz\zr.exe flow run zero-start --live`
It pauses when it needs you and goes on by itself.

## Check the site still matches
1. Run: `C:\zz\zr.exe map`
2. Lines starting with `GAP` are buttons it could not find. Fix them in `aa-conf-main.json` under `labl_over` or `path_over`.

## Other tools
| Task | Command |
|---|---|
| Status | `zr status` |
| Pause everything | `zr pause` (then `zr resume`) |
| Support folder | `zr report` |
| Backup | `zr backup` |

## Errors
| Message | Fix |
|---|---|
| no login on file | Run `zr secret`. |
| no consent on file | Run `zr setup --yes`. |
| needs your approval | Add `--live --force`. |
| button or box not found | Run `zr map`, then fix `labl_over`. |
| stopped by ZenRows | Finish the captcha or code in the window, then run again. |
| stopped for safety | Wait 24 hours. |
| daily limit reached | Wait, or raise the `capz_*` value. |
