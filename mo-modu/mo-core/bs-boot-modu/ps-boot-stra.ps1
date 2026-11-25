# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Bootstrap a fresh Windows device: toolchain, wo, drift check
# Flo: repo root > git config > mise (sha256 checked) > mise install --locked > build wo > wo doct
# I/O: none > exit 0 ok / 1 failed / 3 drift / 4 blocked; prints the next manual step
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File E:\zz-base-home\mo-core\bs-boot-modu\ps-boot-stra.ps1
# ===================================================================
$ErrorActionPreference = 'Stop'
$CF = @{ Vers = '2026.11.9'; Hash = '29a4b496bf859f2b3c9563c90e695fb504a8d6ce067635730cd6f3f90c9826cd' }
Set-Location (git rev-parse --show-toplevel)
git config core.hooksPath ci-flow-sync
git config core.autocrlf false
git config core.longpaths true
$bind = if ($env:WO_MISE_DIR) { $env:WO_MISE_DIR } else { Join-Path $HOME '.local\bin' }
$mise = Join-Path $bind 'mise.exe'
$have = $false
if (Test-Path $mise) { $have = ((& $mise --version) -match ('^' + [regex]::Escape($CF.Vers) + ' ')) }
if (-not $have) {
$tmpd = Join-Path ([IO.Path]::GetTempPath()) ('wo-bs-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmpd | Out-Null
$zipf = Join-Path $tmpd 'mise.zip'
Invoke-WebRequest -UseBasicParsing -Uri ('https://github.com/jdx/mise/releases/download/v' + $CF.Vers + '/mise-v' + $CF.Vers + '-windows-x64.zip') -OutFile $zipf
$got = (Get-FileHash -Algorithm SHA256 $zipf).Hash.ToLower()
if ($got -ne $CF.Hash) { [Console]::Error.WriteLine("bs: mise sha256 mismatch ($got): refusing to run it"); exit 1 }
Expand-Archive -Path $zipf -DestinationPath $tmpd
New-Item -ItemType Directory -Force -Path $bind | Out-Null
Copy-Item (Join-Path $tmpd 'mise\bin\*') $bind -Force
}
$env:PATH = $bind + ';' + $env:PATH
& $mise trust . | Out-Null
& $mise install --locked
if ($LASTEXITCODE -ne 0) { exit 1 }
& $mise exec -- zig build --build-file as-apps/os-syst/wo-work-mode/build.zig
if ($LASTEXITCODE -ne 0) { exit 1 }
$prof = if ($env:CI -eq 'true') { 'ci' } else { 't0' }
& $mise exec -- as-apps\os-syst\wo-work-mode\zig-out\bin\wo.exe --prof $prof doct
$code = $LASTEXITCODE
if ($code -eq 0) { Write-Output 'bs: ok. Next: enroll this device in the tailnet, or lend a secret (wo secr lend).' }
exit $code
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
