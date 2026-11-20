# How to use fb

Replace `fb` below with the full path: `E:\zz-base-home\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe`

Every command shows a preview by default. Add `--live` to do it for real.

## Log in once
```
fb login
```
A browser window opens. Log in by hand (password, 2FA, QR). The command ends when you are in.

## Post something
```
fb run post --text "Hello everyone" --live
```
Post in a group:
```
fb run post --text "Hello group" --url /groups/12345/ --live
```
The same text is never posted twice in the same place.

## Reply to comments
```
fb run reply --live
```
It answers up to 5 new comments. Add `--max 10` for more. Turn on `smar_mode_enab` to let AI write replies.

## Send a message
```
fb run dm --to 100012345 --text "Hi, the bike is still free" --live
```
A person you never wrote to needs your approval: add `--force`.

## Marketplace
List an item:
```
fb run list --title "Red bike" --price 2000000 --desc "Like new" --group "Bike Club HN" --live
```
Renew all items, or one:
```
fb run renewall --live
fb run renew --title "Red bike" --live
```
Mark an item as sold, and see the ledger:
```
fb run sold --title "Red bike" --live
fb ledger
```

## Use plain words
```
fb ask "reply to my comments" --live
fb ask "renew my listings" --live
fb ask "mark Red bike sold" --live
fb ask "message 100012345 Hi there" --live --force
```

## Check status, pause, unlock
```
fb status
fb log
fb pause
fb resume
```
If a job says "an earlier try may have gone through": check Facebook, then `fb unlock "<key shown>"`.

## Errors
| Message | Fix |
|---|---|
| stopped by Facebook | Open Facebook yourself, clear the check, run `fb login` |
| not logged in | Run `fb login` |
| daily limit reached | Wait, or raise the `capz_*` value slowly |
| quiet hours | Run later, or change `quie_hour_rang` |
| needs your approval | Check the preview, then add `--live --force` |
| button or box not found | Facebook looks different: set the `labl_*` words in your language |
| no browser | Install Chrome, or set `brow_exec_path` |
