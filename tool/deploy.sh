#!/usr/bin/env bash
# Rebuild the site and publish it.
#
#   ./tool/deploy.sh "what changed"
#
# Builds into public/, commits, and pushes. Cloudflare Pages is connected to
# this repo with no build command and public/ as the output directory, so the
# push IS the deploy — live in about a minute, with no dashboard upload.
set -euo pipefail

export PATH="$HOME/development/flutter/bin:$PATH"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MSG="${1:-Update site}"

flutter analyze --no-fatal-infos
flutter test
flutter build web --release

# Debug symbol maps: never fetched by a browser, pure weight.
find build/web \( -name "*.symbols" -o -name "*.map" \) -delete

# CanvasKit ships several engine variants. A dart2js build only loads
# canvaskit.js + canvaskit.wasm, plus chromium/ on Chrome and Android; the
# skwasm/wimp/webparagraph builds are for `flutter build web --wasm`.
rm -rf build/web/canvaskit/skwasm.js build/web/canvaskit/skwasm.wasm \
       build/web/canvaskit/skwasm_heavy.js build/web/canvaskit/skwasm_heavy.wasm \
       build/web/canvaskit/wimp.js build/web/canvaskit/wimp.wasm \
       build/web/canvaskit/experimental_webparagraph

rm -rf public
cp -R build/web public

git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit."
else
  git commit -q -m "$MSG"
fi
git push -q origin main

echo
echo "  Pushed. Cloudflare Pages will publish in about a minute."
echo "  Site size: $(du -sh public | cut -f1)"
echo
