# How to use za

Short form: `E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za-zalo-webs.exe` = `za` below. Flags: no flag = preview only · `--read` = look only · `--live` = do it · `--live --force` = also risky actions · `--json` = machine output. Put names with spaces in quotes. `Anna#group` or `Anna#person` picks between two chats with the same name.

## Set up once
1. `za-zalo-webs setup --yes` checks Chrome, makes the folders, records that you accept the Zalo risk.
2. `za-zalo-webs login`: a window opens. Scan the QR code with the Zalo phone app and approve. The session stays in the za profile.

## Several accounts
List the accounts you own in `user-acct.json` in your secrets folder (`~/.zz-base-home-secr/as-apps/ch-chat/za-zalo-webs/`): `{"main":"shop1","accs":[{"id":"shop1","label":"Shop","phone":"0912345678"},{"id":"home","label":"Home","lang":"en","scal":50}]}` (`scal` = percent of the daily limits, optional). It holds no passwords. `za-zalo-webs secret` shows the list (phone masked).
- Scan each account's QR once, in its own window: `za-zalo-webs login --acct shop1`, then `za-zalo-webs login --acct home`.
- One account: add `--acct home` to any command, for example `za-zalo-webs run reply --live --acct home`.
- All accounts: `--acct all`, for example `za-zalo-webs flow run morning --live --acct all`. za runs them one at a time, in a different order each day, and waits 5 to 20 minutes between accounts.
- Each account has its own browser profile, limits, warm-up and stop state, in `acct/<id>/` inside your data folder. Never log two accounts into one window.
- If Zalo stops one account, only that account stops (clear it with `za-zalo-webs resume --acct <id>` after you checked). If two stop, nothing runs.
- Limit: 5 accounts (`acct_maxx_coun`, at most 20). Use only accounts you own.
- A routine can be for one account: `{"name":"morning","items":[...],"acct":"shop1"}`.

## Read and search
`za-zalo-webs run read --read` reads unread chats. `za-zalo-webs run summ` lists the last message of each unread chat. `za-zalo-webs run profile --live` opens your account info.

## Send
- Text: `za-zalo-webs run send Mom "See you at 7"` (preview) then add `--live`. Same text to the same chat twice is skipped.
- Mention: `za-zalo-webs run send "Team A#group" "hello @Mom please call" --live`.
- File or image: put it in the `outb` folder (see CONFIG), then `za-zalo-webs run file Mom report.pdf --live`.
- Sticker: `za-zalo-webs run sticker Mom "Cười" --live`. Note to yourself: `za-zalo-webs run cloud "buy milk" --live`.

## Reply, react, take back
`za-zalo-webs run quote Mom "Dinner at 7" "yes, 7 is fine" --live` · `za-zalo-webs run react Mom "Dinner at 7" "👍" --live` · `za-zalo-webs run pinmsg Mom "Dinner at 7" --live` · `za-zalo-webs run recall Mom "oops" --live --force` · `za-zalo-webs undo last --live --force` · `za-zalo-webs run download Mom report.pdf --live`.

## Chats
`za-zalo-webs run pin Boss --live` · `mute` · `archive` · `hide` · `unread` · `alias` · `za-zalo-webs run block Boss --live --force`.

## Reminders, polls, notes, labels, quick messages
`za-zalo-webs run remind Mom 20:00 "Call back" --live` · `za-zalo-webs run poll "Team A" "Lunch?" "Pho" "Bun" --live` · `za-zalo-webs run note "Team A" "bring the report" --live` · `za-zalo-webs run label Mom family --live` · `za-zalo-webs run quick hi "Hello, how can I help?" --live` · `za-zalo-webs run usequick Mom hi --live`.

## Friends and groups (risky ones need --force)
`za-zalo-webs run friend 0900000009 --live --force` · `za-zalo-webs run accept Lan --live` · `za-zalo-webs run ignore Lan --live` · `za-zalo-webs run reqaccept Zed --live --force` · `za-zalo-webs run group "Family" --live --force` · `za-zalo-webs run forward Mom Boss --live --force` · `za-zalo-webs run rename "Team A" "Team B" --live` · `za-zalo-webs run addmember "Team A" Lan --live --force` · `deputy` · `delmember` · `leave`.

