#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.1.0}"
APP_PATH="$ROOT_DIR/dist/ScreenAnnotator.app"
STAGING_DIR="$ROOT_DIR/dist/dmg-staging-$VERSION-$$"
DMG_PATH="$ROOT_DIR/dist/ScreenAnnotator-$VERSION.dmg"

"$ROOT_DIR/scripts/build.sh" "$VERSION"

mkdir -p "$STAGING_DIR"
ditto "$APP_PATH" "$STAGING_DIR/ScreenAnnotator.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "Screen Annotator" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Built $DMG_PATH"
