#!/usr/bin/env bash
# Capture screenshots from a connected Android device/emulator.
# Usage: ./scripts/screenshots.sh            → interactive, 8s countdown per shot
#        ./scripts/screenshots.sh 01-feed 3  → single shot, custom name + delay
set -euo pipefail

OUT_DIR="assets/screenshots"
DEVICE="${1:-}"
DELAY="${2:-8}"

mkdir -p "$OUT_DIR"

capture() {
  local name="$1" delay="$2"
  echo "📸 Capturing '$name' in ${delay}s — navigate the app now…"
  for ((i = delay; i > 0; i--)); do
    echo "  $i…"
    sleep 1
  done
  adb exec-out screencap -p > "$OUT_DIR/$name.png"
  echo "  ✓ saved $OUT_DIR/$name.png"
}

if [[ -n "$DEVICE" && "$DEVICE" != "--"* ]]; then
  capture "$DEVICE" "$DELAY"
  exit 0
fi

if ! adb get-state &>/dev/null; then
  echo "No Android device found (adb)." >&2
  exit 1
fi

echo "Interactive screenshot session — Ctrl+C to stop early."
capture "01-login" 6
capture "02-feed" 10
capture "03-stories-viewer" 10
capture "04-search" 8
capture "05-explore" 8
capture "06-reels" 10
capture "07-activity" 8
capture "08-profile" 8
capture "09-post-detail" 8
capture "10-chat" 8

echo "Done. Review $OUT_DIR/ and delete the ones you don't want."
