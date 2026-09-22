#!/bin/bash
#
# build-and-install.sh
#
# Builds this branch and installs it as /Applications/Loop.app.
#
# Usage:
#   bash tools/build-and-install.sh                  build, install, start
#   bash tools/build-and-install.sh --apply-config   also apply tools/apply-loop-config.sh
#   bash tools/build-and-install.sh --build-only     build, do not touch /Applications
#
# Requirements: full Xcode (not only the Command Line Tools), and once per Mac:
#   sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept
#   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -runFirstLaunch
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODE="/Applications/Xcode.app"
DEV_DIR="$XCODE/Contents/Developer"
APP_DEST="/Applications/Loop.app"
ARCH="$(uname -m)"
APPLY_CONFIG=0
BUILD_ONLY=0

for arg in "$@"; do
  case "$arg" in
    --apply-config) APPLY_CONFIG=1 ;;
    --build-only)   BUILD_ONLY=1 ;;
    -h|--help)      sed -n "3,15p" "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

echo "==> Loop build"
echo "    repo:   $REPO"
echo "    branch: $(git -C "$REPO" branch --show-current)"

# --- 1. Check the toolchain ----------------------------------------------------

if [ ! -d "$XCODE" ]; then
  echo "!!! $XCODE not found. Install Xcode from the App Store." >&2
  exit 1
fi

# --- 2. Build -------------------------------------------------------------------

LOG="$(mktemp -t loop-build)"
echo "    building ($ARCH, log: $LOG)"

if ! DEVELOPER_DIR="$DEV_DIR" xcodebuild \
  -project "$REPO/Loop.xcodeproj" \
  -scheme Loop \
  -configuration Debug \
  -destination "platform=macOS,arch=$ARCH" \
  -skipMacroValidation \
  build CODE_SIGNING_ALLOWED=NO > "$LOG" 2>&1; then
  echo "!!! Build failed. Last lines:" >&2
  tail -20 "$LOG" >&2
  if grep -q "license agreements" "$LOG"; then
    echo "    Run: sudo $DEV_DIR/usr/bin/xcodebuild -license accept" >&2
  fi
  if grep -q "runFirstLaunch" "$LOG"; then
    echo "    Run: DEVELOPER_DIR=$DEV_DIR xcodebuild -runFirstLaunch" >&2
  fi
  exit 1
fi

APP_SRC="$(find "$HOME/Library/Developer/Xcode/DerivedData"/Loop-*/Build/Products/Debug -maxdepth 1 -name "Loop.app" -print 2>/dev/null | head -1)"

if [ -z "$APP_SRC" ]; then
  echo "!!! Build succeeded, but Loop.app was not found in DerivedData." >&2
  exit 1
fi

echo "    built: $APP_SRC"

if [ "$BUILD_ONLY" = "1" ]; then
  echo "==> Done (build only)."
  exit 0
fi

# --- 3. Quit the running copy -----------------------------------------------------

if pgrep -f "Loop.app/Contents/MacOS/Loop" > /dev/null; then
  osascript -e "tell application \"Loop\" to quit" 2>/dev/null || true
  for _ in $(seq 1 20); do
    pgrep -f "Loop.app/Contents/MacOS/Loop" > /dev/null || break
    sleep 0.5
  done
  if pgrep -f "Loop.app/Contents/MacOS/Loop" > /dev/null; then
    echo "!!! Loop did not quit. Quit it yourself, then run this script again." >&2
    exit 1
  fi
  echo "    Loop quit"
fi

# --- 4. Install --------------------------------------------------------------------

if [ -d "$APP_DEST" ]; then
  PREVIOUS="$HOME/Downloads/Loop-previous-$(date +%Y%m%d-%H%M%S).app"
  mv "$APP_DEST" "$PREVIOUS"
  echo "    previous app: $PREVIOUS"
fi

cp -R "$APP_SRC" "$APP_DEST"
xattr -cr "$APP_DEST" || true
codesign --force --deep --sign - "$APP_DEST" 2>/dev/null
echo "    installed: $APP_DEST (ad-hoc signature)"

# --- 5. Configuration ----------------------------------------------------------------

if [ "$APPLY_CONFIG" = "1" ]; then
  bash "$REPO/tools/apply-loop-config.sh"
  exit 0
fi

if defaults read com.MrKai77.Loop radialMenuActions > /dev/null 2>&1; then
  echo "    note: this Mac already holds Loop preferences, so the built-in defaults"
  echo "          do not apply. To overwrite them, run:"
  echo "          bash $REPO/tools/apply-loop-config.sh"
fi

# --- 6. Start ---------------------------------------------------------------------------

open -a "$APP_DEST"
echo "    Loop started"
echo "==> Done."
echo "    If the trigger keys do nothing, grant Accessibility again:"
echo "    System Settings > Privacy & Security > Accessibility (remove the old Loop entry first)."
