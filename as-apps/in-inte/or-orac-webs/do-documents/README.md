# or-orac-webs: Oracle Cloud helper

`or-orac-webs` does the clicking in your Oracle Cloud console for you, at a human pace, in your own browser. You sign up and log in by hand once. Then it can show your cost and limits, start and stop servers, set budgets, make keys, and more.

## What it does
- Does everything after login. You sign in by hand once in its window (the email link, the card check, the phone check and the MFA code are yours).
- Shows your cost, free-tier limits, credits, invoices and audit log.
- Starts, stops and reboots servers; creates networks, disks and buckets; checks that no port is open.
- Sets budgets and alerts so a free account never bills you by surprise.
- Risky acts (create a billable thing, open a port, stop a server, delete, pay) always wait for your OK.
- Talks plain English: `or-orac-webs ask "show instances"`.

## You need
- Windows, Linux or macOS.
- Google Chrome or Edge.
- An Oracle Cloud account, or an email to sign up with.

## Quick start
1. Log in by hand, once. A Chrome window opens on Oracle Cloud. Sign up or sign in there (you type the cloud account name, password, codes and card yourself):
`C:\zz\or-orac-webs.exe login`
2. Turn on real runs once, after you read the risk note:
`C:\zz\or-orac-webs.exe setup --yes`
3. See what a job would do (nothing is sent yet):
`C:\zz\or-orac-webs.exe run limits-view`
4. Do it for real:
`C:\zz\or-orac-webs.exe run limits-view --live`
The login stays in the app's own browser profile, so later runs need no login until the session expires.

## Key behavior
- Default is a preview. Add `--live` to act. Add `--force` too for risky acts.
- It stops and tells you when it needs you (captcha, MFA, email link, card).
- It never bypasses a captcha or MFA, and never types a card number, private key or token.
- It has not been checked against the live Oracle console yet. Run `or-orac-webs map` first; it lists anything that does not match.

## Next
[HOW-TO](HOW-TO.md) · [CONFIG](CONFIG.md) · [UPDATE](UPDATE.md)
