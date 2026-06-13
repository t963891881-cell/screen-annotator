#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$ROOT_DIR/dist/ScreenAnnotator.app" ]; then
  "$ROOT_DIR/scripts/build.sh"
fi

open "$ROOT_DIR/dist/ScreenAnnotator.app"
