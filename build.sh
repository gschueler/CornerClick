#!/bin/zsh
# Builds CornerClick.app with only the Xcode Command Line Tools (no Xcode project needed).
#   ./build.sh              # release build into build/CornerClick.app
#   ./build.sh --install    # also copy to /Applications and relaunch
#   ./build.sh --universal  # arm64 + x86_64
#   SIGN_IDENTITY="Developer ID Application: …" ./build.sh   # sign with a real identity
set -euo pipefail
cd "${0:A:h}"

VERSION="1.0"
BUILD="$(git rev-list --count HEAD 2>/dev/null || echo 1)"
APP="build/CornerClick.app"
MIN_OS="14.0"
ARCHS=(arm64)
INSTALL=0
for arg in "$@"; do
  case $arg in
    --install) INSTALL=1 ;;
    --universal) ARCHS=(arm64 x86_64) ;;
    *) echo "unknown option $arg"; exit 1 ;;
  esac
done

# Pick an SDK. With only the Command Line Tools, newer SDKs declare SwiftUI's @State as a
# macro whose compiler plugin ships with Xcode alone, so fall back to the newest SDK without it.
pick_sdk() {
  local default="$(xcrun --sdk macosx --show-sdk-path)"
  local plugins="$(dirname "$(xcrun --find swiftc)")/../lib/swift/host/plugins"
  if [[ -e "$plugins/libSwiftUIMacros.dylib" ]] || ! grep -q "public macro State()" \
      "$default/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-macos.swiftinterface" 2>/dev/null; then
    echo "$default"; return
  fi
  for sdk in $(ls -d "$(dirname "$default")"/MacOSX[0-9]*.sdk | sort -V -r); do
    if ! grep -q "public macro State()" \
        "$sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-macos.swiftinterface" 2>/dev/null; then
      echo "$sdk"; return
    fi
  done
  echo "$default"
}
SDK="${SDK:-$(pick_sdk)}"
echo "→ Using SDK $(basename "$SDK")"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/obj

BINS=()
for arch in $ARCHS; do
  echo "→ Compiling ($arch)"
  xcrun swiftc -O -wmo -swift-version 5 \
    -sdk "$SDK" -target "$arch-apple-macos$MIN_OS" \
    -module-name CornerClick \
    Sources/*.swift \
    -o "build/obj/CornerClick-$arch"
  BINS+=("build/obj/CornerClick-$arch")
done
lipo -create $BINS -output "$APP/Contents/MacOS/CornerClick"

sed -e "s/__VERSION__/$VERSION/" -e "s/__BUILD__/$BUILD/" Resources/Info.plist > "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"

if [[ ! -f build/AppIcon.icns || Resources/MakeIcon.swift -nt build/AppIcon.icns ]]; then
  echo "→ Rendering app icon"
  rm -rf build/AppIcon.iconset && mkdir -p build/AppIcon.iconset
  xcrun swiftc -O -sdk "$SDK" Resources/MakeIcon.swift -o build/obj/makeicon
  build/obj/makeicon build/AppIcon.iconset
  iconutil -c icns build/AppIcon.iconset -o build/AppIcon.icns
fi
cp build/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

echo "→ Signing"
codesign --force --sign "${SIGN_IDENTITY:--}" --identifier io.github.cornerclick.CornerClick \
  ${SIGN_IDENTITY:+--options runtime --entitlements Resources/CornerClick.entitlements --timestamp} "$APP"
codesign --verify --strict "$APP"
echo "✓ Built $APP ($VERSION build $BUILD)"

if (( INSTALL )); then
  pkill -x CornerClick 2>/dev/null && sleep 0.5 || true
  rm -rf /Applications/CornerClick.app
  ditto "$APP" /Applications/CornerClick.app
  open /Applications/CornerClick.app
  echo "✓ Installed to /Applications and launched"
fi
