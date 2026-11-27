# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Test ps-bins-inst.ps1 on a scratch dir, never real paths.
# Flo: build fake repo > run installer per case > assert output and files > clean scratch
# I/O: scratch dir (disk) > ok/FAIL lines (stdout); exit 0 all pass, 1 any fail
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File E:\zz-base-home\as-apps\ai-mind\sk-skil-tool\ps-bins-inst-test.ps1
# ===================================================================
$ErrorActionPreference='Stop'
$real=if($env:SKIL_REAL){ $env:SKIL_REAL }else{ Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent }
$CF=@{inst=Join-Path $PSScriptRoot 'ps-bins-inst.ps1';exeA="$real\as-apps\os-syst\id-edit-iden\zig-out\dist\windows-x86_64\id-edit-iden.exe";exeB="$real\as-apps\os-syst\rn-name-upda\zig-out\dist\windows-x86_64\rn-name-upda.exe"}
if(-not ((Test-Path $CF.exeA) -and (Test-Path $CF.exeB))){ 'skip: build id-edit-iden and rn-name-upda dist first'; exit 0 }
$root=Join-Path ([IO.Path]::GetTempPath()) ("sk-test-"+[guid]::NewGuid().ToString('N').Substring(0,8))
$repo="$root\repo"; $srcz="$repo\as-apps\ai-mind\sk-skil-tool"; $dist="$repo\as-apps\xx\fb-app\zig-out\dist\testdist"; $binz="$root\bin"; $link="$root\link"; $stat="$root\stat"; $fail=0
New-Item -ItemType Directory -Force -Path "$srcz\face-book","$srcz\auto-task",$dist,$link | Out-Null
Set-Content "$srcz\so-skil-tool.json" "{`n`"fb-face`":`"face-book|as-apps/xx/fb-app`",`n`"zz-none`":`"nope-tool|as-apps/xx/none`"`n}" -Encoding ascii
Copy-Item $CF.exeA "$dist\fb-face.exe"
$env:SKIL_REPO=$repo; $env:SKIL_DIST='testdist'; $env:SKIL_BINZ=$binz; $env:SKIL_LINK=$link; $env:SKIL_STAT=$stat
function runz($argz){ $script:outz=@(& powershell -NoProfile -ExecutionPolicy Bypass -File $CF.inst @argz 2>&1 | ForEach-Object { "$_" }); $script:code=$LASTEXITCODE }
function chek($name,$cond){ if($cond){ "ok $name" }else{ "FAIL $name code=$code out=$($outz -join '|')"; $script:fail++ } }
function hasz($text){ $script:outz -contains $text }
function isln($name){ $item=Get-Item "$link\$name" -ErrorAction SilentlyContinue; [bool]($item -and $item.LinkType -eq 'Junction') }
runz @('-Dry'); chek 'dry changes nothing' ((-not (Test-Path $binz)) -and (-not (Test-Path "$link\face-book")) -and $code -eq 0)
runz @(); chek 'first run copies exe' ((hasz 'copied fb-face.exe') -and (Test-Path "$binz\fb-face.exe") -and $code -eq 0)
chek 'first run links skills' ((hasz 'linked face-book') -and (hasz 'linked auto-task') -and (isln 'face-book') -and (isln 'auto-task'))
chek 'missing src is reported' (hasz 'miss zz-none')
chek 'baseline hash saved' ((Get-Content "$stat\so-help-hash.txt") -match '^fb-face=[0-9A-F]{64}$')
chek 'path step skipped for a custom bin dir' (-not ($outz -match '^pathed'))
runz @(); chek 'second run is a no-op' (($outz.Count -eq 2) -and ($outz[1] -match 'copied=0 linked=0 unlinked=0 busy=0 miss=1 drift=0') -and $code -eq 0)
New-Item -ItemType Directory -Force -Path "$srcz\file-rena" | Out-Null; runz @(); chek 'new skill folder is linked' ((hasz 'linked file-rena') -and (isln 'file-rena'))
New-Item -ItemType Directory -Force -Path "$link\real-dir","$srcz\real-dir" | Out-Null; runz @(); chek 'real folder clash is skipped' ((hasz 'clash real-dir') -and -not (isln 'real-dir'))
New-Item -ItemType Directory -Force -Path "$root\elsewhere","$srcz\jct-clash" | Out-Null; New-Item -ItemType Junction -Path "$link\jct-clash" -Target "$root\elsewhere" | Out-Null; runz @(); chek 'foreign-target junction clash is skipped' ((hasz 'clash jct-clash') -and (@((Get-Item "$link\jct-clash").Target)[0] -eq "$root\elsewhere")); Move-Item "$srcz\jct-clash" "$root\moved-jct-clash"
New-Item -ItemType Directory -Force -Path "$root\gone2","$srcz\dead-clash" | Out-Null; New-Item -ItemType Junction -Path "$link\dead-clash" -Target "$root\gone2" | Out-Null; [IO.Directory]::Delete("$root\gone2"); runz @(); chek 'dead foreign junction on a skill name is a clash, not a crash' ((hasz 'clash dead-clash') -and $code -eq 0 -and (hasz 'done copied=0 linked=0 unlinked=0 busy=0 miss=1 drift=0')); Move-Item "$srcz\dead-clash" "$root\moved-dead-clash"
Move-Item "$srcz\real-dir" "$root\moved-real-dir"; Move-Item "$srcz\file-rena" "$root\moved-file-rena"; runz @(); chek 'dead link is removed' ((hasz 'unlinked file-rena') -and -not (Test-Path "$link\file-rena") -and (Test-Path "$link\real-dir"))
New-Item -ItemType Directory -Force -Path "$root\gone" | Out-Null; New-Item -ItemType Junction -Path "$link\foreign" -Target "$root\gone" | Out-Null; [IO.Directory]::Delete("$root\gone"); runz @(); chek 'foreign dead link is kept' ((-not (hasz 'unlinked foreign')) -and [bool](Get-ChildItem $link -Directory -Force | Where-Object Name -eq 'foreign')); [IO.Directory]::Delete("$link\foreign")
Set-Content "$binz\fb-face.exe" 'junk' -Encoding ascii; (Get-Item "$binz\fb-face.exe").LastWriteTimeUtc=(Get-Date).ToUniversalTime().AddMinutes(2); runz @(); chek 'older src never overwrites newer exe' ((-not (hasz 'copied fb-face.exe')) -and (Get-Content "$binz\fb-face.exe") -eq 'junk')
Copy-Item $CF.exeB "$dist\fb-face.exe" -Force; (Get-Item "$dist\fb-face.exe").LastWriteTimeUtc=(Get-Date).ToUniversalTime().AddMinutes(5)
$lock=[IO.File]::Open("$binz\fb-face.exe",'Open','Read','None'); runz @(); $lock.Close(); chek 'locked exe reports busy' ((hasz 'busy fb-face.exe') -and $code -eq 0)
runz @('-Dry'); chek 'dry run keeps newer exe uncopied' ((hasz 'would copy fb-face.exe') -and (Get-Content "$binz\fb-face.exe") -eq 'junk')
runz @(); chek 'newer exe is copied' (hasz 'copied fb-face.exe')
chek 'help change flags drift' ((hasz 'drift face-book') -and $code -eq 3)
runz @(); chek 'drift stays flagged' ((hasz 'drift face-book') -and $code -eq 3)
runz @('-Ack'); chek 'ack accepts new help' ((-not (hasz 'drift face-book')) -and $code -eq 0)
runz @(); chek 'clean after ack' ($code -eq 0 -and -not ($outz -match 'drift face-book'))
foreach($item in Get-ChildItem $link -Directory -Force){ if($item.LinkType -eq 'Junction'){ [IO.Directory]::Delete($item.FullName) } }
Remove-Item $root -Recurse -Force
if($fail -gt 0){ "FAIL total=$fail"; exit 1 }
"all ok"
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============