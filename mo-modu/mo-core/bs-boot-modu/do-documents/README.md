# Bootstrap

One command that sets up a fresh device for zz-base-home: tools, the `wo` command and a health check.

## What it does
It installs the pinned tools, builds `wo` and runs `wo doct`. It checks its own download first and stops if the check fails.

## Requirements
- `git` and an internet connection
- Windows: PowerShell. Linux, macOS: `curl` and `tar`.

## Quick start
1. Open a terminal in your zz-base-home folder.
2. Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File E:\zz-base-home\mo-core\bs-boot-modu\ps-boot-stra.ps1`
Linux/macOS: `sh /path/to/zz-base-home/mo-core/bs-boot-modu/sh-boot-stra.sh`
3. At the end you see `bs: ok. Next: enroll this device in the tailnet, or lend a secret (wo secr lend).`

## Key behavior
- Exit code 0 = ready · 3 = the check found drift · 4 = this system is not supported · 1 = something failed.
- A wrong download checksum stops everything and installs nothing.

## Next
- [HOW-TO.md](HOW-TO.md)
- [CONFIG.md](CONFIG.md)
- [UPDATE.md](UPDATE.md)
