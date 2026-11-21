# What changed

## 2026-11-21
Changed: wo's own files moved out of `~/.wo-work-mode` to the tena root: `as-apps/os-syst/wo-work-mode` under Windows `E:\.zz-base-home-tena` / other systems `~/.zz-base-home-tena`. New settings `tena_loca_wind` and `tena_loca_unix`; `apps_data_loca` is now relative to that root. The backup list `bk-stat-list.txt` is now relative to the tena root too, so the Windows scheduler state is backed up. To keep your history, copy the old folder to the new place.

## 2026-11-20
Added: `wo sync` (`wo push` is the same command): keeps every device and both remotes on ONE version of the code. It commits the files idle for 2+ minutes, merges each remote tip (a same-line clash goes to the newer edit; the loser is saved in `zz-dele-auto/_code-<time>/` and stays in git history), pushes to GitHub and GitLab, then checks that your HEAD equals every remote. A clash exits 3 and lists the files. It stops on a leak, a failed merge, too many files or a busy git; a file over the size limit is kept out and reported. An incoming change to a file you are editing waits for the next cycle. Practice run `wo sync`, real run `wo sync --live`. Hub step `home-code` inside the chain `home-sync` (every 10 min). The hub job list is now two chains, `home-sync` and `cicd-dail`; `home-wipz`, `home-minu`, `home-push` and the separate `home-docs`, `home-code`, `home-doct` lines are gone (their commands live inside the chains).
Added: `wo ci stat|test|leak|lock|rele|repr|deps`: local mirrors of the CI jobs and cloud watchers, all read-only. Hub chains: `home-sync` (every 10 min: docs, code, ci stat, ci rele, beat) and `cicd-dail` (08:00 and 14:00: ci test, ci leak, ci lock, doct). `repr` and `deps` are manual only.
Changed: the hub job names are now `home-wipz`, `home-docs`, `home-beat`, `home-bkup-stat`, `home-bkup-nigh`, `home-doct`, `home-dril` (were `wo-...`). The commands they run did not change.

## 2026-11-18
Added: first release. Commands `stat`, `conf`, `doct`, `wipz`, `dril`, `kill` and `secr init`.
Added: practice run by default; `--live` makes real changes.
Added: `--json` output and the `ci` check profile.
Known gaps: `secr lend`.

Fixed: a tool message with several lines now stays on one line in the output.
Added: three hub jobs in `aa-auto-task.json` (all off): wo-wipz, wo-doct, wo-dril. The hub job file was renamed from so-auto-list.json.

## 2026-11-18 (v5 sync)
Changed: `wipz` keeps one backup branch per device that only moves forward, plus a daily bookmark. Unchanged work is skipped. Files over 10 MB are left out and reported.
Changed: a secret hit now saves the work to restic (label `wipz-held`) and exits 1; nothing reaches a remote.
Added: `wo bkup stat` and `wo bkup nigh`, the `box` profile, and the checks `cpuz` `tsfl` `clfl` `lock` `patc` `esus` `bknt`.
Added: release builds target a baseline CPU, are stripped, and are byte-identical when built twice.
Added: two hub jobs (off): wo-bkup-stat, wo-bkup-nigh.
Known gaps: `secr lend`. OCI idle numbers wait for the box.

## 2026-11-19
Added: `wo docs init` and `wo docs sync`. They keep your git-ignored docs (`do-*` folders, `CLAUDE.md`, `aa-todo-*`, and so on) in step across devices through a private docs repo. Every changed file is scanned for secrets first.
Added: `wo beat`, a heartbeat ping to an outside monitor, so a hub that dies silently raises an alarm.
Added: `wo rels sign TAG`, which signs the verified release hashes with your key. How to check a release yourself is in HOW-TO.
Added: the `WO_DEVI_NAME` environment variable gives each device its own name. Checks: the Mac baseline CPU `apple_m1` is accepted.
Changed: `wipz_remo_list` must now name PRIVATE remotes (it ships with `wipg` and `wipl`). A public repo would show your unfinished work.
Added: hub jobs wo-docs (on), wo-beat (off) and wo-doct (on). The hub takes an optional jobs file name, for example `auto-task 4000 aa-auto-task-li01.json`.
Changed: `wo docs sync` always ends with ONE version of each doc. Different lines are merged; on the same lines the newer edit wins (the commit carries the real edit time), and the loser is saved once in `zz-dele-auto/_docs-<stamp>/`. A busy remote is retried up to 3 times, and only changed files are scanned (every 4 minutes now).
