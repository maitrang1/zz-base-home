# Bootstrap settings

## Program
- Files: `ps-boot-stra.ps1` (Windows), `sh-boot-stra.sh` (Linux, macOS)
- Run: see README
- Output: lines on screen, exit code
- Built with: PowerShell, POSIX sh

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| WO_MISE_DIR | Folder where the tool manager is placed | `~/.local/bin` | any folder |
| CI | Use the short CI check | not set | `true` |

## Input
The git repo in the current folder.

## Output
Installed tools, a built `wo`, and the result of `wo doct`.

## Files
- `mise.toml` and `mise.lock` in the repo root (tool versions and checksums)
- `as-apps/os-syst/wo-work-mode/zig-out/bin/wo-work-mode` (built by the script)
