# ie

Rename a job id in the task hub, and fix every place that uses it.

## What it does

A job or a chain step has an id, like `cicd-stat`. That id sits in your job files, in the start scripts, in tests, in notes, and in the hub's saved state and logs. You give `ie` the old id and the new id. It changes every place in one run, then checks the hub still loads. If anything goes wrong, it puts everything back. You can also undo a finished run.

Nothing is deleted. Before it touches a file, it saves a copy.

## Requirements

- Windows 10 or later, Linux, or macOS.
- The task hub folder in your repo.
- `curl` (already on Windows 10+, Linux and macOS) to ask the running hub. Without it, `ie` skips that check.

## Quick start

1. Check the setup:

```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe stat
```

2. Preview a rename. This writes nothing:

```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe plan fb-watc=fb-aliv
```

3. Apply it:

```
E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe run fb-watc=fb-aliv --live
```

## Key behavior

- Whole ids only: `cicd-stat` never changes `cicd-stat2`.
- Dangerous cases stop the run first (a different lock lane, a saved chain, a file named like the id). Add `--force` only for the soft ones.
- The hub reloads its job file by itself. You do not restart it.
- A failed run restores every file and every moved state file.

## Next

- [HOW-TO.md](HOW-TO.md): every task, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed
