# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Install tool exes to PATH and link skills for Claude.
# Flo: find dist exes > copy to bin dir > add bin to user PATH > link skill dirs
# I/O: repo dist exes + skill dirs (disk) > bin dir, PATH, ~/.claude/skills links (disk)
# Run: powershell -NoProfile -File E:\zz-base-home\as-apps\ai-mind\sk-skil-tool\ps-bins-inst.ps1
# ===================================================================
$ErrorActionPreference='Stop'
$CF=@{repo='E:\zz-base-home';bin="$HOME\.zz-base-home-bin";skl="$HOME\.claude\skills";src='E:\zz-base-home\as-apps\ai-mind\sk-skil-tool';dist='zig-out\dist\windows-x86_64';skip=@('auto-task.exe','cmd-run.exe')}
New-Item -ItemType Directory -Force -Path $CF.bin | Out-Null
$exes=Get-ChildItem $CF.repo -Recurse -Filter *.exe -ErrorAction SilentlyContinue | Where-Object { $_.FullName -like "*\$($CF.dist)\*" -and $_.FullName -notlike '*\zz-dele-auto\*' -and $CF.skip -notcontains $_.Name }
foreach($e in $exes){ Copy-Item $e.FullName (Join-Path $CF.bin $e.Name) -Force; "copied $($e.Name)" }
$usr=[Environment]::GetEnvironmentVariable('Path','User')
if(($usr -split ';') -notcontains $CF.bin){ [Environment]::SetEnvironmentVariable('Path',($usr.TrimEnd(';')+';'+$CF.bin),'User'); 'PATH updated (restart terminal)' }
New-Item -ItemType Directory -Force -Path $CF.skl | Out-Null
foreach($d in Get-ChildItem $CF.src -Directory){ $lnk=Join-Path $CF.skl $d.Name; if(-not (Test-Path $lnk)){ New-Item -ItemType Junction -Path $lnk -Target $d.FullName | Out-Null; "linked $($d.Name)" } else { "exists $($d.Name)" } }
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============