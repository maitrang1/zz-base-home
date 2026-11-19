@rem ===================================================================
@rem Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
@rem Des: Start the close-apps-then-shut-down script
@rem Flo: run ru-shut-wind.ps1 with PowerShell
@rem I/O: [-Auto] > apps closed, PC off (any key in a countdown cancels; -Auto = no UAC, no countdowns, for tr jobs)
@rem Run: "E:\zz-base-home\as-apps\os-syst\ss-star-shut\ru-shut-wind.bat"
@rem ===================================================================
@echo off
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ru-shut-wind.ps1" %*
@rem =======================___THIS_IS_THE_END___=======================
@rem ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
