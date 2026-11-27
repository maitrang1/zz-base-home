# How to use or-orac-webs

Commands below use `C:\zz\or-orac-webs.exe`. Use your own path.

## Sign up for Free Tier (by hand, once)
1. Run: `C:\zz\or-orac-webs.exe login`
2. A Chrome window opens on Oracle Cloud. Open the sign-up page and fill the form. Oracle emails you a link: open it in the same window.
3. Pick a cloud account name and your home region. The home region cannot change later, and Always Free servers live only there.
4. Do the card check and phone check yourself. Oracle may hold a small amount and release it.
5. Do not use `--head` here: it hides the window.

## Log in (by hand)
1. Run: `C:\zz\or-orac-webs.exe login`
2. Type the cloud account name, then your user name, password and MFA code.
3. The terminal prints `logged in` and ends. The login stays in the app's own profile.

## Optional: let it fill the forms
Only the plain form steps. Save your login first (`printf 'you@example.com\nyour-password\n' | C:\zz\or-orac-webs.exe secret`) and put your cloud account name in `tena_name_main`. Then `run login --live`. Sign-up: `run signup --title Kim --desc Doe --opt Vietnam --live`, open the email link with `run verify-email --url <link> --live`, then `run signup-setup --opt "US West (Phoenix)" --live --force`. Prefer the by-hand way.

## Turn on real runs
1. Run: `C:\zz\or-orac-webs.exe setup`
2. Log in by hand in the window.
3. Read the risk note. Then run: `C:\zz\or-orac-webs.exe setup --yes`

## Check your free limits and cost
| Want | Command |
|---|---|
| Cost and usage | `or-orac-webs run usage-view --live` |
| Limits (A1 cores, memory) | `or-orac-webs run limits-view --live` |
| Find one limit | `or-orac-webs run limits-find --text A1 --live` |
| Free credits and plan | `or-orac-webs run plan-view --live` |
| CPU chart of a server | `or-orac-webs run metrics-view --title my-box --live` |
| Invoices | `or-orac-webs run invoice-list --live` |

## Set a budget alert
1. Make a budget: `C:\zz\or-orac-webs.exe run budget-create --title free-guard --price 1 --live`
2. Add an alert at 80 percent: `C:\zz\or-orac-webs.exe run budget-alert --title free-guard --price 80 --to you@example.com --live`

## Look at your servers and ports
1. Servers: `C:\zz\or-orac-webs.exe run inst-list --live`
2. One server: `C:\zz\or-orac-webs.exe run inst-view --title my-box --live`
3. Is a port open? `C:\zz\or-orac-webs.exe run secl-view --title my-network --live`

## Start, stop, create
| Want | Command |
|---|---|
| Start | `or-orac-webs run inst-start --title my-box --live` |
| Stop (risky) | `or-orac-webs run inst-stop --title my-box --live --force` |
| Create (risky) | `or-orac-webs run inst-create --title my-box --opt VM.Standard.A1.Flex --text "<your public key>" --live --force` |
"Out of host capacity" means Oracle has no free server right now. Run the same command later. It does not retry by itself.

## Make an API key
1. Run: `C:\zz\or-orac-webs.exe run key-create --text "<your public key text>" --live`
The app never makes or reads your private key.

## Do a risky act
Pay, upgrade, stop, open a port, delete, close: add `--force`.
1. Preview: `C:\zz\or-orac-webs.exe run payg-upgrade`
2. Do it: `C:\zz\or-orac-webs.exe run payg-upgrade --live --force`

## Several accounts
Save each login under its own name: `printf 'a@x.com\nPASS\n' | or-orac-webs secret --acct client1`, then `or-orac-webs secret list`. Add `--acct client1` to any command, or `--acct all` to run each one in turn. Each account has its own browser profile and limits. The limit is 1 (`acct_maxx_coun`); raise it only for accounts you own. Never open accounts to get more free credits.

## Run a routine
1. List: `C:\zz\or-orac-webs.exe jobs`
2. Plan: `C:\zz\or-orac-webs.exe plan free-guard`
3. Approve: `C:\zz\or-orac-webs.exe approve all`
4. Run: `C:\zz\or-orac-webs.exe flow run free-guard --live`
It pauses when it needs you and goes on by itself.

## Check the console still matches
1. Run: `C:\zz\or-orac-webs.exe map`
2. Lines starting with `GAP` are buttons it could not find. Fix them in `aa-conf-main.json` under `labl_over` or `path_over`.

## Other tools
| Task | Command |
|---|---|
| Status | `or-orac-webs status` |
| Pause everything | `or-orac-webs pause` (then `or-orac-webs resume`) |
| Support folder | `or-orac-webs report` |
| Backup | `or-orac-webs backup` |

## Errors
| Message | Fix |
|---|---|
| no login on file | Only for the optional form-fill jobs: run `or-orac-webs secret`. |
| no consent on file | Run `or-orac-webs setup --yes`. |
| needs your approval | Add `--live --force`. |
| button or box not found | Run `or-orac-webs map`, then fix `labl_over`. |
| stopped by Oracle | Finish the captcha, code or card check in the window, then run again. |
| stopped for safety | Wait 24 hours. |
| daily limit reached | Wait, or raise the `capz_*` value. |