## Say it in plain words
`za-zalo-webs run say "remind Mom at 8 to buy milk" --live` · `za-zalo-webs run say "send Mom: hello" --live` · `za-zalo-webs run say "summarize unread"`.

## Answer price questions
Put your reply in `aa-conf-main.json` as `reci_pric_text` (`{name}` becomes the chat name). `za-zalo-webs run reply` shows the plan, `za-zalo-webs run reply --live` sends it.

## Run a whole list by itself
1. `za-zalo-webs plan "read" "send Mom good morning" "group Family"` prints the list and what needs approval.
2. `za-zalo-webs approve all` (or `za-zalo-webs approve 2`). Not approved = skipped, never blocking.
3. `za-zalo-webs go --live` runs it. If Zalo asks for you (QR, captcha) it tells you, waits up to 30 minutes, then continues by itself and keeps a calm pace for 24 hours. If Zalo shows a lock or warning it stops and does not continue by itself.
4. A routine from `flow_list`: `za-zalo-webs flow run morning --live`. A parked item: `za-zalo-webs retry 3` then `za-zalo-webs go --live`.
5. Check inbox now and then: `za-zalo-webs watch --live`.

## Feed for scra
`za-zalo-webs feed` takes the messages `za` already stored (it opens no browser and reads nothing from Zalo) for the chats you list in `feed_chat_list`, and with `--live` writes them as one `za-<time>.jsonl` file in scra's `social-in` folder. `scra cars --live` loads it (same cloud copy, purge and privacy as every other source). Without `--live` it only counts. It remembers the last message per chat, so the next file holds only new ones. Chats you do not list never leave `za`.

## Look after it
`za-zalo-webs status` · `za-zalo-webs caps` · `za-zalo-webs log` · `za-zalo-webs matrix` (every job and its quality level) · `za-zalo-webs flows` (every Zalo Web action: built, gap, hand = yours, out) · `za-zalo-webs run devices --read` · `za-zalo-webs run notify on --live` · `za-zalo-webs run lang en --live` · `za-zalo-webs run logout --live --force` · `za-zalo-webs export` · `za-zalo-webs backup` · `za-zalo-webs purge` · `za-zalo-webs report` (a safe bundle for support, no chat text) · `za-zalo-webs stop` (stops at the next action) · `za-zalo-webs resume`.

## First live check (do once, with a test account)
1. `za-zalo-webs login`, then `za-zalo-webs run canary --read`. Every line must say "ok".
2. `za-zalo-webs probe chat-list`, `za-zalo-webs probe chat-open`: saves a hashed dump of the page. Use it to find the real button names and put them in `so-labl-zalo.json`.
3. Try one job at a time: preview, then `--live` on a test chat.
4. If a step says "element missing", open Zalo, read the real label, fix it in `so-labl-zalo.json`.

## Errors
| Message | Fix |
|---|---|
| đang giờ nghỉ / quiet hours | Run later, or change `quie_hour_rang`. |
| hết hạn mức / cap reached | Wait. Do not raise caps fast. |
| đã dừng / halted | Open Zalo, clear the check, run `za-zalo-webs resume`. |
| cần đăng nhập / login needed | Run `za-zalo-webs login`, scan the QR. |
| không thấy nút / element missing | A label changed. Run the canary, fix `so-labl-zalo.json`. |
| tên trùng / ambiguous name | Add `#group` or `#person`. |
| cần xác nhận thêm / needs force | Check the preview, then `--live --force`. |
| chưa đồng ý rủi ro / risk not accepted | Run `za-zalo-webs setup --yes`. |
| cửa sổ lạ / unknown popup | Close it by hand, run again. |
| đang chạy / already running | Another za is running. Wait or run `za-zalo-webs status`. |
