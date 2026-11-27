# Updates

## 2026-11-24 (manual login)
Changed: login and sign-up are done by hand in zr's own window (Cloudflare check, email code). The saved-login jobs (`login`, `signup`, `verify-email`) are optional. `zr-zrow-webs login` is the main way; the login stays in zr's browser profile.
Fixed: the folder lock-down could lock you out on a PC where your user name equals the PC name (AccessDenied). It now grants by account id and only then removes inherited access. Help now says `--head` hides the window.

## 2026-11-24 (accounts)
Added: several accounts in one `user-acct.json`, picked with `--acct <id>` or run all with `--acct all` (one at a time, rotating order, random wait between accounts). Each account has its own browser profile, database and limits under `acct/<id>/`. Two accounts resting = all rest. `zr-zrow-webs secret --acct <id>` saves one login, `zr-zrow-webs secret list` shows them. New settings `acct_maxx_coun` (3), `acct_gap_secs`. Routine items can name an account.
Changed: your existing profile and data move into `acct/main/` the first time you run this version (moved, nothing deleted). The login file is now `user-acct.json`; the old `zr-login.json` is still read.
Tested with a fake runner and the practice site only: the full `--acct all` run with real browsers has not been tried.

## 2026-11-24
Added: first release of `zr`. 53 jobs for account, products, data, money, access, settings and help.
Added: plain-word mode (`zr-zrow-webs ask`) and raw mode (`--opt`, `--text`).
Added: `zr-zrow-webs map` crawls the live site and lists buttons that do not match.
Added: routines with plan and approve; pauses for captcha, 2FA, email code.
Added: Windows, Linux and macOS builds.
Changed: nothing yet.
Fixed: nothing yet. Not yet checked on the live ZenRows site.
