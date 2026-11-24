# Updates

## 2026-11-24 (accounts)
Added: several accounts in one `user-acct.json`, picked with `--acct <id>` or run all with `--acct all` (one at a time, rotating order, random wait between accounts). Each account has its own browser profile, database, limits, warm-up and safety rest under `acct/<id>/`. Two accounts resting = all rest. New settings `acct_maxx_coun`, `acct_gap_secs`. Routine items can name an account.
Changed: your existing profile and data move into `acct/main/` the first time you run this version (moved, nothing deleted). `fb secret` lists every account. `fb status` shows the account. The file is now named `user-acct.json`.
Tested with a fake runner and the practice site only: the full `--acct all` run with real browsers has not been tried.

## 2026-11-24
Added: 125 more jobs (178 in all, see `fb jobs`): account (login, logout, sign-up, password, two-factor, passkey, sessions, contact info, name, language, deactivate, delete, profile photo, cover, work, school, city, links, featured, life events), settings (privacy, search, tags, notifications, block, apps, ad choices), data (activity log, download your information, saved, albums, memories), money (billing, invoices, payment methods, Meta Verified, ads, boost), access (page, business and ad roles, partners, group admins, developer console, connected accounts), help and support, and more core jobs (friend lists, group and page create and edit, post tag, check-in, feeling, hide, report, pin, comment edit and delete, story, reel, event edit, Messenger extras).
Added: job classes in `fb jobs`: A runs by itself, G needs your OK, H assist (stops for codes, card entry and the final delete, deactivate or pay click, then continues).
Added: `fb start --live` (zero start from a login and password in a secrets file), `fb secret`, `fb map` (read-only map of the site), `fb gaps` (changed buttons, new buttons, `matrix` job list).
Added: fb logs in again by itself once when the session ends; known cookie and save-login popups are closed; short error pages are retried.
Added: new limits `capz_acct_dayz`, `capz_data_dayz`, `capz_mone_dayz` (0 = money off), `capz_help_dayz`, `mone_spen_capz`.
Changed: `fb doctor` also checks toggles. Read-only jobs and login always run; setting jobs run once a day.
This version is tested on a practice copy of Facebook only. Every new button name and menu path is a guess until you run `fb map` on your own account.

## 2026-11-21 (later)
Added: 36 more jobs: photo, audience and poll posts, edit and delete posts, comments, reactions, shares, saves, Business Suite scheduling, friend accept, decline, follow, unfriend and block, birthday wishes, notifications, Messenger reply, files and requests, buyer replies, group admin (approve, decline, remove), page switch and hide, Marketplace wizard (category, condition, location), edit, available, relist, delete and share to groups, sale scan, events, stories, reels and profile bio. See `fb jobs`.
Added: attended routines: `fb plan`, `fb approve`, `fb flow run`. A routine runs by itself, stops only when it needs you, waits while you finish a Facebook check, then continues. A second check within 24 hours, or a Facebook warning, stops it and rests 24 hours.
Added: `fb setup` (first run and risk consent), `fb doctor` (checks the buttons), `fb snap` (safe copy of a page for testing), `fb read`, `fb report`, `fb backup`, `fb export`, `fb purge`.
Added: Vietnamese messages (default) and English, alerts in `alerts.txt` and a desktop popup, one lock so two runs never share the browser, readable text is kept out of logs, AI replies are limited to 20 a day.
Changed: a button is matched by its exact name first, so "Post" no longer clicks "Delete post". Words like "slow down" only stop fb when they appear in a Facebook dialog. Known popups ("Not now", "Close") are closed automatically; an unknown dialog makes fb wait for you.
Fixed: marking an item sold now updates the ledger even when you typed the title in other letters.
This version is tested on a practice copy of Facebook only.

## 2026-11-21
Added: first version. Post, group and page posts, comment replies, direct messages, friend requests, group join, Marketplace list, renew and sold with a ledger, plain-words commands, optional AI replies, status, log, pause and unlock.
Added: human pace (random delays, mouse curves, typing), daily limits, warm-up for new accounts, quiet hours.
Added: automatic stop on checkpoint, captcha, 2FA, warning, block and logout pages (English and Vietnamese).
Changed: fb now keeps its browser profile and notes only in one folder: `E:\.zz-base-home-tena\as-apps\ch-chat\fb-face-webs` on Windows, `~/.zz-base-home-tena/as-apps/ch-chat/fb-face-webs` on Linux and macOS (settings `data_loca_wind`, `data_loca_unix`). The old `prof_dirz_path` and `stat_dirz_path` settings are gone.
Fixed: nothing yet.
