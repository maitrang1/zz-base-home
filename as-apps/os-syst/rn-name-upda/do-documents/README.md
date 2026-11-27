# rn

Rename a file or folder, and fix every place that points to it.

## What it does

You give `rn` the old name and the new name. It finds the places that mention the old path: notes, scripts, config files, shortcuts, links, the Windows registry, your crontab. It changes them to the new path and renames the item. If anything goes wrong, it puts everything back. You can also undo a finished run.

Nothing is deleted. Before it touches a file, it saves a copy.

## Requirements

- Windows 10 or later, Linux, or macOS.
- Nothing else to install. It is one program.

## Quick start

1. Preview the change. This writes nothing:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe plan R:\work\old-app R:\work\new-app
```

```
plan R:/work/old-app -> R:/work/new-app
apply 6 · skip 0 (comp 0, enco 0) · dirs 4 files 5 scanned 5 bin 0 big 0 link 0 err 0
do   safe R:/work/tool.cfg:1 rela
do   safe R:/work/old-app/backup.cmd:2 nati
do   safe R:/work/old-app/backup.cmd:3 nati
do   safe R:/work/old-app/README.txt:1 fwds
do   safe R:/notes/todo.txt:1 nati
do   safe R:/notes/todo.txt:2 rela
```

2. Do it for real:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe runz R:\work\old-app R:\work\new-app --live
```

```
ok 20261123-140621 · patched 6 refs in 4 files · renamed · left 0 · flagged 0
undo: rn undo 20261123-140621 --live
```

3. Changed your mind? Undo it:

```
E:\zz-base-home\as-apps\os-syst\rn-name-upda\zig-out\bin\rn-name-upda.exe undo last --live
```

```
undone 20261123-140621 · restored 5 · already ok 0
```

## Good to know

- `runz` without `--live` only previews. Add `--live` to change things.
- Some places are risky, so `rn` lists them and leaves them alone: other users' files, system folders, program folders, cloud-synced folders, git folders, signed or lock files, and binary files. You can allow each one in the settings.
- The new name must sit in the same folder as the old one. Moving to another folder is not built yet.
- A short word like `old` on its own is never changed. Only full paths are.

## Next

- [HOW-TO.md](HOW-TO.md): every task, step by step
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed
