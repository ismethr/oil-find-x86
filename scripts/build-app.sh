#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"
CONFIGURATION=release
APP_PATH="$PROJECT_DIR/build/Oil Find.app"
case "${1:-}" in
    '') [[ $# -eq 0 ]] || exit 2 ;;
    --debug) [[ $# -eq 1 ]] || exit 2; CONFIGURATION=debug; APP_PATH="$PROJECT_DIR/build/debug/Oil Find.app" ;;
    *) printf '%s\n' 'Usage: scripts/build-app.sh [--debug]' >&2; exit 2 ;;
esac
# x86 fork: always produce an Intel binary, whatever the host architecture.
swift build -c "$CONFIGURATION" --arch x86_64
BINARY_DIR="$(swift build -c "$CONFIGURATION" --arch x86_64 --show-bin-path)"
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
cp "$BINARY_DIR/OilFind" "$APP_PATH/Contents/MacOS/OilFind"
if [[ "$CONFIGURATION" == release ]]; then
    # Release bundles omit debug symbols containing local source paths.
    strip -S "$APP_PATH/Contents/MacOS/OilFind"
fi
cp "Resources/Info.plist" "$APP_PATH/Contents/Info.plist"
# MIT requires the copyright and permission notice in every copy, binaries included.
cp LICENSE "$APP_PATH/Contents/Resources/LICENSE"
if [[ -f "Resources/AppIcon.icns" ]]; then
    cp "Resources/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
fi
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' Resources/Info.plist)"
SELF_SIGNED="Oil Find Self-Signed"
if [[ -n "${OILFIND_SIGN_IDENTITY:-}" ]]; then
    codesign --force --sign "$OILFIND_SIGN_IDENTITY" --identifier "$BUNDLE_ID" --options runtime --timestamp "$APP_PATH"
elif security find-identity -v -p codesigning | grep -q "\"$SELF_SIGNED\""; then
    # Stable identity: macOS keeps Full Disk Access across updates. See scripts/create-signing-cert.sh.
    codesign --force --sign "$SELF_SIGNED" --identifier "$BUNDLE_ID" "$APP_PATH"
else
    codesign --force --sign - --identifier "$BUNDLE_ID" "$APP_PATH"
fi
printf '%s\n' "$APP_PATH"
