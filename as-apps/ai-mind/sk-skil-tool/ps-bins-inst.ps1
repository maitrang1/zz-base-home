# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Sync tool exes, skill links, and flag help drift.
# Flo: read map > copy newer exes > add PATH > link new skills > unlink dead links > hash help > flag drift
# I/O: so-skil-tool.json + repo dist exes (disk) > bin dir, user PATH, ~/.claude/skills links, help hashes (disk); exit 0 ok, 3 drift
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File E:\zz-base-home\as-apps\ai-mind\sk-skil-tool\ps-bins-inst.ps1 [-Dry] [-Ack]
# ===================================================================
param([switch]$Dry,[switch]$Ack)
$ErrorActionPreference='Stop'
function envzRead($keyz,$defa){ $valu=[Environment]::GetEnvironmentVariable($keyz); if($valu){ $valu }else{ $defa } }
$CF=@{timeMsec=10000;helpArgz=@{za='help'}}
$CF.repo=envzRead 'SKIL_REPO' (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent); $CF.srcz=Join-Path $CF.repo 'as-apps\ai-mind\sk-skil-tool'; $CF.dist=envzRead 'SKIL_DIST' 'windows-x86_64'
$CF.binz=envzRead 'SKIL_BINZ' "$HOME\.zz-base-home-bin"; $CF.link=envzRead 'SKIL_LINK' "$HOME\.claude\skills"; $CF.stat=envzRead 'SKIL_STAT' (Join-Path (Split-Path $CF.repo -Parent) '.zz-base-home-tena\as-apps\ai-mind\sk-skil-tool')
$CF.mapz=Join-Path $CF.srcz 'so-skil-tool.json'
function fileHash($path){ try{ (Get-FileHash $path -Algorithm SHA256).Hash }catch{ $null } }
function helpExec($exez,$argz){ $proc=New-Object Diagnostics.Process; $info=$proc.StartInfo; $info.FileName=$exez; $info.Arguments=$argz; $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true; $info.UseShellExecute=$false; $info.CreateNoWindow=$true; [void]$proc.Start(); $outz=$proc.StandardOutput.ReadToEndAsync(); $errz=$proc.StandardError.ReadToEndAsync(); if(-not $proc.WaitForExit($CF.timeMsec)){ $proc.Kill(); return $null }; $text=(($outz.Result+$errz.Result) -replace "`r",'').Trim(); ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($text)))) -replace '-','' }
function helpHash($exez,$argz){ try{ helpExec $exez $argz }catch{ $null } }
$cnts=@{copy=0;link=0;dead=0;busy=0;miss=0;drif=0}
$mapz=[ordered]@{}
foreach($line in Get-Content $CF.mapz){ if($line -match '^"([a-z]+)":"([a-z\-]+)\|([^"]+)"'){ $mapz[$Matches[1]]=@($Matches[2],$Matches[3]) } }
if(-not $Dry){ New-Item -ItemType Directory -Force -Path $CF.binz,$CF.link | Out-Null }
foreach($tool in $mapz.Keys){ $srcz=Join-Path $CF.repo (Join-Path $mapz[$tool][1] "zig-out\dist\$($CF.dist)\$tool.exe"); $dstz=Join-Path $CF.binz "$tool.exe"; if(-not (Test-Path $srcz)){ "miss $tool"; $cnts.miss++; continue }; if((Test-Path $dstz) -and (((Get-Item $srcz).LastWriteTimeUtc -le (Get-Item $dstz).LastWriteTimeUtc) -or ((fileHash $srcz) -eq (fileHash $dstz)))){ continue }; if($Dry){ "would copy $tool.exe"; continue }; try{ Copy-Item $srcz "$dstz.new" -Force; Move-Item "$dstz.new" $dstz -Force; "copied $tool.exe"; $cnts.copy++ }catch{ Remove-Item "$dstz.new" -Force -ErrorAction SilentlyContinue; "busy $tool.exe"; $cnts.busy++ } }
if(-not $env:SKIL_BINZ -and -not $Dry){ $path=[Environment]::GetEnvironmentVariable('Path','User'); if(($path -split ';') -notcontains $CF.binz){ [Environment]::SetEnvironmentVariable('Path',($path.TrimEnd(';')+';'+$CF.binz),'User'); 'pathed (restart terminals)' } }
foreach($fold in Get-ChildItem $CF.srcz -Directory){ $link=Join-Path $CF.link $fold.Name; $item=Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue; if($item){ if(@($item.Target)[0] -ne $fold.FullName){ "clash $($fold.Name)" }; continue }; if($Dry){ "would link $($fold.Name)"; continue }; New-Item -ItemType Junction -Path $link -Target $fold.FullName | Out-Null; "linked $($fold.Name)"; $cnts.link++ }
if(Test-Path $CF.link){ foreach($item in Get-ChildItem $CF.link -Directory -Force){ $targ=@($item.Target)[0]; if($item.LinkType -eq 'Junction' -and $targ -and $targ.StartsWith($CF.srcz,[StringComparison]::OrdinalIgnoreCase) -and -not (Test-Path $targ)){ if($Dry){ "would unlink $($item.Name)" }else{ [IO.Directory]::Delete($item.FullName); "unlinked $($item.Name)"; $cnts.dead++ } } } }
$file=Join-Path $CF.stat 'so-help-hash.txt'; $oldz=@{}; $newz=[ordered]@{}
if(Test-Path $file){ foreach($line in Get-Content $file){ $keyz,$valu=$line -split '=',2; $oldz[$keyz]=$valu } }
foreach($tool in $mapz.Keys){ $dstz=Join-Path $CF.binz "$tool.exe"; if(-not (Test-Path $dstz)){ continue }; $argz=if($CF.helpArgz[$tool]){ $CF.helpArgz[$tool] }else{ '--help' }; $hash=helpHash $dstz $argz; if(-not $hash){ continue }; $newz[$tool]=$hash; if($oldz[$tool] -and $oldz[$tool] -ne $hash -and -not $Ack){ "drift $($mapz[$tool][0])"; $cnts.drif++; $newz[$tool]=$oldz[$tool] } }
foreach($keyz in $oldz.Keys){ if(-not $newz.Contains($keyz)){ $newz[$keyz]=$oldz[$keyz] } }
if(-not $Dry){ New-Item -ItemType Directory -Force -Path $CF.stat | Out-Null; [IO.File]::WriteAllLines("$file.tmp",[string[]]@($newz.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" })); Move-Item "$file.tmp" $file -Force }
"done copied=$($cnts.copy) linked=$($cnts.link) unlinked=$($cnts.dead) busy=$($cnts.busy) miss=$($cnts.miss) drift=$($cnts.drif)"
if($cnts.drif -gt 0){ exit 3 }
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============