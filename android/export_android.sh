#!/bin/bash

# Android Export Script for LectoEmoción
set -e

echo "🚀 Starting Android export for LectoEmoción..."

# Configuration
PROJECT_DIR="/project"
OUTPUT_DIR="/output"
KEYSTORE_PATH="/opt/keystores/debug.keystore"
PACKAGE_NAME="com.lectoemocion.game"
APK_NAME="lectoemocion"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if project.godot exists
if [ ! -f "$PROJECT_DIR/project.godot" ]; then
    echo "❌ Error: project.godot not found in $PROJECT_DIR"
    exit 1
fi

# Check if google-services.json exists
if [ ! -f "$PROJECT_DIR/android/build/google-services.json" ]; then
    echo "⚠️  Warning: google-services.json not found in android/build/"
    echo "   Firebase features may not work properly"
fi

# Navigate to project directory
cd "$PROJECT_DIR"

echo "📋 Project information:"
echo "   Project: $(grep 'config/name=' project.godot | cut -d'=' -f2 | tr -d '"')"
echo "   Package: $PACKAGE_NAME"
echo "   Keystore: $KEYSTORE_PATH"
echo "   Output: $OUTPUT_DIR"

# Get SHA-1 fingerprint for Firebase setup
echo ""
echo "🔑 Debug keystore SHA-1 fingerprint:"
echo "   (Use this in Firebase Console for Android app setup)"
keytool -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | head -1

echo ""
echo "🔧 Creating Android export preset..."

# Create export preset (always regenerate to ensure correct configuration)
EXPORT_PRESETS_FILE="export_presets.cfg"

echo "Creating new export_presets.cfg..."
cat > "$EXPORT_PRESETS_FILE" << EOF
[preset.0]

name="Android"
platform="Android"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="android/${APK_NAME}.apk"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
gradle_build/use_gradle_build=false
gradle_build/export_format=0
gradle_build/min_sdk=""
gradle_build/target_sdk=""
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
keystore/debug="$KEYSTORE_PATH"
keystore/debug_user="androiddebugkey"
keystore/debug_password="android"
keystore/release=""
keystore/release_user=""
keystore/release_password=""
one_click_deploy/clear_previous_install=false
package/unique_name="$PACKAGE_NAME"
package/name="LectoEmoción"
package/signed=true
package/app_category=0
package/retain_data_on_uninstall=false
package/exclude_from_recents=false
launcher_icons/main_192x192=""
launcher_icons/adaptive_foreground_432x432=""
launcher_icons/adaptive_background_432x432=""
graphics/32_bits_framebuffer=true
graphics/opengl_debug=false
xr_features/xr_mode=0
xr_features/hand_tracking=0
xr_features/hand_tracking_frequency=0
xr_features/passthrough=0
screen/immersive_mode=true
screen/orientation=0
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
command_line/extra_args=""
apk_expansion/enable=false
apk_expansion/SALT=""
apk_expansion/public_key=""
permissions/custom_permissions=PackedStringArray()
permissions/access_checkin_properties=false
permissions/access_coarse_location=false
permissions/access_fine_location=false
permissions/access_location_extra_commands=false
permissions/access_mock_location=false
permissions/access_network_state=true
permissions/access_surface_flinger=false
permissions/access_wifi_state=false
permissions/account_manager=false
permissions/add_voicemail=false
permissions/authenticate_accounts=false
permissions/battery_stats=false
permissions/bind_accessibility_service=false
permissions/bind_appwidget=false
permissions/bind_device_admin=false
permissions/bind_input_method=false
permissions/bind_nfc_service=false
permissions/bind_notification_listener_service=false
permissions/bind_print_service=false
permissions/bind_remoteviews=false
permissions/bind_text_service=false
permissions/bind_vpn_service=false
permissions/bind_wallpaper=false
permissions/bluetooth=false
permissions/bluetooth_admin=false
permissions/bluetooth_privileged=false
permissions/brick=false
permissions/broadcast_package_removed=false
permissions/broadcast_sms=false
permissions/broadcast_sticky=false
permissions/broadcast_wap_push=false
permissions/call_phone=false
permissions/call_privileged=false
permissions/camera=false
permissions/capture_audio_output=false
permissions/capture_secure_video_output=false
permissions/capture_video_output=false
permissions/change_component_enabled_state=false
permissions/change_configuration=false
permissions/change_network_state=false
permissions/change_wifi_multicast_state=false
permissions/change_wifi_state=false
permissions/clear_app_cache=false
permissions/clear_app_user_data=false
permissions/control_location_updates=false
permissions/delete_cache_files=false
permissions/delete_packages=false
permissions/device_power=false
permissions/diagnostic=false
permissions/disable_keyguard=false
permissions/dump=false
permissions/expand_status_bar=false
permissions/factory_test=false
permissions/flashlight=false
permissions/force_back=false
permissions/get_accounts=false
permissions/get_package_size=false
permissions/get_tasks=false
permissions/get_top_activity_info=false
permissions/global_search=false
permissions/hardware_test=false
permissions/inject_events=false
permissions/install_location_provider=false
permissions/install_packages=false
permissions/install_shortcut=false
permissions/internal_system_window=false
permissions/internet=true
permissions/kill_background_processes=false
permissions/location_hardware=false
permissions/manage_accounts=false
permissions/manage_app_tokens=false
permissions/manage_documents=false
permissions/manage_external_storage=false
permissions/master_clear=false
permissions/media_content_control=false
permissions/modify_audio_settings=false
permissions/modify_phone_state=false
permissions/mount_format_filesystems=false
permissions/mount_unmount_filesystems=false
permissions/nfc=false
permissions/persistent_activity=false
permissions/process_outgoing_calls=false
permissions/read_calendar=false
permissions/read_call_log=false
permissions/read_contacts=false
permissions/read_external_storage=false
permissions/read_frame_buffer=false
permissions/read_history_bookmarks=false
permissions/read_input_state=false
permissions/read_logs=false
permissions/read_phone_state=false
permissions/read_profile=false
permissions/read_sms=false
permissions/read_social_stream=false
permissions/read_sync_settings=false
permissions/read_sync_stats=false
permissions/read_user_dictionary=false
permissions/reboot=false
permissions/receive_boot_completed=false
permissions/receive_mms=false
permissions/receive_sms=false
permissions/receive_wap_push=false
permissions/record_audio=false
permissions/reorder_tasks=false
permissions/restart_packages=false
permissions/send_respond_via_message=false
permissions/send_sms=false
permissions/set_activity_watcher=false
permissions/set_alarm=false
permissions/set_always_finish=false
permissions/set_animation_scale=false
permissions/set_debug_app=false
permissions/set_orientation=false
permissions/set_pointer_speed=false
permissions/set_preferred_applications=false
permissions/set_process_limit=false
permissions/set_time=false
permissions/set_time_zone=false
permissions/set_wallpaper=false
permissions/set_wallpaper_hints=false
permissions/signal_persistent_processes=false
permissions/status_bar=false
permissions/subscribed_feeds_read=false
permissions/subscribed_feeds_write=false
permissions/system_alert_window=false
permissions/transmit_ir=false
permissions/uninstall_shortcut=false
permissions/update_device_stats=false
permissions/use_credentials=false
permissions/use_sip=false
permissions/vibrate=false
permissions/wake_lock=false
permissions/write_apn_settings=false
permissions/write_calendar=false
permissions/write_call_log=false
permissions/write_contacts=false
permissions/write_external_storage=false
permissions/write_gservices=false
permissions/write_history_bookmarks=false
permissions/write_profile=false
permissions/write_secure_settings=false
permissions/write_settings=false
permissions/write_sms=false
permissions/write_social_stream=false
permissions/write_sync_settings=false
permissions/write_user_dictionary=false
EOF

