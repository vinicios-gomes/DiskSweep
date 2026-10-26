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
if [[ -n "${VERSION:-}" ]]; then   # ex.: VERSION=1.2.0 (vem da tag vX.Y.Z no release)
  plutil -replace CFBundleShortVersionString -string "$VERSION" "$APP/Contents/Info.plist"
  plutil -replace CFBundleVersion -string "${BUILD_NUMBER:-1}" "$APP/Contents/Info.plist"
fi
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp -R shell "$APP/Contents/Resources/shell"
# CODESIGN_IDENTITY="Developer ID Application: ..." para assinar de verdade; padrão = assinatura ad hoc
codesign --force --sign "${CODESIGN_IDENTITY:--}" "$APP" 2>&1 | tail -1
echo "OK: $APP"
