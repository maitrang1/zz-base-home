# za

za is a helper that uses Zalo Web the way you do. It reads your new chats, replies, sends messages, sets reminders and pins chats, slowly and at a human pace, in its own browser window.

## What it does
- Reads your unread chats and remembers what is new.
- Sends a message once, never twice, even after a crash.
- Sets reminders, pins and mutes chats. Creating groups and forwarding need an extra `--force`.
- Answers price questions with a text you wrote (or with AI, if you turn it on).
- Stops by itself when Zalo shows a lock, captcha, warning or "logged in elsewhere" page.
- Shows a preview first. Nothing is sent until you add `--live`.

## What you need
- Windows, Linux or macOS with Google Chrome or Microsoft Edge.
- A Zalo account you own, and the Zalo app on your phone for the QR login.

## Quick start
1. Open the browser and log in once. Scan the QR code with the Zalo app on your phone:
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe login
```
2. See what it would do (nothing is changed):
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe run send Mom "See you at 7"
```
3. Do it for real:
```
E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe run send Mom "See you at 7" --live
```

## Good to know
- It uses its own browser profile. Your daily Chrome is not touched.
- It is slow on purpose. Hourly and daily limits, quiet hours and a one-week warm-up protect your account.
- Zalo does not offer automation for personal accounts. Your account can still be restricted. You accept this risk.
- Labels on the Zalo page are guesses until you run the live check once (see HOW-TO).
- If it says "halted", open Zalo yourself, clear the check, then run `za resume`.

## Next
- [HOW-TO.md](HOW-TO.md): every task, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed

## License
PolyForm Noncommercial 1.0.0. See LICENSE.