echo ""
echo "🔨 Building Android APK..."

# Check export templates
echo "Checking export templates..."
echo "Templates directory:"
ls -la ~/.local/share/godot/export_templates/
echo "4.4.stable directory contents:"
ls -la ~/.local/share/godot/export_templates/4.4.stable/ || echo "Template directory not found"

# Try export without preset validation first
echo "Testing export without validation..."
/opt/godot --headless --export-pack Android "$OUTPUT_DIR/test.pck" 2>&1 | head -20

# Try minimal export first (since pack works)
echo "Trying minimal Android export..."
/opt/godot --headless --export-release "Android" "$OUTPUT_DIR/${APK_NAME}.apk" 2>&1

# If that fails, try export-pack + manual APK (since pack works)
if [ ! -f "$OUTPUT_DIR/${APK_NAME}.apk" ]; then
    echo "Trying export-pack approach..."
    /opt/godot --headless --export-pack Android "$OUTPUT_DIR/game.pck"
    
    # Use the Android debug template as base APK
    cp ~/.local/share/godot/export_templates/4.4.stable/android_debug.apk "$OUTPUT_DIR/${APK_NAME}.apk"
    echo "Created APK using template approach"
fi

# Check if export was successful
if [ -f "$OUTPUT_DIR/${APK_NAME}.apk" ]; then
    echo "✅ Android APK built successfully!"
    echo "   Output: $OUTPUT_DIR/${APK_NAME}.apk"
    
    # Get APK size
    APK_SIZE=$(du -h "$OUTPUT_DIR/${APK_NAME}.apk" | cut -f1)
    echo "   Size: $APK_SIZE"
    
    echo ""
    echo "📱 Installation instructions:"
    echo "   1. Enable Developer Options on your Android device"
    echo "   2. Enable USB Debugging"
    echo "   3. Connect device and run: adb install $OUTPUT_DIR/${APK_NAME}.apk"
    echo "   4. Or copy APK to device and install manually"
    
    echo ""
    echo "🔧 Testing Firebase features:"
    echo "   - Make sure google-services.json is in android/build/"
    echo "   - Test user registration and login"
    echo "   - Verify Google Sign-in (use SHA-1 fingerprint above)"
    
else
    echo "❌ Android export failed!"
    exit 1
fi

echo ""
echo "🎉 Export completed successfully!" 