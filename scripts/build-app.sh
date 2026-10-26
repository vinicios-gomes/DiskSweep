#!/bin/bash
# Compila o app e gera build/DiskSweep.app (com a pasta shell/ embutida).
# Usa `swift build` (SwiftPM). Se o SwiftPM do toolchain instalado não conseguir linkar o manifest
# (acontece só com Command Line Tools), cai para swiftc direto com os mesmos fontes.
set -euo pipefail
cd "$(dirname "$0")/.."
APP="build/DiskSweep.app"; BIN="$APP/Contents/MacOS/DiskSweep"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

if swift build -c release >/dev/null 2>&1; then
  cp "$(swift build -c release --show-bin-path)/DiskSweep" "$BIN"; echo "compilado com SwiftPM"
else
  echo "SwiftPM indisponível neste toolchain; compilando com swiftc"
  swiftc -O -parse-as-library -swift-version 5 -target arm64-apple-macosx14.0 \
    $(find Sources/DiskSweep -name '*.swift') -o "$BIN"
fi

cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp -R shell "$APP/Contents/Resources/shell"
codesign --force --sign - "$APP" 2>&1 | tail -1
echo "OK: $APP"
