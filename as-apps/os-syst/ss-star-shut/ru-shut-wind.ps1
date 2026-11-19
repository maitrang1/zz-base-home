# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Close apps gracefully, fix Chrome flags, shut down Windows
# Flo: admin > cancel countdown > Explorer > VSCode > other apps > Chrome flags > countdown > shut down
# I/O: none > apps closed, PC off (any key in a countdown cancels)
# Run: E:\zz-base-home\as-apps\os-syst\ss-star-shut\ru-shut-wind.bat
# ===================================================================
$CF = @{ COUN_SECO = 9; VSCO_BKUP_WIPE = $false; WAIT_CODE = 10; WAIT_APPS = 8; WAIT_ELEC = 3; WAIT_COOL = 3; SKIP_LIST = @('System','Idle','svchost','lsass','csrss','wininit','winlogon','services','smss','Registry','MsMpEng','spoolsv','explorer','dwm','fontdrvhost','sihost','taskhostw','ctfmon','conhost','powershell','cmd','dasHost','dllhost','LsaIso','Memory Compression','RuntimeBroker','SearchIndexer','SearchApp','ShellExperienceHost','StartMenuExperienceHost','SystemSettings','TextInputHost','CompPkgSrv','PresentationFontCache','SecurityHealthService','UserOOBEBroker','WMIRegistrationService','wslservice','WUDFHost','NisSrv','MpDefenderCoreService','AggregatorHost','ApplicationFrameHost') }
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; exit }
function cnt_down($ttl, $subs) { Write-Host ""; Write-Host "====== $ttl ======"; $subs | ForEach-Object { Write-Host $_ }; Write-Host ""; for ($i = $CF.COUN_SECO; $i -ge 0; $i--) { $bar = ("-" * ($CF.COUN_SECO - $i)) + ("=" * $i); Write-Host -NoNewline "`r       [$bar] - ${i}s  "; if ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true); Write-Host ""; return $true }; Start-Sleep -Seconds 1 }; Write-Host ""; return $false }
function cnt_stop() { Write-Host ""; Write-Host "====== Key Pressed --> SHUT-DOWN CANCELLED ======"; Write-Host ""; Start-Sleep -Seconds $CF.WAIT_COOL; exit }
function close_expl() { $shell = New-Object -ComObject Shell.Application; $shell.Windows() | ForEach-Object { $_.Quit() }; Start-Sleep -Seconds 1 }
function close_elec() { Get-Process -Name "electron" -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() | Out-Null }; Start-Sleep -Seconds $CF.WAIT_ELEC }
function close_code() { Get-Process -Name "Code" -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() | Out-Null }; $w = 0; while ((Get-Process -Name "Code" -ErrorAction SilentlyContinue) -and $w -lt $CF.WAIT_CODE) { Start-Sleep -Seconds 1; $w++ }; Stop-Process -Name "Code" -Force -ErrorAction SilentlyContinue; if ($CF.VSCO_BKUP_WIPE) { $bak = "$env:APPDATA\Code\Backups"; if (Test-Path $bak) { Move-Item $bak ($bak + "_" + (Get-Date -Format "yyMMdd_HHmmss")) -ErrorAction SilentlyContinue } } }
function close_rest() { $procs = Get-Process | Where-Object { $CF.SKIP_LIST -notcontains $_.Name }; foreach ($p in $procs) { try { if ($p.MainWindowHandle -ne 0) { $p.CloseMainWindow() | Out-Null; $w = 0; while (!$p.HasExited -and $w -lt $CF.WAIT_APPS) { Start-Sleep -Seconds 1; $w++ } }; if (!$p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } } catch {} } }
function fix_flag($file) { if (Test-Path $file) { $txt = Get-Content $file -Raw; $txt = $txt -replace '"exited_cleanly":false', '"exited_cleanly":true'; $txt = $txt -replace '"exit_type":"Crashed"', '"exit_type":"Normal"'; Set-Content $file $txt -NoNewline } }
function fix_chrome() { $ud = "$env:LOCALAPPDATA\Google\Chrome\User Data"; fix_flag "$ud\Local State"; Get-ChildItem "$ud" -Directory | Where-Object { $_.Name -match '^(Default|Profile \d+)$' } | ForEach-Object { fix_flag (Join-Path $_.FullName "Preferences") } }
if (cnt_down "Close all Apps --> SHUT-DOWN the PC" @("  !! SAVE YOUR WORK FIRST -- unsaved files will be lost !!  ", "    Starting in $($CF.COUN_SECO)s -- Press any key to CANCEL    ")) { cnt_stop }
Write-Host ""; Write-Host "    closing apps... please... wait a moment.    "; Write-Host ""
close_expl; close_elec; close_code; close_rest; fix_chrome
if (cnt_down "Apps Closed --> Shutting Down in $($CF.COUN_SECO)s" @("           Press any key to CANCEL now           ")) { cnt_stop }
Write-Host ""; Write-Host "====== Countdown Done ----> SHUT-DOWN NOW! ======"; Write-Host ""
Start-Sleep -Seconds $CF.WAIT_COOL
shutdown.exe /s /t 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
