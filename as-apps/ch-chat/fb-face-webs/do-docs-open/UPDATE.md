# Updates

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
