# How to use za

Short form: `E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe` = `za` below. Flags: no flag = preview only · `--read` = look only · `--live` = do it · `--live --force` = also groups, forwards, big batches · `--json` = machine output.

## Log in
1. Run `za login`.
2. A browser window opens. Scan the QR code with the Zalo phone app and approve.
3. `za` prints "logged in". You do this once; the session stays in the za profile.

## Read new chats
```
za run read --read
```
It opens each unread chat and saves the new messages.

## Send a message
Preview: `za run send Mom "See you at 7"`. Real send: add `--live`. Sending the same text to the same chat twice is skipped.

## Set a reminder
```
za run remind Mom 20:00 "Call back" --live
```

## Pin or mute a chat
`za run pin Boss --live` · `za run mute Boss --live`

## Group or forward (needs --force)
`za run group "Family" --live --force` · `za run forward Mom Boss --live --force`

## Say it in plain words
`za run say "remind Mom at 8 to buy milk" --live` · `za run say "send Mom: hello" --live` · `za run say "summarize unread"`

## Answer price questions
1. Put your reply in `aa-conf-main.json` as `reci_pric_text`.
2. `za run reply` shows the plan. `za run reply --live` sends it (more than 5 chats needs `--force`).

## Check limits and status
`za status` · `za caps` · `za log`

## Stop everything
`za stop` (or `za pause`): running jobs stop at the next action. `za resume` lets them go again.

## Check that Zalo did not change (read only)
`za run canary --read`. Exit 3 means a label changed: fix the `labl_*` names in CONFIG.

## First live check (do once, with a test account)
1. `za login`.
2. `za run canary --read`. Every line must say "ok".
3. `za run read --read`, then `za run send <friend> "test"` (preview), then add `--live`.
4. If a step says "element missing", open Zalo, read the real label of that button, and put it in `aa-conf-main.json`.

## Errors
| Message | Fix |
|---|---|
| error: quiet hours | Run later, or change `quie_hour_rang`. |
| error: cap reached | Wait for the hour or day to pass. Do not raise caps fast. |
| error: halted | Open Zalo yourself, clear the check, run `za resume`. |
| error: login needed | Run `za login` and scan the QR. |
| error: element missing | A label changed. Run the canary, fix the `labl_*` name. |
| error: needs force | Check the preview, then add `--live --force`. |
| error: browser start timeout | Close other windows that use the za profile, then retry. |
