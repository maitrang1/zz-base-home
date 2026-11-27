# How to use ie

Program: `E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe`

## Check the setup
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe stat
```
It shows the repo, whether the hub is up, how many job ids and chain steps exist, and your last run. Exit 0 means all is fine.

## Preview one rename
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe plan cicd-stat=cics-stat
```
You see every file and line that holds the id, the state files that would move, and any guard. Nothing is written.

## Rename one id
1. Run the preview above and read the guards.
2. Apply:
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe run cicd-stat=cics-stat --live
```
3. Read the last lines: files edited, state files moved, leftovers, and the hub answer.

## Rename several ids at once
Make a text file, one pair per line. Lines starting with `#` are notes.
```
fb-watc = fb-aliv
scra-raws -> scra-rawz
```
Then:
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe run --map C:\work\map.txt --live
```

## Pass a soft guard
A soft guard means "check this first". If you are sure:
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe run cicd-stat=cics-stat --live --force
```
Hard guards never pass.

## Skip notes and docs
Add `--no-docs`. Only code, scripts and job files change.

## Fix the second computer
After the first computer renamed and the repo synced, the second computer still has old state file names. Run the same pairs with:
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe run cicd-stat=cics-stat --live --scope state
```

## Undo a run
Preview, then apply:
```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe undo last
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe undo last --live
```
Use a run id from `stat` instead of `last` for an older run.

## Get machine output
Add `--json` to any command. You get one JSON document.

## Errors
| Message | Fix |
|---|---|
| `bad map: ...: old equals new` | Use two different ids. |
| `[hard] oldz_miss` | The old id is not a job id or chain step. Check the spelling with `stat`. |
| `[hard] newz_exis` | The new id is taken. Pick another. |
| `[hard] stat_exis` | A state or log file with the new name exists. Move it away first. |
| `[soft] lane` | The new id falls in a different lock lane. Keep the same prefix, or add `--force`. |
| `[soft] chain` | A chain is saved mid-run. Wait for it to finish, or add `--force`. |
| `[soft] clash` | A file or folder has the id as its name. Rename it first, or add `--force`. |
| `run ... never finished` | A past run stopped half way. Run `ie undo <id> --live --force`. |
| `another run holds the lock` | Wait. After 10 minutes the lock counts as stale. |
| `Drift` | A file changed after the preview. Run again. |
| `Dangling` | A step would lose its start-script entry. Rename the script entry too, or fix the plan. |
| `hub still lists <id>` | The hub has not reloaded. Wait a minute, then run `ie stat`. If it stays, run `ie undo last --live`. |
| `repo root not found` | Run from inside the repo, or set `repo_root` in the config. |

One note: the hub may write one last line to the old log name before it reloads. That old file is not removed.
