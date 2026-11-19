# What changed

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
