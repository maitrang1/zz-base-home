# How to use fb

Replace `fb` below with the full path: `E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe`

Every command shows a preview by default. Add `--live` to do it for real. See every job with `fb jobs`.

## First run
1. `fb setup`: opens the browser, you log in by hand, it checks the buttons and shows a demo preview.
2. Read the risk note, then `fb setup --yes`.
3. `fb doctor`: checks the buttons fb needs. If a line says MISSING, see "Fix a button name" below.

## Start from zero (only a login and a password)
1. Create the secrets file `acct.json` in `~/.zz-base-home-secr/as-apps/ch-chat/fb-face-webs/` (Windows: your user folder). Only the fields you need, for example `{"login":"you@mail.com","pass":"your password"}`. Other fields: `newp` (new password), `firs` and `last` (name), `mail`, `birt` (birthday, YYYY-MM-DD).
2. `fb secret` shows which fields are filled (never the values).
3. `fb setup --yes` once (risk note), then `fb start --live`: it logs in, checks the buttons and maps the site's pages. If Facebook asks for a code or approval, you do that in the browser window; fb waits and continues.
4. `fb gaps`: shows buttons that changed and new buttons no job knows. `fb gaps matrix` lists every job by area.
fb never types your password on the command line and never prints it. A wrong password stops fb (no retry loop).

## Account, settings, data, money, access, help
Every job shows in `fb jobs`: **A** runs by itself, **G** is guarded (needs your OK: `--force` or `fb approve`), **H** assist: fb prepares the page, then stops for the step only you can do (codes, card entry, the final delete or pay click) and continues after.
```
fb run acct-pass-change --live --force
fb run acct-2fa-setup --live --force
fb run sett-audience-default --opt Friends --live
fb run data-download-request --live
fb run data-download-get --live
fb run mone-billing --live
fb run acce-role-add --to "Ann Lee" --opt Editor --live --force
fb run help-search --text "recover account" --live
```
- Deactivate and delete (`acct-deactivate`, `acct-delete`) open the exact page and wait: you press the last button yourself.
- Money jobs are off until you set `capz_mone_dayz` and a budget limit `mone_spen_capz` in your settings. Ads, boosts and payments always stop for you before the final click.
- Sign-up (`acct-signup`) is only for your own new account, one try per run; you enter the code Facebook sends.

## Run a routine by itself (recommended)
A routine is a list of jobs in your settings (`flow_list`). The example `morning` replies to comments and messages and renews your listings.
1. See what it will do: `fb plan morning`
2. Approve the risky items once: `fb approve all` (or `fb approve 1,3`). Refuse with `fb deny 2`.
3. Run it: `fb flow run morning --live`
It runs by itself and stops only when it needs you, for example a Facebook security check. You get a message (in `alerts.txt` and a desktop popup). Finish the check in the browser window. fb waits, then continues the same step by itself and works at half speed for 24 hours.
If Facebook warns or limits the account, fb stops the whole routine and rests 24 hours. `fb resume` ends the rest early (not recommended).
Items you did not approve are skipped, not stuck. Look at the result with `fb flow show`.

## Log in again
```
fb login
```

## Posts
```
fb run post --text "Hello everyone" --live
fb run post-photo --text "New bike" --photo C:\pics\bike.jpg --live
fb run post-poll --text "Which color?" --title Red --desc Blue --live
fb run post-edit --url /posts/123 --text "New text" --live
fb run post-comment --url /posts/123 --text "Nice!" --live
fb run post-react --url /posts/123 --live
fb run post-share --url /posts/123 --live
```
Delete a post (needs your OK): `fb run post-delete --url /posts/123 --live --force`

## Friends, groups, pages
```
fb run friend-accept --live
fb run friend-follow --url /people/123 --live
fb run join --url /groups/123/ --live
fb run page --url /pages/123/ --text "News" --live
```
Unfriend, block, decline, leave a group, remove a post: add `--force`.

## Messages
```
fb read inbox
fb run msgr-reply --live
fb run market-reply --live
fb run dm --to 100012345 --text "Hi" --live
```
A person you never wrote to needs your OK (`--force`). Buyers on Marketplace get the texts in `inqu_temp_list`.

## Marketplace
```
fb run list --title "Red bike" --price 2000000 --desc "Like new" --group "Bike Club HN" --live
fb run list --title "Red bike" --price 2000000 --catg Bikes --cond Used --loca Hanoi --live
fb run renewall --live
fb run sold --title "Red bike" --live
fb run mark-share --title "Red bike" --group "Bike Club HN, Home Goods" --live
fb ledger
```
Mark items sold from group posts: `fb run sale-scan --url /groups/123/` shows them; add `--live --force` to mark them.

## Events, stories, profile
```
fb run event-create --title "Bike meetup" --date 2026-12-05 --desc "Bring bikes" --live
fb run story-create --photo C:\pics\day.jpg --live
fb run profile-bio --text "New bio" --live
```

## Use plain words
```
fb ask "reply to my comments" --live
fb ask "renew my listings" --live
fb ask "mark Red bike sold" --live
```

## Map the site
`fb map` visits a short list of Facebook pages (settings, Accounts Center, activity log and more), slowly, and saves the names of their buttons and boxes in your data folder (`stat/map/<date>/`). It never clicks or types. `fb gaps` then compares that map with the jobs.

## Check things
```
fb status
fb log
fb read noti
fb pause
fb resume
```
If a job says "an earlier try may have gone through": check Facebook, then `fb unlock "<key shown>"`.

## Fix a button name
Facebook shows different words in different languages. `fb doctor` lists what is MISSING. Add the real word in your settings under `labl_over`, for example:
`"labl_over": { "noti_mark": ["Mark all as read"] }`
Then run `fb doctor` again.

## Your data
- `fb report`: makes a support folder with no cookies and no private text.
- `fb backup`: copies your data. `fb export`: your ledger and log as files. `fb purge`: deletes logs older than 30 days.

## Errors
| Message | Fix |
|---|---|
| stopped by Facebook | Open Facebook yourself, clear the check, run `fb login` |
| stopped for safety | Do nothing for 24 hours |
| not logged in | Run `fb login` |
| no consent on file | Run `fb setup`, then `fb setup --yes` |
| already running | Another fb run uses the browser: wait |
| daily limit reached | Wait, or raise the `capz_*` value slowly |
| quiet hours | Run later, or change `quie_hour_rang` |
| needs your approval | `fb plan`, then `fb approve all`, or add `--live --force` |
| button or box not found | `fb doctor`, then fix `labl_over` |
| no browser | Install Chrome, or set `brow_exec_path` |
