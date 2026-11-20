# What changed

## 2026-11-20
Added: `wo push`: commits the files that sat idle for 2+ minutes and pushes `main` to GitHub and GitLab. Practice run first (`wo push`), real run `wo push --live`. Hub job `work-push` (hourly, off until you turn it on). It stops on a leak, a conflict, diverged remotes, a big file or a busy git, and it never pulls by itself. `work-wipz` and the `work-minu` chain are gone from the job list; docs sync is its own job `work-docs` again.
Added: `wo ci stat|test|leak|lock|rele|repr|deps`: local mirrors of the CI jobs and cloud watchers, all read-only. Hub jobs: `cicd-stat` (10 min), `cicd-rele` (30 min), chain `cicd-nigh` (02:00: test, leak, lock), chain `cicd-week` (Sunday 03:00: repr, deps).
Changed: the hub job names are now `work-wipz`, `work-docs`, `work-beat`, `work-bkup-stat`, `work-bkup-nigh`, `work-doct`, `work-dril` (were `wo-...`). The commands they run did not change.

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
