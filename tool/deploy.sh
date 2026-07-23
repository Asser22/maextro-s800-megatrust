#!/usr/bin/env bash
# Rebuild the site and publish it.
#
#   ./tool/deploy.sh "what changed"
#
# Builds TWICE, because the two hosts serve from different paths and Flutter
# bakes the base path into index.html at build time:
#
#   public/  base href "/"                        -> Cloudflare / Netlify
#   docs/    base href "/maextro-s800-megatrust/" -> GitHub Pages
#
# Both are committed, so a push is a deploy on all three.
set -euo pipefail

export PATH="$HOME/development/flutter/bin:$PATH"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MSG="${1:-Update site}"
REPO="maextro-s800-megatrust"

flutter analyze --no-fatal-infos
flutter test

trim() {
  # Debug symbol maps: never fetched by a browser, pure weight.
  find "$1" \( -name "*.symbols" -o -name "*.map" \) -delete
  # CanvasKit ships several engine variants. A dart2js build only loads
  # canvaskit.js + canvaskit.wasm, plus chromium/ on Chrome and Android; the
  # skwasm/wimp/webparagraph builds are for `flutter build web --wasm`.
  rm -rf "$1"/canvaskit/skwasm.js "$1"/canvaskit/skwasm.wasm \
         "$1"/canvaskit/skwasm_heavy.js "$1"/canvaskit/skwasm_heavy.wasm \
         "$1"/canvaskit/wimp.js "$1"/canvaskit/wimp.wasm \
         "$1"/canvaskit/experimental_webparagraph
}

# ── Cloudflare / Netlify: served from the domain root ────────────────────────
flutter build web --release --base-href /
trim build/web
rm -rf public && cp -R build/web public

# ── GitHub Pages: served from /<repo>/ ──────────────────────────────────────
flutter build web --release --base-href "/$REPO/"
trim build/web
rm -rf docs && cp -R build/web docs
# Without this, Pages runs Jekyll, which silently drops files and directories
# whose names begin with an underscore — including _headers.
touch docs/.nojekyll

git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit."
else
  git commit -q -m "$MSG"
fi
git push -q origin main

cat <<EOF

  Pushed.
    GitHub Pages : https://asser22.github.io/$REPO/
    Cloudflare   : publishes from public/ in about a minute
  Sizes: public $(du -sh public | cut -f1) · docs $(du -sh docs | cut -f1)

EOF
