# What changed

## 2026-11-27

Added
- `id-edit-iden plan` shows every file and line that holds a job id, the state files that would move, and any guard.
- `id-edit-iden run` renames ids in one run. Without `--live` it only previews.
- `id-edit-iden undo` puts any past run back exactly as it was.
- `id-edit-iden stat` shows the repo, the hub, job counts and the last run.
- Checks the running hub after a rename and reports if it still lists the old id.
- Guards for a lock-lane change, a saved chain, a name clash, an unknown old id and a taken new id.
- A failed run puts everything back by itself.
