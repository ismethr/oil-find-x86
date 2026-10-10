#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# x86 fork: the upstream self-signed identity, update manifest and site downloads do not apply.
# Builds are ad-hoc signed unless OILFIND_SIGN_IDENTITY is set.
"$PROJECT_DIR/scripts/build-app.sh"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
ARCHIVE_PATH="$PROJECT_DIR/build/Oil-Find-x86.zip"
STAGING="$PROJECT_DIR/build/package"
rm -rf "$STAGING" "$ARCHIVE_PATH"
mkdir -p "$STAGING"
ditto "build/Oil Find.app" "$STAGING/Oil Find.app"
cp LICENSE "$STAGING/LICENSE"
ditto -c -k --sequesterRsrc "$STAGING" "$ARCHIVE_PATH"
rm -rf "$STAGING"

printf 'Version: %s\n' "$VERSION"
printf 'File: %s\n' "$ARCHIVE_PATH"
printf 'Size: %s bytes\n' "$(stat -f '%z' "$ARCHIVE_PATH")"
printf 'SHA-256: %s\n' "$(shasum -a 256 "$ARCHIVE_PATH" | cut -d ' ' -f 1)"
