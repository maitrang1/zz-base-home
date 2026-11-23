#!/bin/sh
# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Bootstrap a fresh Linux/macOS/Termux device: toolchain + wo + drift check
# Flo: repo root > git config > mise (sha256 checked) > mise install --locked > build wo > wo doct
# I/O: none > exit 0 ok / 1 failed / 3 drift / 4 unsupported or blocked; prints the next manual step
# Run: sh /path/to/zz-base-home/mo-core/bs-boot-modu/sh-boot-stra.sh
# ===================================================================
set -eu
MISE_VERS=2026.11.9
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath ci-flow-sync
git config core.autocrlf false
case "$(uname -s)-$(uname -m)" in
Linux-x86_64) plat=linux-x64; want=23ba592fcbc61f057e2b82c1eafd085832712ba0c759b714ca16cd06babca378;;
Linux-aarch64|Linux-arm64) plat=linux-arm64; want=cf2900bfb4279f8d8f8a19d5c27bf1bde826b3e742182f3f67511c588498c786;;
Darwin-arm64) plat=macos-arm64; want=e4509f159e0492e89065edcf52f2918e2751e3574620586058468ba0563aed59;;
*) echo "bs: unsupported platform $(uname -s)-$(uname -m)" >&2; exit 4;;
esac
bind="${WO_MISE_DIR:-$HOME/.local/bin}"
hash256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }
if ! [ -x "$bind/mise" ] || ! "$bind/mise" --version 2>/dev/null | grep -q "^$MISE_VERS "; then
tmpd="$(mktemp -d)"
curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors -o "$tmpd/mise.tgz" "https://github.com/jdx/mise/releases/download/v$MISE_VERS/mise-v$MISE_VERS-$plat.tar.gz"
got="$(hash256 "$tmpd/mise.tgz")"
if [ "$got" != "$want" ]; then echo "bs: mise sha256 mismatch ($got): refusing to run it" >&2; exit 1; fi
tar -xzf "$tmpd/mise.tgz" -C "$tmpd"
mkdir -p "$bind"
cp "$tmpd/mise/bin/mise" "$bind/mise"
chmod +x "$bind/mise"
fi
PATH="$bind:$PATH"
export PATH
mise trust . >/dev/null
mise install --locked
mise exec -- zig build --build-file as-apps/os-syst/wo-work-mode/build.zig
prof=t0
if [ "${CI:-}" = "true" ]; then prof=ci; fi
mise exec -- as-apps/os-syst/wo-work-mode/zig-out/bin/wo --prof "$prof" doct
echo "bs: ok. Next: enroll this device in the tailnet, or lend a secret (wo secr lend)."
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
