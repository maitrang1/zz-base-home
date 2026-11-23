# Updates

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
