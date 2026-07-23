#!/usr/bin/env bash
# Builds the web release and packages it for BOTH hosts.
#
#   ./tool/package_web.sh
#
# Produces on the Desktop:
#   S800-cloudflare/  + S800-cloudflare.zip   → Cloudflare Pages
#   S800-netlify/     + S800-netlify.zip      → Netlify
#
# The two differ only in config files. In both, the site sits at the ROOT of
# the zip — a zip containing a wrapper directory deploys to a site with no
# index.html at the top level, which serves nothing.
set -euo pipefail

export PATH="$HOME/development/flutter/bin:$PATH"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESK="$HOME/Desktop"

cd "$ROOT"
flutter build web --release

cd build/web

# Debug symbol maps. Never requested by a browser; pure upload weight.
find . \( -name "*.symbols" -o -name "*.map" \) -delete

# CanvasKit ships several engine variants. A dart2js build only ever loads
# canvaskit.js + canvaskit.wasm, plus chromium/ on Chrome and Android. The
# skwasm/wimp/webparagraph builds are for `flutter build web --wasm`, which
# this is not — dropping them removes roughly 15 MB from every deploy.
rm -rf canvaskit/skwasm.js canvaskit/skwasm.wasm \
       canvaskit/skwasm_heavy.js canvaskit/skwasm_heavy.wasm \
       canvaskit/wimp.js canvaskit/wimp.wasm \
       canvaskit/experimental_webparagraph

build_variant() {
  local name="$1" drop="$2"
  local out="$DESK/S800-$name"

  rm -rf "$out" "$out.zip"
  cp -R . "$out"
  [ -n "$drop" ] && rm -f "$out/$drop"
  ( cd "$out" && zip -qr "$out.zip" . -x ".*" )

  printf '  %-12s %-7s %s files\n' \
    "$name" "$(du -h "$out.zip" | cut -f1)" "$(find "$out" -type f | wc -l | tr -d ' ')"
}

echo
# Cloudflare Pages reads _headers and _redirects; netlify.toml is dead weight.
build_variant cloudflare netlify.toml
# Netlify reads all three.
build_variant netlify ""
echo
echo "  Drag the FOLDER (or the zip) for whichever host you are using."
echo
