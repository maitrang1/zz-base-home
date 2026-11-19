# Updates

## 2026-11-19 · Moved here
- The One-Tap Keys script now lives in this repo as `ks-keys-shor`, next to the startup and shutdown scripts.
- Changed: double-tap **End** now runs `ru-shut-wind.bat`. It saves your work, closes apps, and shows a countdown you can cancel.
- Changed: the login script starts it for you, as admin.
- Changed: the script is now three files in the repo style: the keys (`ru-keys-shor.ahk`, one line per key), the shared helpers with the settings (`ut-keys-func.ahk`), and a safe test file. Every key does what it did before.
- Tested: 13 of 13 helper checks pass. The keys themselves are not run by the tests; check them once on your PC.
