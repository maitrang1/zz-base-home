# How to use wo

Replace `wo` below with `E:\zz-base-home\wo-work-mode\zig-out\bin\wo.exe`.

## Check that this device is healthy
1. Run: `wo doct`
2. Read each line: `okay` fine · `drif` drifted · `bloc` could not run.
3. Fix every `drif` line, then run it again until the exit code is 0.
Use `wo doct --prof ci` for the short check used by CI (hooks, Zig version and CPU level). Use `--prof box` on the OCI box.
A fresh PC shows `drif` for Tailnet Lock, OS patches and ESU until you have done them: that is on purpose.

## See when each job last ran
Run: `wo stat`

## Save your unsaved work
1. Name your private remotes once in `aa-conf-main.json` (`wipz_remo_list`).
2. Practice run (changes nothing): `wo wipz`
3. Real run: `wo wipz --live`
It copies your work to one private backup branch per device (`refs/wipz/<device>/head`) and scans it for secrets first. Files over 10 MB are left out and reported. If a secret is found, nothing is pushed: the copy goes to restic only and the command exits 1.

## Back up state files and databases
1. List the files once: `mo-modu/mo-core/bk-back-modu/bk-stat-list.txt` (paths under your home). Name your databases in `aa-conf-main.json` (`bkup_dbzz_list`).
2. Set `RESTIC_REPOSITORY` and `RESTIC_PASSWORD_FILE` in the environment of the job (never in a file of this repo).
3. Practice run: `wo bkup stat` and `wo bkup nigh`
4. Real run: `wo bkup stat --live` (every 5 minutes) and `wo bkup nigh --live` (every night)
`stat` skips every `*.db` file on purpose: databases are copied safely by `nigh` (and by Litestream). Windows needs an admin shell for the shadow copy. Nightly copies stay in `.wo-work-mode/nigh`; move old ones away by hand.

## Test that a restore works
1. Practice run: `wo dril`
2. Real run: `wo dril --live`
It restores your latest backup into a new folder in `.wo-work-mode`, checks every database in it and times it. Over 15 minutes counts as a failure. Old drill folders stay; move them away by hand.

## Switch the agents off
1. Practice run: `wo kill`
2. Real run: `wo kill --live`
It runs every step listed in `kill_step_list` and never stops at the first failure.

## Create the secret folder
Run: `wo secr init --live`
`wo secr lend` is not ready yet. It says so and exits with 4.

## Get machine-readable output
Add `--json` to any command: `wo doct --json`

## Use another settings file
`wo --conf C:\path\to\file.json doct`

## Problems
| Message | Fix |
|---|---|
| `usage: wo [--conf FILE] ...` (exit 2) | Check the command name and flags. `--force` only works with `--live`. |
| `tool absent: gitleaks` (or restic, sqlite3, gh) | Install that tool, then run again. |
| `wipz_remo_list is empty` | Add your private remotes to `aa-conf-main.json`. |
| `LEAK found: git push skipped` | A secret is in your work. Remove it, then run again. The copy is in restic (label `wipz-held`). |
| `wo: config unreadable` | The `--conf` path is wrong or the file is not valid JSON. |
| `no upstream` | Set an upstream branch for your repo. |
