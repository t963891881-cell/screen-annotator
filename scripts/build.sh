#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.1.1}"
APP_DIR="$ROOT_DIR/dist/ScreenAnnotator.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"
MODULE_CACHE_DIR="$ROOT_DIR/.build/module-cache"
ICON_FILE="$ROOT_DIR/assets/ScreenAnnotator.icns"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$MODULE_CACHE_DIR"

"$ROOT_DIR/scripts/generate_icon.py"

swiftc \
  -O \
  -module-cache-path "$MODULE_CACHE_DIR" \
  -framework Cocoa \
  -framework Carbon \
  "$ROOT_DIR/src/ScreenAnnotator.swift" \
  -o "$MACOS_DIR/ScreenAnnotator"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>ScreenAnnotator</string>
  <key>CFBundleIdentifier</key>
  <string>local.codex.screen-annotator</string>
  <key>CFBundleName</key>
  <string>Screen Annotator</string>
  <key>CFBundleDisplayName</key>
  <string>Screen Annotator</string>
  <key>CFBundleIconFile</key>
  <string>ScreenAnnotator</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>__VERSION__</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>12.0</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
PLIST

perl -0pi -e "s/__VERSION__/$VERSION/g" "$APP_DIR/Contents/Info.plist"

cp "$ICON_FILE" "$RESOURCES_DIR/ScreenAnnotator.icns"

echo "Built $APP_DIR"
