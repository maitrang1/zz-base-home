# zr: ZenRows helper

`zr` does the clicking in your ZenRows dashboard for you, at a human pace, in your own browser. Start with just an email and a password. It can sign up, log in, make API keys, run a scrape, show usage, change plans, and more.

## What it does
- Signs up and logs in. You read the 6-digit email code once.
- Creates and manages API keys, webhooks, team invites and alerts.
- Runs a page scrape, a crawl or a batch, and saves the answer.
- Shows usage, invoices and your plan. Risky acts (pay, cancel, delete) always wait for your OK.
- Talks plain English: `zr ask "get https://example.com as text"`.

## You need
- Windows, Linux or macOS.
- Google Chrome or Edge.
- A ZenRows email and password (or a new email to sign up).

## Quick start
1. Save your login once (it stays on this PC):
   `printf 'you@example.com\nyour-password\n' | C:\zz\zr.exe secret`
2. See what it would do (nothing is sent yet):
   `C:\zz\zr.exe run login`
3. Turn on real runs once, after you read the risk note:
   `C:\zz\zr.exe setup --yes`
4. Do it for real:
   `C:\zz\zr.exe run login --live`

## Key behavior
- Default is a preview. Add `--live` to act. Add `--force` too for risky acts.
- It stops and tells you when it needs you (captcha, 2FA, email code, card).
- It never bypasses a captcha or 2FA.
- It has not been checked against the live ZenRows site yet. Run `zr map` first; it lists anything that does not match.

## Next
[HOW-TO](HOW-TO.md) · [CONFIG](CONFIG.md) · [UPDATE](UPDATE.md)
