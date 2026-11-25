# zr: ZenRows helper

`zr` does the clicking in your ZenRows dashboard for you, at a human pace, in your own browser. You log in once by hand. Then it can make API keys, run a scrape, show usage, change plans, and more.

## What it does
- Does everything after login. You log in by hand once in its window (the Cloudflare check and the email code are yours).
- Creates and manages API keys, webhooks, team invites and alerts.
- Runs a page scrape, a crawl or a batch, and saves the answer.
- Shows usage, invoices and your plan. Risky acts (pay, cancel, delete) always wait for your OK.
- Talks plain English: `zr ask "get https://example.com as text"`.

## You need
- Windows, Linux or macOS.
- Google Chrome or Edge.
- A ZenRows account, or an email to sign up with.

## Quick start
1. Log in by hand, once. A Chrome window opens on ZenRows. Tick the Cloudflare box, then sign up or log in there (you read the 6-digit email code yourself):
`C:\zz\zr.exe login`
2. Turn on real runs once, after you read the risk note:
`C:\zz\zr.exe setup --yes`
3. See what a job would do (nothing is sent yet):
`C:\zz\zr.exe run usage-view`
4. Do it for real:
`C:\zz\zr.exe run usage-view --live`
The login stays in zr's own browser profile, so later runs need no login until the session expires.

## Key behavior
- Default is a preview. Add `--live` to act. Add `--force` too for risky acts.
- It stops and tells you when it needs you (captcha, 2FA, email code, card).
- It never bypasses a captcha or 2FA.
- It has not been checked against the live ZenRows site yet. Run `zr map` first; it lists anything that does not match.

## Next
[HOW-TO](HOW-TO.md) · [CONFIG](CONFIG.md) · [UPDATE](UPDATE.md)
