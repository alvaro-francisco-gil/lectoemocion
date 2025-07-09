# Android Export Setup for LectoEmoción

## Prerequisites

### 1. Install OpenJDK 17
Download and install OpenJDK 17 from: https://adoptium.net/
- Choose the HotSpot JVM variant
- Add to PATH during installation

### 2. Install Android Studio or Android SDK
**Option A: Android Studio (Recommended)**
- Download from: https://developer.android.com/studio
- Install with default settings
- Android SDK will be installed automatically

**Option B: Android SDK Only**
- Download Command Line Tools from: https://developer.android.com/studio/command-line
- Extract to a folder (e.g., `C:\Android\sdk`)
- Set `ANDROID_HOME` environment variable to SDK path

### 3. Install Android SDK Components
Open Android Studio > SDK Manager and install:
- Android SDK Platform-Tools
- Android SDK Build-Tools (latest)
- Android API 33 (Android 13) - Target for this project
- Android API 34 (Android 14) - Latest

## Godot Configuration

### 1. Set up Godot Editor Settings
1. Open Godot Editor
2. Go to **Editor → Editor Settings**
3. Navigate to **Export → Android**
4. Set the following paths:
   - **Java SDK Path**: Path to your OpenJDK 17 installation
     - Windows: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x.x-hotspot`
   - **Android SDK Path**: Path to your Android SDK
     - Windows (Android Studio): `C:\Users\[USERNAME]\AppData\Local\Android\Sdk`
     - Windows (Manual): Where you extracted the SDK

### 2. Download Android Export Templates
1. In Godot, go to **Project → Export**
2. Click **Manage Export Templates**
3. Download templates for your Godot version (4.4)
4. Close the template manager

### 3. Create Android Export Preset
1. In **Project → Export**, click **Add**
2. Select **Android**
3. Configure the preset:
   - **Export Path**: `android/lectoemocion.apk`
   - **Package Name**: `com.lectoemocion.game`
   - **Version Name**: `1.0`
   - **Version Code**: `1`
   - **Min SDK**: `21` (Android 5.0)
   - **Target SDK**: `33` (Android 13)

## Firebase Configuration

### 1. Create google-services.json
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **lectoemocion-game**
3. Go to **Project Settings → General**
4. Under **Your apps**, add an Android app:
   - **Android package name**: `com.lectoemocion.game`
   - **App nickname**: `LectoEmoción Android`
   - **Debug signing certificate SHA-1**: (Generate debug keystore first)

### 2. Generate Debug Keystore
Run this command in terminal:
```bash
keytool -genkey -v -keystore android/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
```

### 3. Get SHA-1 Fingerprint
```bash
keytool -list -v -keystore android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 4. Download and Place google-services.json
1. After adding the Android app in Firebase, download `google-services.json`
2. Place it in: `android/build/google-services.json`

## Export Process

### 1. Build APK
1. In Godot, go to **Project → Export**
2. Select your Android preset
3. Click **Export Project**
4. Choose location and filename
5. Click **Save**

### 2. Install APK
- **Via ADB**: `adb install path/to/your.apk`
- **Via USB**: Copy APK to device and install
- **Via Android Studio**: Use the APK Analyzer

## Testing Firebase Features

### Android-specific Testing
1. Install the APK on a physical Android device
2. Test user registration and login
3. Verify Google Sign-in works
4. Check network permissions for Firebase API calls

### Debug Console
Use `adb logcat` to view device logs:
```bash
adb logcat | grep -i godot
```

## Troubleshooting

### Common Issues
1. **Build fails**: Check Java SDK and Android SDK paths
2. **Firebase not working**: Verify google-services.json placement
3. **Google Sign-in fails**: Check SHA-1 fingerprint registration
4. **Network issues**: Ensure INTERNET permission is enabled

### Network Permissions
The project already uses Firebase REST API, so ensure these permissions are in the Android manifest:
- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`

## Production Release

### 1. Create Release Keystore
```bash
keytool -genkey -v -keystore android/release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configure Release Build
In Godot Export preset:
- Set **Release** mode
- Configure keystore settings
- Enable **Code Signing**

### 3. Generate App Bundle
- Export as `.aab` for Google Play Store
- Use APK for other distribution methods

## Next Steps
1. Complete Android setup
2. Test thoroughly on real devices
3. Set up iOS export (requires macOS)
4. Configure CI/CD for automated builds 