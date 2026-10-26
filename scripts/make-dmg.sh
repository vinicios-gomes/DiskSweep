#!/bin/bash
# Gera build/DiskSweep-<versão>.dmg (com atalho para /Applications) e o arquivo .sha256.
# Uso: VERSION=1.2.0 ./scripts/make-dmg.sh   (usa build/DiskSweep.app; rode build-app.sh antes)
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${VERSION:-dev}"
APP="build/DiskSweep.app"
DMG="build/DiskSweep-$VERSION.dmg"
[[ -d "$APP" ]] || { echo "Falta $APP — rode ./scripts/build-app.sh primeiro" >&2; exit 1; }

STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

rm -f "$DMG"
hdiutil create -volname "DiskSweep" -srcfolder "$STAGE" -ov -format UDZO -fs HFS+ "$DMG" >/dev/null
hdiutil verify "$DMG" >/dev/null
(cd build && shasum -a 256 "$(basename "$DMG")" > "$(basename "$DMG").sha256")
echo "OK: $DMG"; cat "$DMG.sha256"
