# fb

fb is a helper that uses Facebook the way you do. It posts, replies to comments, sends messages and manages your Marketplace listings, slowly and at a human pace, in your own browser.

## What it does
- Posts text on your timeline, in a group or on a page.
- Replies to new comments and sends direct messages.
- Lists, renews and marks Marketplace items as sold, and keeps a ledger (exact title, group, time).
- Stops by itself when Facebook asks for a security check.
- Shows a preview first. Nothing is posted until you add `--live`.

## What you need
- Windows, Linux or macOS with Google Chrome or Microsoft Edge.
- A Facebook account you own.

## Quick start
1. Open a terminal in the folder with `fb`.
2. Open the browser and log in once:
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe login
```
3. See what it would do (nothing is changed):
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe ask "post: Hello everyone"
```
4. Do it for real:
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe ask "post: Hello everyone" --live
```

## Good to know
- It uses its own browser profile. Your daily Chrome is not touched.
- It is slow on purpose. Daily limits and quiet hours protect your account.
- Facebook does not allow automation. Your account can still be restricted. You accept this risk.
- If it says "stopped by Facebook", open Facebook yourself, clear the check, then run `fb login`.

## Next
- [HOW-TO.md](HOW-TO.md): every task, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed

## License
PolyForm Noncommercial 1.0.0. See LICENSE.
