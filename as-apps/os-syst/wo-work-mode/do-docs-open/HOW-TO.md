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

## Keep your docs in step across devices
1. Create the private repo once on your git host, named like the main repo plus `-docs`, and add the same remote names the main repo has (`origin`, `mirr`).
2. Practice run: `wo docs init`, then `wo docs sync`
3. Real run: `wo docs init --live` on each device (it restores the docs on a new device), then `wo docs sync --live` (every 15 minutes)
A conflict aborts the sync and keeps both copies, and the `docs` stamp stops moving, so `wo beat` raises the alarm. Deleted docs are not deleted on the other device.

## Get an alarm when the hub dies
1. Make a free check at an outside monitor (for example Healthchecks.io): period 15 minutes, grace 15 minutes, with an email alert.
2. Put its https ping address, alone on one line, in a file under your home (outside the repo) and name that file in `beat_urlz_file`.
3. Practice run: `wo beat`. Real run: `wo beat --live` (every 15 minutes). Turn the job wo-beat on.
It pings when the stamps in `beat_chek_list` are fresh, and pings `/fail` when they are stale. If the hub stops, the pings stop and the monitor alerts you.

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

## Verify a release yourself

A release says **Verified** only after two separate builders (GitHub and GitLab) produced identical bytes.

1. From the release page download `sha256.txt`, `sha256.txt.sig` and the archive for your system.
2. Unpack the archive and compare the file's hash with its line in `sha256.txt`:
   `sha256sum wo` (macOS: `shasum -a 256 wo`). The line for your system is `./linux-x86_64/wo`, `./macos-aarch64/wo`, and so on.
3. Check the owner's signature on the hash list, using the public key file `mo-modu/mo-core/bs-boot-modu/si-rele-keyz.txt` from this repo:
   `ssh-keygen -Y verify -f si-rele-keyz.txt -I zz-base-home-release -n zz-base-home-release -s sha256.txt.sig < sha256.txt`
   You should see `Good "zz-base-home-release" signature`.
4. Optional: rebuild it yourself with `zig build dist` (see the build notes) and compare again. The build is reproducible.

For the owner: after a release is marked Verified, run `wo rels sign vX.Y.Z --live` from the repo folder on a trusted device, in cmd or PowerShell (not Git Bash, whose ssh-keygen cannot reach the Windows agent). The key must be loaded in ssh-agent. It signs `sha256.txt` with the key in ssh-agent and uploads the `.sig`.
