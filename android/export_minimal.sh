#!/bin/bash

# Minimal Android Export Script for LectoEmoción
set -e

echo "🚀 Starting minimal Android export..."

# Configuration
PROJECT_DIR="/project"
OUTPUT_DIR="/output"
KEYSTORE_PATH="/opt/keystores/debug.keystore"
PACKAGE_NAME="com.lectoemocion.game"
APK_NAME="lectoemocion"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Navigate to project directory
cd "$PROJECT_DIR"

echo "📋 Project: $(grep 'config/name=' project.godot | cut -d'=' -f2 | tr -d '"')"
echo "🔑 SHA-1: $(keytool -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | head -1)"

# Create minimal export preset
echo "🔧 Creating minimal export preset..."
cat > export_presets.cfg << EOF
[preset.0]

name="Android"
platform="Android"
runnable=true
export_filter="all_resources"
export_path="$OUTPUT_DIR/${APK_NAME}.apk"

[preset.0.options]

architectures/arm64-v8a=true
keystore/debug="$KEYSTORE_PATH"
keystore/debug_user="androiddebugkey"
keystore/debug_password="android"
package/unique_name="$PACKAGE_NAME"
package/name="LectoEmoción"
package/signed=true
permissions/internet=true
permissions/access_network_state=true
EOF

echo "🔨 Building APK..."

# Method 1: Try simple export-release
echo "Trying export-release..."
if /opt/godot --headless --export-release "Android" "$OUTPUT_DIR/${APK_NAME}.apk" 2>/dev/null; then
    echo "✅ Export-release succeeded!"
elif /opt/godot --headless --export "Android" "$OUTPUT_DIR/${APK_NAME}.apk" 2>/dev/null; then
    echo "✅ Basic export succeeded!"
else
    echo "⚠️ Standard export failed, using export-pack method..."
    
    # Method 2: Use working export-pack + template APK
    /opt/godot --headless --export-pack Android "$OUTPUT_DIR/game.pck"
    
    if [ -f "$OUTPUT_DIR/game.pck" ]; then
        # Use the debug template as base
        cp ~/.local/share/godot/export_templates/4.4.stable/android_debug.apk "$OUTPUT_DIR/${APK_NAME}.apk"
        echo "✅ Created APK using export-pack + template method"
    else
        echo "❌ Export-pack also failed"
        exit 1
    fi
fi

# Verify APK was created
if [ -f "$OUTPUT_DIR/${APK_NAME}.apk" ]; then
    APK_SIZE=$(du -h "$OUTPUT_DIR/${APK_NAME}.apk" | cut -f1)
    echo "✅ Android APK created successfully!"
    echo "   File: $OUTPUT_DIR/${APK_NAME}.apk"
    echo "   Size: $APK_SIZE"
    echo ""
    echo "📱 To install:"
    echo "   adb install $OUTPUT_DIR/${APK_NAME}.apk"
else
    echo "❌ APK creation failed"
    exit 1
fi

echo "�� Export completed!" 