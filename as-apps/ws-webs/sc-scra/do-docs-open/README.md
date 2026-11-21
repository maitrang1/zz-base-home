# scra
Fetch public web pages at the lowest cost. Free first. Paid only when you say so.

## What it does
scra downloads text pages (HTML, JSON, XML) and stores them once on your PC. It tries a plain download first. If the site blocks it, it asks a scraping service (ZenRows, Decodo or Bright Data) but only while free credits last. You can add a spending cap and approve paid use yourself. Pages are copied to the cloud later, in the background. Images, video and fonts are never downloaded.

## Requirements
Windows or Linux, 64-bit. Zig 0.17.0 to build it. Vendor accounts and keys only if you want the paid or free scraping services.

## Quick start
1. Build once:
   cd /d E:\zz-base-home\as-apps\ws-webs\sc-scra
   zig build
2. Check it runs:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe status
   You see:
     scra 0.1.0 | read-only | kill false | spend 0/0 micro-USD | pages 0 | queue 0 pending 0 dead | disk cap 5 GB
3. Fetch one page (nothing happens until you add --live):
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe fetch https://example.com/ --live
   You see:
     new | 200 | T1  | https://example.com/ | 25ddf2c883e0d1958ea971d279a7e4f0fd446724ee3db7db19dadabd4a62e484
   Run it again and you see `notm | 304 ...`: the page did not change, so nothing was stored twice.

## Key behavior
- Every command that touches the network does nothing until you add `--live`.
- Vendors are used only after a plain download is blocked, and only inside free credits. Paid use needs `--live --force` and a spending cap.
- `scra kill --on` stops all vendor use at once.
- Your data lives in the tena folder: `E:\.zz-base-home-tena\as-apps\ws-webs\sc-scra` (Windows) or `~/.zz-base-home-tena/as-apps/ws-webs/sc-scra`.

## License
PolyForm Noncommercial 1.0.0. See LICENSE.

## Next
[HOW-TO.md](HOW-TO.md) · [CONFIG.md](CONFIG.md) · [UPDATE.md](UPDATE.md)
