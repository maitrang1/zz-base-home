# How to use rn

In every command below, `rn` means `E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe`.

## Preview a rename

1. Run:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe plan R:\work\old-app R:\work\new-app
```

2. Read the second line. `apply 6` means 6 places will change. `skip 3` means 3 places are listed but left alone.
3. Each line after that is one place: `do` (will change) or `skip` (left alone), its kind, the file and line.

The exit code is 0 when nothing is skipped and 3 when something is skipped.

## Rename for real

1. Preview first (above).
2. Run:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe runz R:\work\old-app R:\work\new-app --live
```

3. Read the answer:

```
ok 20261123-140621 · patched 6 refs in 4 files · renamed · left 0 · flagged 0
undo: rn undo 20261123-140621 --live
```

- `patched` is how many places changed.
- `left` is how many places that should have changed are still there. It should be 0.
- `flagged` is how many places were found and skipped on purpose.
- The code in the first line is the run id. Keep it if you want to undo later.

If something fails, `rn` puts everything back and says why:

```
failed 20261123-140621: Blocked · rolled back, nothing changed
```

## Undo a run

1. Undo the latest run:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe undo last --live
```

2. Or undo a named run: replace `last` with the run id.
3. Add no `--live` to preview the undo.

If you edited one of the changed files after the run, `rn` stops and changes nothing:

```
blocked 20261123-140621: 1 items changed since the run. Nothing undone. Add --force to overwrite them.
```

Add `--force` only if you are sure you want your later edit replaced by the saved copy.

## Allow a skipped place

1. Run a preview and look at the class of the skipped lines: `comp`, `bina`, `syst`, `othe`, `sync`, `pack`, `gitz`, `sign`, `arch`.
2. Open `aa-conf-main.json` and set the matching key to `false` (see CONFIG.md).
3. Run the preview again. The line now says `do`.

## Check the last run

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe stat
```

```
rn 0.1.0 · windows · data R:/tena/as-apps/os-syst/rn-name-upda
skip on: bina arch sign_hash othe_user syst_owne runn_proc sync_remo pack_mana comp_part urls_exte gitz_hist
last run 20261123-140621: done
```

If the last line says `open run`, a run was cut short. Run `rn undo <id> --live --force` to put things back.

## Use a different settings file

Add `--conf` and the file path to any command:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe --conf R:\conf.json plan R:\work\old-app R:\work\new-app
```

## Machine-readable output

Add `--json` to any command to get one line of JSON.

## Errors

| Message | Fix |
|---|---|
| `rn: old path not found. Check the spelling and run again.` | Check the old path. |
| `rn: new path already exists. Pick a free name.` | Choose a name that is not taken. |
| `rn: rename keeps the same parent folder. A move is not built yet.` | Put the new name in the same folder as the old one. |
| `rn: old and new names are the same. Nothing to do.` | Use a different new name. |
| `rn: no runs yet. Nothing to undo.` | Nothing has been run yet. |
| `rn: run <id> is already undone.` | That run was already undone. |
| `rn: no run named <id>. Run rn stat to see the last one.` | Check the run id. |
