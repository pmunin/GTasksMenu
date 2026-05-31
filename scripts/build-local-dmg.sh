#!/usr/bin/env bash
# Builds an ad-hoc-signed TaskMenu.app and packages it into a DMG for personal,
# non-notarized installs on your own Macs. No Apple Developer account required.
#
# On the receiving Mac, after copying the app to /Applications, clear quarantine:
#   xattr -dr com.apple.quarantine /Applications/TaskMenu.app
set -euo pipefail

cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

scheme="TaskMenu"
configuration="Debug"
derived="build"
app_path="$derived/Build/Products/${configuration}/TaskMenu.app"
output_dir="dist"

xcodegen generate

xcodebuild build \
  -project TaskMenu.xcodeproj \
  -scheme "$scheme" \
  -configuration "$configuration" \
  -derivedDataPath "$derived"

version="$(
  xcodebuild -project TaskMenu.xcodeproj \
    -scheme "$scheme" \
    -configuration "$configuration" \
    -showBuildSettings 2>/dev/null |
    awk -F'= ' '/ MARKETING_VERSION = / { print $2; exit }'
)"

./scripts/make_dmg.sh \
  --app "$app_path" \
  --version "$version" \
  --output-dir "$output_dir"

echo "DMG ready: $output_dir/TaskMenu-${version}.dmg"
