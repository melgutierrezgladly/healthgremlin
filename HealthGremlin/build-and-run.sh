#!/bin/bash
# Build Health Gremlin and package it as a proper macOS .app bundle
# A bare executable won't show a menu bar icon — macOS needs
# the .app bundle structure to treat it as a real application.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔨 Building Health Gremlin..."
swift build 2>&1

echo "📦 Creating .app bundle..."

APP_DIR="$SCRIPT_DIR/.build/HealthGremlin.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean previous bundle
rm -rf "$APP_DIR"

# Create bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy the built executable
cp .build/arm64-apple-macosx/debug/HealthGremlin "$MACOS_DIR/HealthGremlin"

# Copy the resource bundle (SPM puts compiled resources here)
if [ -d ".build/arm64-apple-macosx/debug/HealthGremlin_HealthGremlin.bundle" ]; then
    cp -R ".build/arm64-apple-macosx/debug/HealthGremlin_HealthGremlin.bundle" "$RESOURCES_DIR/"
fi

# Copy the gremlin icon directly into Resources for reliable loading
# The @2x version looks crisp on retina displays (most modern Macs)
cp "HealthGremlin/Resources/Assets.xcassets/MenuBarIcon.imageset/icon_18x18@2x.png" "$RESOURCES_DIR/gremlin-icon.png"

# Create Info.plist — tells macOS this is a menu bar-only app
cat > "$CONTENTS_DIR/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>HealthGremlin</string>
    <key>CFBundleIdentifier</key>
    <string>com.healthgremlin.app</string>
    <key>CFBundleName</key>
    <string>Health Gremlin</string>
    <key>CFBundleDisplayName</key>
    <string>Health Gremlin</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "✅ Build complete!"
echo "📍 App location: $APP_DIR"
echo ""
echo "🚀 Launching Health Gremlin..."

# Kill any existing instance
pkill -f "HealthGremlin.app/Contents/MacOS/HealthGremlin" 2>/dev/null || true

# Launch the .app bundle
open "$APP_DIR"

echo "👀 Check your menu bar for the gremlin icon!"
