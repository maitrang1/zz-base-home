# za

za is a helper that uses Zalo Web the way you do. It reads your new chats, replies, sends messages and files, sets reminders, reacts, manages friends, groups and polls, slowly and at a human pace, in its own browser window.

## What it does
- Reads your unread chats and remembers what is new. Searches and opens any chat by name or phone number.
- Sends text, files, images and stickers once, never twice, even after a crash. Replies to a message, mentions people, reacts, recalls.
- Sets reminders, pins, mutes, archives and hides chats. Makes polls, notes, labels and quick messages.
- Handles friend requests, message requests and group admin. Risky actions (new group, forward, delete, block, add friend, leave) need `--force`.
- Runs a whole list of jobs by itself (`za plan`, `za go`) and stops to wait only when Zalo needs you (QR, captcha).
- Handles account pages too: log out, logged-in devices, notification and language settings, storage, help, feedback. `za flows` lists every Zalo Web action and who does it. Passwords, SMS codes and QR scans stay yours; za never types them.
- Stops by itself when Zalo shows a lock, warning or "logged in elsewhere" page.
- Shows a preview first. Nothing changes until you add `--live`.
- Messages and help are in Vietnamese by default (English: set `lang_main_code` to `en`).

## What you need
- Windows, Linux or macOS with Google Chrome or Microsoft Edge.
- A Zalo account you own, and the Zalo app on your phone for the QR login.

## Quick start
1. Check everything and accept the risk once:
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe setup --yes
```
2. Open the browser and log in once. Scan the QR code with the Zalo app on your phone:
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe login
```
3. See what it would do (nothing is changed):
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe run send Mom "See you at 7"
```
4. Do it for real:
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe run send Mom "See you at 7" --live
```

## Good to know
- It uses its own browser profile. Your daily Chrome is not touched. Your data stays on this PC, in a folder only you can open.
- It is slow on purpose. Hourly and daily limits, quiet hours, work breaks and a one-week warm-up protect your account.
- Zalo does not offer automation for personal accounts. Your account can still be restricted. You accept this risk with `za setup --yes`.
- The button names on the Zalo page are guesses until you run the live check once (see HOW-TO).
- If it says "halted", open Zalo yourself, clear the check, then run `za resume`.

## Next
- [HOW-TO.md](HOW-TO.md): every task, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed

## License
PolyForm Noncommercial 1.0.0. See LICENSE.
