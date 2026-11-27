# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Test ps-bins-inst.ps1 on a scratch dir, never real paths.
# Flo: build fake repo > run installer per case > assert output and files > clean scratch
# I/O: scratch dir (disk) > ok/FAIL lines (stdout); exit 0 all pass, 1 any fail
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File E:\zz-base-home\as-apps\ai-mind\sk-skil-tool\ps-bins-inst-test.ps1
# ===================================================================
$ErrorActionPreference='Stop'
$real=if($env:ZZ_REAL){ $env:ZZ_REAL }else{ Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent }
$CF=@{inst=Join-Path $PSScriptRoot 'ps-bins-inst.ps1';exeA="$real\as-apps\os-syst\id-edit-iden\zig-out\dist\windows-x86_64\ie.exe";exeB="$real\as-apps\os-syst\rn-name-upda\zig-out\dist\windows-x86_64\rn.exe"}
if(-not ((Test-Path $CF.exeA) -and (Test-Path $CF.exeB))){ 'skip: build ie and rn dist first'; exit 0 }
$root=Join-Path ([IO.Path]::GetTempPath()) ("sk-test-"+[guid]::NewGuid().ToString('N').Substring(0,8))
$repo="$root\repo"; $sk="$repo\as-apps\ai-mind\sk-skil-tool"; $dist="$repo\as-apps\xx\fb-app\zig-out\dist\testdist"; $bin="$root\bin"; $skl="$root\skl"; $st="$root\st"; $f=0
New-Item -ItemType Directory -Force -Path "$sk\face-book","$sk\auto-task",$dist,$skl | Out-Null
Set-Content "$sk\so-skil-tool.json" "{`n`"fb`":`"face-book|as-apps/xx/fb-app`",`n`"zz`":`"nope-tool|as-apps/xx/none`"`n}" -Encoding ascii
Copy-Item $CF.exeA "$dist\fb.exe"
$env:ZZ_REPO=$repo; $env:ZZ_DIST='testdist'; $env:ZZ_BIN=$bin; $env:ZZ_SKL=$skl; $env:ZZ_STATE=$st
function Run($a){ $script:o=@(& powershell -NoProfile -ExecutionPolicy Bypass -File $CF.inst @a 2>&1 | ForEach-Object { "$_" }); $script:rc=$LASTEXITCODE; ($script:o -join '|') }
function T($n,$c){ if($c){ "ok $n" }else{ "FAIL $n rc=$rc out=$($o -join '|')"; $script:f++ } }
function Has($p){ $script:o -contains $p }
function Link($n){ $i=Get-Item "$skl\$n" -ErrorAction SilentlyContinue; $i -and $i.LinkType -eq 'Junction' }
[void](Run @('-Dry')); T 'dry changes nothing' ((-not (Test-Path $bin)) -and (-not (Test-Path "$skl\face-book")) -and $rc -eq 0)
[void](Run @()); T 'first run copies exe' ((Has 'copied fb.exe') -and (Test-Path "$bin\fb.exe") -and $rc -eq 0)
T 'first run links skills' ((Has 'linked face-book') -and (Has 'linked auto-task') -and (Link 'face-book') -and (Link 'auto-task'))
T 'missing src is reported' (Has 'miss zz')
T 'baseline hash saved' ((Get-Content "$st\so-help-hash.txt") -match '^fb=[0-9A-F]{64}$')
[void](Run @()); T 'second run is a no-op' (($o.Count -eq 2) -and ($o[1] -match 'copied=0 linked=0 unlinked=0 busy=0 miss=1 drift=0') -and $rc -eq 0)
New-Item -ItemType Directory -Force -Path "$sk\file-rena" | Out-Null; [void](Run @()); T 'new skill folder is linked' ((Has 'linked file-rena') -and (Link 'file-rena'))
New-Item -ItemType Directory -Force -Path "$skl\real-dir" | Out-Null; New-Item -ItemType Directory -Force -Path "$sk\real-dir" | Out-Null; [void](Run @()); T 'real folder clash is skipped' ((Has 'clash real-dir') -and -not (Link 'real-dir'))
New-Item -ItemType Directory -Force -Path "$root\elsewhere","$sk\jct-clash" | Out-Null; New-Item -ItemType Junction -Path "$skl\jct-clash" -Target "$root\elsewhere" | Out-Null; [void](Run @()); T 'foreign-target junction clash is skipped' ((Has 'clash jct-clash') -and (@((Get-Item "$skl\jct-clash").Target)[0] -eq "$root\elsewhere")); Move-Item "$sk\jct-clash" "$root\moved-jct-clash"
Move-Item "$sk\real-dir" "$root\moved-real-dir"; Move-Item "$sk\file-rena" "$root\moved-file-rena"; [void](Run @()); T 'dead link is removed' ((Has 'unlinked file-rena') -and -not (Test-Path "$skl\file-rena") -and (Test-Path "$skl\real-dir"))
New-Item -ItemType Directory -Force -Path "$root\gone" | Out-Null; New-Item -ItemType Junction -Path "$skl\foreign" -Target "$root\gone" | Out-Null; [IO.Directory]::Delete("$root\gone"); [void](Run @()); T 'foreign dead link is kept' ((-not (Has 'unlinked foreign')) -and [bool](Get-ChildItem $skl -Directory | Where-Object Name -eq 'foreign')); [IO.Directory]::Delete("$skl\foreign")
Set-Content "$bin\fb.exe" 'junk' -Encoding ascii; (Get-Item "$bin\fb.exe").LastWriteTimeUtc=(Get-Date).ToUniversalTime().AddMinutes(2); [void](Run @()); T 'older src never overwrites newer exe' ((-not (Has 'copied fb.exe')) -and (Get-Content "$bin\fb.exe") -eq 'junk')
Copy-Item $CF.exeB "$dist\fb.exe" -Force; (Get-Item "$dist\fb.exe").LastWriteTimeUtc=(Get-Date).ToUniversalTime().AddMinutes(5)
$fs=[IO.File]::Open("$bin\fb.exe",'Open','Read','None'); [void](Run @()); $fs.Close(); T 'locked exe reports busy' ((Has 'busy fb.exe') -and $rc -eq 0)
[void](Run @('-Dry')); T 'dry run keeps newer exe uncopied' ((Has 'would copy fb.exe') -and (Get-Content "$bin\fb.exe") -eq 'junk')
[void](Run @()); T 'newer exe is copied' (Has 'copied fb.exe')
T 'help change flags drift' ((Has 'drift face-book') -and $rc -eq 3)
[void](Run @()); T 'drift stays flagged' ((Has 'drift face-book') -and $rc -eq 3)
[void](Run @('-Ack')); T 'ack accepts new help' ((-not (Has 'drift face-book')) -and $rc -eq 0)
[void](Run @()); T 'clean after ack' ($rc -eq 0 -and -not ($o -match 'drift face-book'))
foreach($j in Get-ChildItem $skl -Directory){ if($j.LinkType -eq 'Junction'){ [IO.Directory]::Delete($j.FullName) } }
Remove-Item $root -Recurse -Force
if($f -gt 0){ "FAIL total=$f"; exit 1 }
"all ok"
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============