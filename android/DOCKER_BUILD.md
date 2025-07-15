# 🐳 Docker-based Android Export for LectoEmoción

This directory contains a complete Docker-based Android build system that allows you to export your Godot project to Android APK without installing any development tools on your local machine.

## 🌟 Advantages

- ✅ **No local Java/Android SDK installation required**
- ✅ **Consistent build environment across different machines**
- ✅ **Version-controlled build configuration**
- ✅ **Isolated from your existing Java installations**
- ✅ **Easy team collaboration**
- ✅ **Reproducible builds**

## 📋 Prerequisites

Only **Docker** is required:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows/Mac
- Or Docker Engine for Linux

## 🚀 Quick Start

### 1. First Time Setup
```bash
# Build the Android export Docker image
make android-setup
```

### 2. Build APK
```bash
# Build Android APK
make android
```

Your APK will be created at: `android/output/lectoemocion.apk`

## 🔧 Available Commands

### Main Commands
```bash
make android         # Build Android APK (builds image if needed)
make android-setup   # Build Docker image only
make android-clean   # Clean all build artifacts and Docker images
make android-shell   # Open interactive shell in build container
```

### Helper Commands
```bash
make help           # Show all available commands
make dev-check      # Check development environment status
make firebase-setup # Show Firebase setup instructions
make quick-start    # Show quick start guide
```

## 🔥 Firebase Configuration

### 1. Get SHA-1 Fingerprint
The build process will output the SHA-1 fingerprint needed for Firebase:

```bash
make android
# Look for output like:
# 🔑 Debug keystore SHA-1 fingerprint:
#    SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

### 2. Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **lectoemocion-game**
3. Add Android app:
   - **Package name**: `com.lectoemocion.game`
   - **App nickname**: `LectoEmoción Android`
   - **SHA-1 certificate**: Use the fingerprint from step 1

### 3. Add Configuration File
1. Download `google-services.json` from Firebase
2. Place it at: `android/build/google-services.json`
3. Rebuild: `make android`

## 📱 Installing APK

### Method 1: Using ADB
```bash
# Enable Developer Options and USB Debugging on your device
# Connect device via USB
adb install android/output/lectoemocion.apk
```

### Method 2: Manual Installation
1. Copy `android/output/lectoemocion.apk` to your Android device
2. Enable "Install from Unknown Sources" in Settings
3. Tap the APK file to install

## 🛠️ Development Workflow

### Building and Testing
```bash
# 1. Make changes to your Godot project
# 2. Build new APK
make android

# 3. Install on device
adb install android/output/lectoemocion.apk

# 4. Test the app
```

### Debugging
```bash
# View device logs
adb logcat | grep -i godot

# Open interactive shell in build container
make android-shell

# Check development environment
make dev-check
```

## 📁 File Structure

```
android/
├── Dockerfile              # Main build environment
├── docker-compose.yml      # Alternative compose setup
├── export_android.sh       # Export script (runs inside container)
├── editor_settings.tres    # Godot editor settings for Android
├── build/                  # Place google-services.json here
├── output/                 # Generated APK files
├── README.md              # Manual setup guide (alternative)
├── DOCKER_BUILD.md        # This file
└── .gitignore             # Android-specific ignores
```

## 🔍 Troubleshooting

### Docker Issues
```bash
# Check Docker is running
docker --version
docker ps

# Rebuild image from scratch
make android-clean
make android-setup
```

### Build Issues
```bash
# Check project structure
make dev-check

# View build logs
make android-shell
# Then run: /opt/export_android.sh
```

### APK Issues
```bash
# Check APK was created
ls -la android/output/

# Verify APK is valid
adb install android/output/lectoemocion.apk
```

### Firebase Issues
1. Ensure `google-services.json` is in `android/build/`
2. Verify SHA-1 fingerprint is registered in Firebase Console
3. Check package name matches: `com.lectoemocion.game`

## 🏗️ Docker Image Details

The Docker image includes:
- **Ubuntu 22.04** base
- **OpenJDK 17** (Java Development Kit)
- **Android SDK** with API levels 21, 33
- **Godot 4.4** headless export engine
- **Build tools** and platform tools
- **Debug keystore** (auto-generated)

Image size: ~2.5GB (downloads once, caches locally)

## 🌐 Alternative: Docker Compose

You can also use Docker Compose:

```bash
# Build APK
cd android
docker-compose up android-build

# Interactive development
docker-compose up android-dev

# Get SHA-1 fingerprint only
docker-compose up android-fingerprint
```

## 🔒 Security Notes

- ✅ Debug keystore is included (safe for development)
- ⚠️ Never commit `google-services.json` with production keys
- ✅ All sensitive data is isolated in containers
- ✅ No modification of host system

## 🚀 Production Builds

For production releases, you'll need to:
1. Create a release keystore
2. Configure signing in the export script
3. Use Firebase production configuration
4. Build release APK instead of debug

## 📞 Support

If you encounter issues:
1. Check `make dev-check` output
2. Review container logs: `make android-shell`
3. Verify Docker installation and permissions
4. Ensure project structure is correct

## 🎯 Next Steps

1. **Test the build**: `make android`
2. **Configure Firebase**: Add `google-services.json`
3. **Test on device**: Install and verify all features work
4. **Set up CI/CD**: Use this system for automated builds
5. **iOS export**: Consider similar approach for iOS (requires macOS) 