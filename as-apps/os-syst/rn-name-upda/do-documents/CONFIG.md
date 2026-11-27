# rn settings

## Program

| | |
|---|---|
| File | `E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe` |
| Run | `rn-name-upda plan OLD NEW` · `rn-name-upda runz OLD NEW [--live] [--force]` · `rn-name-upda undo ID or last [--live] [--force]` · `rn-name-upda stat` |
| Flags | `--conf FILE` settings file · `--json` JSON output · `--live` really change things · `--force` go past a blocked or changed item |
| Output | one result line, or JSON with `--json` |
| Built with | Zig, no other parts |

## Settings

Settings live in `aa-conf-main.json` in the `rn-name-upda` folder (two folders above the program). `rn` also accepts a copy placed right next to the program. A key you leave out uses the default below. To use another file, add `--conf FILE`.

Paths in lists may use `\` or `/`.

| Name | Does | Default | Allowed |
|---|---|---|---|
| apps_data_loca | Folder for runs, copies and the journal, inside the data root | `as-apps/os-syst/rn-name-upda` | folder path |
| tena_loca_wind | Data root on Windows | `E:\.zz-base-home-tena` | absolute path |
| tena_loca_unix | Data root on Linux and macOS | `.zz-base-home-tena` | path, relative to your home |
| scan_root_list | Folders to search for mentions. Empty means every fixed drive on Windows, `/` elsewhere | `[]` | list of paths |
| scan_alls_driv | On Windows with an empty list, search every fixed drive. If false, only the drive of the old path | `true` | true, false |
| scan_maxz | Biggest text file to read, in MB | `64` | whole number |
| scan_binz_maxz | Biggest binary file to read, in MB. 0 = never read binaries | `4` | whole number |
| scan_deep | Deepest folder level to enter | `96` | whole number |
| scan_skip_list | Folders never entered. A name matches anywhere; a path with `/` matches that place | pseudo folders, `C:/Windows`, `.zig-cache`, `.git/objects`, `node_modules` | list |
| scan_skip_ext | File endings counted as binary and never read | media, programs, archives | list |
| skip_bina | Binary files: list only (true) or patch when the new name has the same length (false) | `true` | true, false |
| skip_arch | Archives (zip, docx, xlsx...) | `true` | true, false |
| skip_sign_hash | Lock, signature and checksum files | `true` | true, false |
| skip_othe_user | Other users' folders | `true` | true, false |
| skip_syst_owne | System folders and system registry keys | `true` | true, false |
| skip_runn_proc | Reserved. There is no check for running programs yet | `true` | true, false |
| skip_sync_remo | Cloud-synced folders and network shares | `true` | true, false |
| skip_pack_mana | Program and package folders | `true` | true, false |
| skip_comp_part | A short name on its own, like `old` | `true` | true, false |
| skip_urls_exte | Reserved. There is no web address check yet | `true` | true, false |
| skip_enco_vari | Paths written with `\\` or as `file:///` | `false` | true, false |
| skip_gitz_hist | Anything inside a `.git` folder | `true` | true, false |
| skip_path_list | Single files to leave alone | `[]` | list of paths |
| skip_glob_list | Reserved, not used yet | `[]` | list |
| risk_syst_list | Folders that count as system | `C:/Windows`, `/etc`, `/usr`, ... | list |
| risk_pack_list | Folders that count as programs | `C:/Program Files`, `/opt`, ... | list |
| risk_sync_list | Folder names that count as cloud-synced | `OneDrive`, `Dropbox`, ... | list |
| risk_user_list | Folders that hold user homes | `C:/Users`, `/home`, `/Users` | list |
| risk_sign_list | File endings that count as signed or locked | `.lock`, `.sig`, `.sha256`, ... | list |
| risk_arch_list | File endings that count as archives | `.zip`, `.docx`, ... | list |
| loca_on | Also check the Windows registry or your crontab | `true` | true, false |
| loca_regk_list | Registry keys to check on Windows | environment, Run, Services | list |
| lock_retr | Tries again when a file is busy | `3` | whole number |
| plan_line_maxz | Most lines shown by a preview | `200` | whole number |

## Input

Two paths: the old one and the new one. Relative paths start from the folder you run `rn` in.

## Output

- A result line, and an exit code: 0 done · 1 failed and put back · 2 wrong command · 3 done, but some places were skipped or left · 4 blocked.
- `jour/<id>.jsonl`: the step list of each run.
- `snap/<id>/`: the saved copies of everything that was changed. Keep them until you are sure you do not need to undo.

## Files

| File | What |
|---|---|
| `aa-conf-main.json` | Your settings |
| `<data root>/<apps_data_loca>/jour/` | Run journals |
| `<data root>/<apps_data_loca>/snap/` | Saved copies |
