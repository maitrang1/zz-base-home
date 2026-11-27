# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Sync tool exes, skill links, and flag help drift.
# Flo: read map > copy newer exes > link new skills > unlink dead links > hash help > flag drift
# I/O: so-skil-tool.json + repo dist exes (disk) > bin dir, ~/.claude/skills links, help hashes (disk); exit 0 ok, 3 drift
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File E:\zz-base-home\as-apps\ai-mind\sk-skil-tool\ps-bins-inst.ps1 [-Dry] [-Ack]
# ===================================================================
param([switch]$Dry,[switch]$Ack)
$ErrorActionPreference='Stop'
function Env($k,$d){ $v=[Environment]::GetEnvironmentVariable($k); if($v){$v}else{$d} }
$CF=@{timeMs=10000;hlp=@{za='help'}}
$CF.repo=Env 'ZZ_REPO' (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent); $CF.src=Join-Path $CF.repo 'as-apps\ai-mind\sk-skil-tool'; $CF.dist=Env 'ZZ_DIST' 'windows-x86_64'
$CF.bin=Env 'ZZ_BIN' "$HOME\.zz-base-home-bin"; $CF.skl=Env 'ZZ_SKL' "$HOME\.claude\skills"; $CF.state=Env 'ZZ_STATE' (Join-Path (Split-Path $CF.repo -Parent) '.zz-base-home-tena\as-apps\ai-mind\sk-skil-tool')
$CF.map=Join-Path $CF.src 'so-skil-tool.json'
function Hsh($p){ try{ (Get-FileHash $p -Algorithm SHA256).Hash }catch{ $null } }
function HelpHash($exe,$arg){ try{ HelpHashRun $exe $arg }catch{ $null } }
function HelpHashRun($exe,$arg){ $p=New-Object Diagnostics.Process; $i=$p.StartInfo; $i.FileName=$exe; $i.Arguments=$arg; $i.RedirectStandardOutput=$true; $i.RedirectStandardError=$true; $i.UseShellExecute=$false; $i.CreateNoWindow=$true; [void]$p.Start(); $o=$p.StandardOutput.ReadToEndAsync(); $e=$p.StandardError.ReadToEndAsync(); if(-not $p.WaitForExit($CF.timeMs)){ $p.Kill(); return $null }; $t=(($o.Result+$e.Result) -replace "`r",'').Trim(); ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($t)))) -replace '-','' }
$n=@{copied=0;linked=0;unlinked=0;busy=0;drift=0;miss=0}
$map=[ordered]@{}
foreach($l in Get-Content $CF.map){ if($l -match '^"([a-z]+)":"([a-z\-]+)\|([^"]+)"'){ $map[$Matches[1]]=@($Matches[2],$Matches[3]) } }
if(-not $Dry){ New-Item -ItemType Directory -Force -Path $CF.bin,$CF.skl | Out-Null }
foreach($t in $map.Keys){ $s=Join-Path $CF.repo (Join-Path $map[$t][1] "zig-out\dist\$($CF.dist)\$t.exe"); $d=Join-Path $CF.bin "$t.exe"; if(-not (Test-Path $s)){ "miss $t"; $n.miss++; continue }; if((Test-Path $d) -and (((Get-Item $s).LastWriteTimeUtc -le (Get-Item $d).LastWriteTimeUtc) -or ((Hsh $s) -eq (Hsh $d)))){ continue }; if($Dry){ "would copy $t.exe"; continue }; try{ Copy-Item $s "$d.new" -Force; Move-Item "$d.new" $d -Force; "copied $t.exe"; $n.copied++ }catch{ Remove-Item "$d.new" -Force -ErrorAction SilentlyContinue; "busy $t.exe"; $n.busy++ } }
foreach($f in Get-ChildItem $CF.src -Directory){ $l=Join-Path $CF.skl $f.Name; if(Test-Path $l){ $g=Get-Item $l; if(@($g.Target)[0] -ne $f.FullName){ "clash $($f.Name)" }; continue }; if($Dry){ "would link $($f.Name)"; continue }; New-Item -ItemType Junction -Path $l -Target $f.FullName | Out-Null; "linked $($f.Name)"; $n.linked++ }
if(Test-Path $CF.skl){ foreach($j in Get-ChildItem $CF.skl -Directory){ $g=@($j.Target)[0]; if($j.LinkType -eq 'Junction' -and $g -and $g.StartsWith($CF.src,[StringComparison]::OrdinalIgnoreCase) -and -not (Test-Path $g)){ if($Dry){ "would unlink $($j.Name)" } else { [IO.Directory]::Delete($j.FullName); "unlinked $($j.Name)"; $n.unlinked++ } } } }
$sf=Join-Path $CF.state 'so-help-hash.txt'; $old=@{}; $new=[ordered]@{}
if(Test-Path $sf){ foreach($l in Get-Content $sf){ $k,$v=$l -split '=',2; $old[$k]=$v } }
foreach($t in $map.Keys){ $d=Join-Path $CF.bin "$t.exe"; if(-not (Test-Path $d)){ continue }; $a=if($CF.hlp[$t]){ $CF.hlp[$t] }else{ '--help' }; $h=HelpHash $d $a; if(-not $h){ continue }; $new[$t]=$h; if($old[$t] -and $old[$t] -ne $h -and -not $Ack){ "drift $($map[$t][0])"; $n.drift++; $new[$t]=$old[$t] } }
foreach($k in $old.Keys){ if(-not $new.Contains($k)){ $new[$k]=$old[$k] } }
if(-not $Dry){ New-Item -ItemType Directory -Force -Path $CF.state | Out-Null; [IO.File]::WriteAllLines("$sf.tmp",[string[]]@($new.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" })); Move-Item "$sf.tmp" $sf -Force }
"done copied=$($n.copied) linked=$($n.linked) unlinked=$($n.unlinked) busy=$($n.busy) miss=$($n.miss) drift=$($n.drift)"
if($n.drift -gt 0){ exit 3 }
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============