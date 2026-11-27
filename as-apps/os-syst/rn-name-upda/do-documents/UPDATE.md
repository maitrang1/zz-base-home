# What changed

## 2026-11-23

Added
- `rn-name-upda plan` shows every place that mentions the old path and what would change.
- `rn-name-upda runz` renames and fixes the mentions in one run. Without `--live` it only previews.
- `rn-name-upda undo` puts any past run back exactly as it was.
- `rn-name-upda stat` shows your skip switches and the last run.
- Finds plain text, UTF-16 text, binary files, links, Windows registry values and your crontab.
- Twelve risk groups, each with its own switch. Risky places are listed and left alone until you allow them.
- A failed run puts everything back by itself.

Changed
- Paths written with `\\` or as `file:///` are changed by default.

Fixed
- `rn` now finds `aa-conf-main.json` no matter which folder you run it from. Before, it only looked in the current folder.
- Paths with `\` in `skip_path_list` and `scan_skip_list` now work on Windows.
- A run cut short by a crash or power loss can be undone: the run log and the saved copies are written to disk before any file changes, and a half-written last log line is ignored.
- Saved copies and the run log are private to you on Linux and macOS.
