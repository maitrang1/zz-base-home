# Updates

## 2026-11-26 (command-line contract)
Changed: a bad config now exits 2 (was 1). An unknown name in `aa-conf-main.json` now stops the program instead of being ignored, so a typo can no longer silently turn a setting off. Bad flags and unknown commands name themselves on stderr.
Changed: running `za` with no command now prints usage on stderr and exits 2 (was exit 0); `za --help` prints usage on stdout, exit 0.
Added: `--dry-run` (the default); with `--live` or `--force` it exits 2. `--json` is now always one document with `ok`, `cmd`, `exit`, `dry_run`, `code`, `msg`; old fields are unchanged.
Changed: `za status` and `za caps` no longer create folders or write to the database.

## 2026-11-26 (small browser window)
Changed: the visible browser window now opens small at the left edge, zoomed out. Hidden runs are unchanged. New settings brow_wind_widt, brow_wind_high, brow_wind_scal, brow_wind_left.
The shipped values (500, 1008, 1.0, -7) give a 400 by 800 window on a Windows screen set to 125%. Other screens need their own numbers; 0 turns a setting off. The page is about 500 wide in this window. Not tried on a real logged-in account.

## 2026-11-25 (feed for scra)
Added: `za feed` hands the stored messages of the chats in `feed_chat_list` to scra as JSONL (`--live` writes the file, incremental per chat). Opt-in, no browser. New settings feed_*.

## 2026-11-24 (accounts)
Added: several accounts in one `user-acct.json` (names only, no passwords), picked with `--acct <id>` or run all with `--acct all` (one at a time, rotating order, random wait between accounts). Each account has its own browser profile, database, limits and stop state under `acct/<id>/`. Two accounts stopped for safety = nothing runs. `za secret` lists the accounts. New settings `acct_maxx_coun`, `acct_gap_secs`, `secr_loca_main`. A routine can name an account.
Changed: your existing profile and data move into `acct/main/` the first time you run this version (moved, nothing deleted).
Tested with a fake runner and the mock page only: the full `--acct all` run with real browsers has not been tried.

## 2026-11-23 (account and settings)
Added: `za flows` shows every Zalo Web action and who does it: built, gap (not checked on real Zalo yet), hand (you: QR, SMS code, password, captcha) or out (Zalo Web does not have it).
Added: jobs `logout`, `devices`, `devout <device>`, `notify on|off`, `lang vi|en`, `storage`, `help`, `feedback <text>`, `passwd`, `unfriend <name>`. Log out, remote log out, feedback and unfriend ask for `--live --force`.
Added: `passwd` opens the change-password page and stops; za never types a password or a code. New stop pages: "too many requests", "session expired", "browser not supported".

## 2026-11-21 (second build)
Added: send files and images (only from the outbox folder), stickers, replies, mentions, reactions, recall, delete, pin message, download, archive, hide, mark unread, alias, block.
Added: polls, notes, labels, quick messages, friend requests, message requests, group admin (rename, members, deputy, leave), profile read, My Cloud.
Added: open any chat by name or phone, scroll long lists, load old messages, pick between two chats with the same name (`#group`, `#person`).
Added: `za plan`, `za approve`, `za go`, `za flow`, `za watch`: lists of jobs that run by themselves, wait only when Zalo needs you, stop on a lock or warning.
Added: `za setup`, `za matrix`, `za export`, `za report`, `za backup`, `za retry`, `za undo last`, `za purge`. Messages in Vietnamese or English.
Added: Zalo button names now live in `so-labl-zalo.json` in two languages; `za probe` saves a page dump with personal text hashed; the canary checks every job and the Chrome version.
Added: popups are closed or stop the run; the message box is read back before sending; failed sends are never resent; folders are owner-only; chat text in logs is hashed; old chat text is deleted after 30 days.
Changed: `labl_*` settings moved into `so-labl-zalo.json`. Live runs need `za setup --yes` once.
Fixed: a chat message containing "captcha" no longer stops za.

## 2026-11-21
Added: first version. Read unread chats, send once, reminders, pin, mute, group, forward, plain-words commands, optional AI price replies, status, caps, log, pause, stop, resume.
Added: human pace (random delays, mouse curves, typing), hourly and daily limits, one-week warm-up, quiet hours.
Added: automatic stop on lock, captcha, warning, logout and "logged in elsewhere" pages (English and Vietnamese).
