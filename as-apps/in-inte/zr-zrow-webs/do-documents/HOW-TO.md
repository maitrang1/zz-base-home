# How to use zr

Commands below use `C:\zz\zr-zrow-webs.exe`. Use your own path.

## Log in or sign up (by hand, once)
1. Run: `C:\zz\zr-zrow-webs.exe login`
2. A Chrome window opens on ZenRows. Tick the Cloudflare box.
3. Sign up or log in there. Type the 6-digit email code yourself.
4. The terminal prints `logged in` and ends. The login stays in zr's own profile.
5. Do not use `--head` here: it hides the window.
If Cloudflare keeps looping in the window, stop and tell the developer.

## Optional: let zr fill the login form
Only if Cloudflare lets it through. Save the login first (`printf 'you@example.com\nyour-password\n' | C:\zz\zr-zrow-webs.exe secret`), then `C:\zz\zr-zrow-webs.exe run login --live`. Sign-up: `run signup --live`, then `run verify-email --text 123456 --live`. Prefer the by-hand way above.

## Several accounts
Save each login under its own name (email on line 1, password on line 2), for example `printf 'a@x.com\nPASS\n' | zr-zrow-webs secret --acct team1`, then `zr-zrow-webs secret list` shows the ids. The old one-login file still works.
- One account: add `--acct team1` to any command.
- All accounts: `--acct all`, for example `zr-zrow-webs flow run morning --live --acct all`. zr runs them one at a time, in a different order each day, and waits 5 to 20 minutes between accounts.
- Each account has its own browser profile, limits and safety rest, in `acct/<id>/` inside your data folder. Never log two accounts into one window.
- If one account is warned or limited, only it rests. If two are, every account rests.
- Limit: 3 accounts (`acct_maxx_coun`, at most 20). Use only accounts you own, for example separate teams. Never open accounts to get more free credits.
- In a routine, an item can name an account: `{"job":"usage-view","acct":"team2"}`.

## Turn on real runs
1. Run: `C:\zz\zr-zrow-webs.exe setup`
2. Log in by hand in the window (Cloudflare tick, password, email code).
3. Read the risk note. Then run: `C:\zz\zr-zrow-webs.exe setup --yes`

## Make an API key
1. Run: `C:\zz\zr-zrow-webs.exe run key-create --title my-key --live`
2. Limit its credits: `C:\zz\zr-zrow-webs.exe run key-cap --price 500 --live`

## Get a web page
1. Plain words: `C:\zz\zr-zrow-webs.exe ask "get https://example.com as text" --live`
2. Devs: `C:\zz\zr-zrow-webs.exe run fetch-run --url https://example.com --opt "js_render=true&premium_proxy=true" --text python --live`

## Look at your account
| Want | Command |
|---|---|
| Credits used | `zr-zrow-webs run usage-view --live` |
| Plan | `zr-zrow-webs run plan-view --live` |
| Invoices | `zr-zrow-webs run invoice-list --live` |
| Request history | `zr-zrow-webs run logs-view --live` |

## Do a risky act
Pay, cancel, delete, remove: add `--force`.
1. Preview: `C:\zz\zr-zrow-webs.exe run plan-change --opt Business`
2. Do it: `C:\zz\zr-zrow-webs.exe run plan-change --opt Business --live --force`

## Run a routine
1. List: `C:\zz\zr-zrow-webs.exe jobs`
2. Plan: `C:\zz\zr-zrow-webs.exe plan zero-start`
3. Approve: `C:\zz\zr-zrow-webs.exe approve all`
4. Run: `C:\zz\zr-zrow-webs.exe flow run zero-start --live`
It pauses when it needs you and goes on by itself.

## Check the site still matches
1. Run: `C:\zz\zr-zrow-webs.exe map`
2. Lines starting with `GAP` are buttons it could not find. Fix them in `aa-conf-main.json` under `labl_over` or `path_over`.

## Other tools
| Task | Command |
|---|---|
| Status | `zr-zrow-webs status` |
| Pause everything | `zr-zrow-webs pause` (then `zr-zrow-webs resume`) |
| Support folder | `zr-zrow-webs report` |
| Backup | `zr-zrow-webs backup` |

## Errors
| Message | Fix |
|---|---|
| no login on file | Only for the optional form-fill jobs: run `zr-zrow-webs secret`. |
| no consent on file | Run `zr-zrow-webs setup --yes`. |
| needs your approval | Add `--live --force`. |
| button or box not found | Run `zr-zrow-webs map`, then fix `labl_over`. |
| stopped by ZenRows | Finish the captcha or code in the window, then run again. |
| stopped for safety | Wait 24 hours. |
| daily limit reached | Wait, or raise the `capz_*` value. |
