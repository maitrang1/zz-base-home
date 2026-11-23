# What changed

## 2026-11-23

Added
- `rn plan` shows every place that mentions the old path and what would change.
- `rn runz` renames and fixes the mentions in one run. Without `--live` it only previews.
- `rn undo` puts any past run back exactly as it was.
- `rn stat` shows your skip switches and the last run.
- Finds plain text, UTF-16 text, binary files, links, Windows registry values and your crontab.
- Twelve risk groups, each with its own switch. Risky places are listed and left alone until you allow them.
- A failed run puts everything back by itself.

Changed
- Paths written with `\\` or as `file:///` are changed by default.

Fixed
- Nothing yet. First release.
