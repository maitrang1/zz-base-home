# Updates

## 2026-11-26 (login watch)
Changed: `za-zalo-webs run read` with no chat name now reads every chat in `feed_chat_list` (a chat this account does not have is skipped); with an empty list it reads unread chats as before. A successful `read` also saves the login state as ok.
Fixed: a chat name with a no-break space (for example "Nhóm Doctorfarm" as Zalo shows it) is now found.
Added: `za-zalo-webs alive`: tells you if each account is still logged in. It reads the saved state (no network). When the last look is older than `aliv_look_hour` (8 hours) it also makes one read-only look at ONE account per run, so a 15-minute schedule never opens two accounts together. `--live` looks now. A dead login exits 3 and shows one alert per 6 hours with the exact `za-zalo-webs login --acct <id>` to run. Quiet hours skip the look. `za-zalo-webs login` saves ok; a run that hits a login wall saves needs-login.
Changed: the gap between accounts with `--acct all` is now 4 to 16 minutes (`acct_gap_secs` [240, 960]).

## 2026-11-26 (human pace)
Changed: waits now follow a human-like spread: mostly short, about one in five long, always inside your min and max. Each account gets its own speed that drifts slowly, and a long run gets a little slower. The mouse moves on a curved, eased path and lands a few pixels off center after a short hover. Typing has a pause between key down and up, a few overlapping keys and faster common letter pairs; long texts are pasted. Scrolling comes in flicks and sometimes goes back a little.
Changed: the daily work and break blocks now differ per account; the quiet-hours window starts a little earlier or later each day.
Changed (bad config, exit 2): a fixed random seed is refused, and settings that would make waits fixed or instant are refused: typing delay under 30 ms or with too little spread, action gap under 2 s, read delay under 200 ms.
Not included on purpose: fake typos, deliberate overshoot, detour clicks or anything meant to fool a bot detector.

## 2026-11-26 (command-line contract)
Changed: a bad config now exits 2 (was 1). An unknown name in `aa-conf-main.json` now stops the program instead of being ignored, so a typo can no longer silently turn a setting off. Bad flags and unknown commands name themselves on stderr.
Changed: running `za` with no command now prints usage on stderr and exits 2 (was exit 0); `za-zalo-webs --help` prints usage on stdout, exit 0.
Added: `--dry-run` (the default); with `--live` or `--force` it exits 2. `--json` is now always one document with `ok`, `cmd`, `exit`, `dry_run`, `code`, `msg`; old fields are unchanged.
Changed: `za-zalo-webs status` and `za-zalo-webs caps` no longer create folders or write to the database.

## 2026-11-26 (small browser window)
Changed: the visible browser window now opens small at the left edge, zoomed out. Hidden runs are unchanged. New settings brow_wind_widt, brow_wind_high, brow_wind_scal, brow_wind_left.
The shipped values (500, 1008, 1.0, -7) give a 400 by 800 window on a Windows screen set to 125%. Other screens need their own numbers; 0 turns a setting off. The page is about 500 wide in this window. Not tried on a real logged-in account.

## 2026-11-25 (feed for scra)
Added: `za-zalo-webs feed` hands the stored messages of the chats in `feed_chat_list` to scra as JSONL (`--live` writes the file, incremental per chat). Opt-in, no browser. New settings feed_*.

## 2026-11-24 (accounts)
Added: several accounts in one `user-acct.json` (names only, no passwords), picked with `--acct <id>` or run all with `--acct all` (one at a time, rotating order, random wait between accounts). Each account has its own browser profile, database, limits and stop state under `acct/<id>/`. Two accounts stopped for safety = nothing runs. `za-zalo-webs secret` lists the accounts. New settings `acct_maxx_coun`, `acct_gap_secs`, `secr_loca_main`. A routine can name an account.
Changed: your existing profile and data move into `acct/main/` the first time you run this version (moved, nothing deleted).
Tested with a fake runner and the mock page only: the full `--acct all` run with real browsers has not been tried.

## 2026-11-23 (account and settings)
Added: `za-zalo-webs flows` shows every Zalo Web action and who does it: built, gap (not checked on real Zalo yet), hand (you: QR, SMS code, password, captcha) or out (Zalo Web does not have it).
Added: jobs `logout`, `devices`, `devout <device>`, `notify on|off`, `lang vi|en`, `storage`, `help`, `feedback <text>`, `passwd`, `unfriend <name>`. Log out, remote log out, feedback and unfriend ask for `--live --force`.
Added: `passwd` opens the change-password page and stops; za never types a password or a code. New stop pages: "too many requests", "session expired", "browser not supported".

## 2026-11-21 (second build)
Added: send files and images (only from the outbox folder), stickers, replies, mentions, reactions, recall, delete, pin message, download, archive, hide, mark unread, alias, block.
Added: polls, notes, labels, quick messages, friend requests, message requests, group admin (rename, members, deputy, leave), profile read, My Cloud.
Added: open any chat by name or phone, scroll long lists, load old messages, pick between two chats with the same name (`#group`, `#person`).
Added: `za-zalo-webs plan`, `za-zalo-webs approve`, `za-zalo-webs go`, `za-zalo-webs flow`, `za-zalo-webs watch`: lists of jobs that run by themselves, wait only when Zalo needs you, stop on a lock or warning.
Added: `za-zalo-webs setup`, `za-zalo-webs matrix`, `za-zalo-webs export`, `za-zalo-webs report`, `za-zalo-webs backup`, `za-zalo-webs retry`, `za-zalo-webs undo last`, `za-zalo-webs purge`. Messages in Vietnamese or English.
Added: Zalo button names now live in `so-labl-zalo.json` in two languages; `za-zalo-webs probe` saves a page dump with personal text hashed; the canary checks every job and the Chrome version.
Added: popups are closed or stop the run; the message box is read back before sending; failed sends are never resent; folders are owner-only; chat text in logs is hashed; old chat text is deleted after 30 days.
Changed: `labl_*` settings moved into `so-labl-zalo.json`. Live runs need `za-zalo-webs setup --yes` once.
Fixed: a chat message containing "captcha" no longer stops za.

## 2026-11-21
Added: first version. Read unread chats, send once, reminders, pin, mute, group, forward, plain-words commands, optional AI price replies, status, caps, log, pause, stop, resume.
Added: human pace (random delays, mouse curves, typing), hourly and daily limits, one-week warm-up, quiet hours.
Added: automatic stop on lock, captcha, warning, logout and "logged in elsewhere" pages (English and Vietnamese).
