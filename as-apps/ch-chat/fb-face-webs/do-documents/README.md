# fb

fb is a helper that uses Facebook the way you do. It posts, comments, reacts, sends messages, manages friends, groups, pages and your Marketplace items, slowly and at a human pace, in its own browser window.

## What it does
- Posts (text, photo, poll), comments, reacts, shares, edits and deletes your own posts.
- Replies to comments and Messenger messages, and answers buyers on Marketplace.
- Accepts friend requests, follows, and more. Anything you cannot undo (delete, unfriend, block) needs your OK first.
- Lists, renews and marks Marketplace items as sold, with a ledger of title, group and time.
- Runs a whole routine by itself (for example "morning") and stops only when it truly needs you, for example a Facebook security check. When you finish the check, it continues on its own.
- Stops and rests when Facebook warns or limits your account.
- Shows a preview first. Nothing happens until you add `--live`.

## What you need
- Windows, Linux or macOS with Google Chrome or Microsoft Edge.
- A Facebook account you own. Try it on a test account first.

## Quick start
1. Open a terminal.
2. Run the first-time setup. It opens the browser, you log in by hand:
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe setup
```
3. Read the note it prints. If you accept the risk, run:
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe setup --yes
```
4. Preview a post (nothing is posted):
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe ask "post: Hello everyone"
```
5. Do it for real:
```
E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe ask "post: Hello everyone" --live
```

## Good to know
- fb has its own browser profile. Your daily Chrome is not touched.
- It is slow on purpose. Daily limits, quiet hours and a slow start protect your account.
- Facebook does not allow automation. Your account can still be restricted. You accept this risk.
- This version is tested on a practice copy of Facebook, not on the real site yet. Facebook's button names may differ for you: run `fb doctor` and fix names in your settings.
- Messages are in Vietnamese by default. Set `lang_main_code` to `en` for English.
- Your data lives in one folder: `E:\.zz-base-home-tena\as-apps\ch-chat\fb-face-webs` (Windows).

## License
PolyForm Noncommercial 1.0.0. See LICENSE.

## Next
- [HOW-TO.md](HOW-TO.md): every task, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed
