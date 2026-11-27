# How to use za

Short form: `E:\zz-base-home\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za-zalo-webs.exe` = `za` below. Flags: no flag = preview only · `--read` = look only · `--live` = do it · `--live --force` = also risky actions · `--json` = machine output. Put names with spaces in quotes. `Anna#group` or `Anna#person` picks between two chats with the same name.

## Set up once
1. `za setup --yes` checks Chrome, makes the folders, records that you accept the Zalo risk.
2. `za login`: a window opens. Scan the QR code with the Zalo phone app and approve. The session stays in the za profile.

## Several accounts
List the accounts you own in `user-acct.json` in your secrets folder (`~/.zz-base-home-secr/as-apps/ch-chat/za-zalo-webs/`): `{"main":"shop1","accs":[{"id":"shop1","label":"Shop","phone":"0912345678"},{"id":"home","label":"Home","lang":"en","scal":50}]}` (`scal` = percent of the daily limits, optional). It holds no passwords. `za secret` shows the list (phone masked).
- Scan each account's QR once, in its own window: `za login --acct shop1`, then `za login --acct home`.
- One account: add `--acct home` to any command, for example `za run reply --live --acct home`.
- All accounts: `--acct all`, for example `za flow run morning --live --acct all`. za runs them one at a time, in a different order each day, and waits 5 to 20 minutes between accounts.
- Each account has its own browser profile, limits, warm-up and stop state, in `acct/<id>/` inside your data folder. Never log two accounts into one window.
- If Zalo stops one account, only that account stops (clear it with `za resume --acct <id>` after you checked). If two stop, nothing runs.
- Limit: 5 accounts (`acct_maxx_coun`, at most 20). Use only accounts you own.
- A routine can be for one account: `{"name":"morning","items":[...],"acct":"shop1"}`.

## Read and search
`za run read --read` reads unread chats. `za run summ` lists the last message of each unread chat. `za run profile --live` opens your account info.

## Send
- Text: `za run send Mom "See you at 7"` (preview) then add `--live`. Same text to the same chat twice is skipped.
- Mention: `za run send "Team A#group" "hello @Mom please call" --live`.
- File or image: put it in the `outb` folder (see CONFIG), then `za run file Mom report.pdf --live`.
- Sticker: `za run sticker Mom "Cười" --live`. Note to yourself: `za run cloud "buy milk" --live`.

## Reply, react, take back
`za run quote Mom "Dinner at 7" "yes, 7 is fine" --live` · `za run react Mom "Dinner at 7" "👍" --live` · `za run pinmsg Mom "Dinner at 7" --live` · `za run recall Mom "oops" --live --force` · `za undo last --live --force` · `za run download Mom report.pdf --live`.

## Chats
`za run pin Boss --live` · `mute` · `archive` · `hide` · `unread` · `alias` · `za run block Boss --live --force`.

## Reminders, polls, notes, labels, quick messages
`za run remind Mom 20:00 "Call back" --live` · `za run poll "Team A" "Lunch?" "Pho" "Bun" --live` · `za run note "Team A" "bring the report" --live` · `za run label Mom family --live` · `za run quick hi "Hello, how can I help?" --live` · `za run usequick Mom hi --live`.

## Friends and groups (risky ones need --force)
`za run friend 0900000009 --live --force` · `za run accept Lan --live` · `za run ignore Lan --live` · `za run reqaccept Zed --live --force` · `za run group "Family" --live --force` · `za run forward Mom Boss --live --force` · `za run rename "Team A" "Team B" --live` · `za run addmember "Team A" Lan --live --force` · `deputy` · `delmember` · `leave`.

## Say it in plain words
`za run say "remind Mom at 8 to buy milk" --live` · `za run say "send Mom: hello" --live` · `za run say "summarize unread"`.

## Answer price questions
Put your reply in `aa-conf-main.json` as `reci_pric_text` (`{name}` becomes the chat name). `za run reply` shows the plan, `za run reply --live` sends it.

## Run a whole list by itself
1. `za plan "read" "send Mom good morning" "group Family"` prints the list and what needs approval.
2. `za approve all` (or `za approve 2`). Not approved = skipped, never blocking.
3. `za go --live` runs it. If Zalo asks for you (QR, captcha) it tells you, waits up to 30 minutes, then continues by itself and keeps a calm pace for 24 hours. If Zalo shows a lock or warning it stops and does not continue by itself.
4. A routine from `flow_list`: `za flow run morning --live`. A parked item: `za retry 3` then `za go --live`.
5. Check inbox now and then: `za watch --live`.

## Feed for scra
`za feed` takes the messages `za` already stored (it opens no browser and reads nothing from Zalo) for the chats you list in `feed_chat_list`, and with `--live` writes them as one `za-<time>.jsonl` file in scra's `social-in` folder. `scra cars --live` loads it (same cloud copy, purge and privacy as every other source). Without `--live` it only counts. It remembers the last message per chat, so the next file holds only new ones. Chats you do not list never leave `za`.

## Look after it
`za status` · `za caps` · `za log` · `za matrix` (every job and its quality level) · `za flows` (every Zalo Web action: built, gap, hand = yours, out) · `za run devices --read` · `za run notify on --live` · `za run lang en --live` · `za run logout --live --force` · `za export` · `za backup` · `za purge` · `za report` (a safe bundle for support, no chat text) · `za stop` (stops at the next action) · `za resume`.

## First live check (do once, with a test account)
1. `za login`, then `za run canary --read`. Every line must say "ok".
2. `za probe chat-list`, `za probe chat-open`: saves a hashed dump of the page. Use it to find the real button names and put them in `so-labl-zalo.json`.
3. Try one job at a time: preview, then `--live` on a test chat.
4. If a step says "element missing", open Zalo, read the real label, fix it in `so-labl-zalo.json`.

## Errors
| Message | Fix |
|---|---|
| đang giờ nghỉ / quiet hours | Run later, or change `quie_hour_rang`. |
| hết hạn mức / cap reached | Wait. Do not raise caps fast. |
| đã dừng / halted | Open Zalo, clear the check, run `za resume`. |
| cần đăng nhập / login needed | Run `za login`, scan the QR. |
| không thấy nút / element missing | A label changed. Run the canary, fix `so-labl-zalo.json`. |
| tên trùng / ambiguous name | Add `#group` or `#person`. |
| cần xác nhận thêm / needs force | Check the preview, then `--live --force`. |
| chưa đồng ý rủi ro / risk not accepted | Run `za setup --yes`. |
| cửa sổ lạ / unknown popup | Close it by hand, run again. |
| đang chạy / already running | Another za is running. Wait or run `za status`. |
