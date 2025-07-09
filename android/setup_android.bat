@echo off
echo Setting up Android development environment for LectoEmoción...
echo.

REM Check if Java is installed
echo Checking Java installation...
java -version 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install OpenJDK 17 from https://adoptium.net/
    echo.
    pause
    exit /b 1
)

REM Check if keytool is available
echo Checking keytool availability...
keytool -help >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: keytool is not available
    echo Please ensure Java SDK is properly installed
    echo.
    pause
    exit /b 1
)

REM Create debug keystore
echo.
echo Creating debug keystore...
if not exist debug.keystore (
    keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
    if %errorlevel% equ 0 (
        echo Debug keystore created successfully!
    ) else (
        echo ERROR: Failed to create debug keystore
        pause
        exit /b 1
    )
) else (
    echo Debug keystore already exists, skipping creation.
)

REM Get SHA-1 fingerprint
echo.
echo Getting SHA-1 fingerprint for Firebase setup...
echo.
echo =====================================
echo COPY THIS SHA-1 FINGERPRINT TO FIREBASE:
echo =====================================
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android | findstr SHA1
echo =====================================
echo.

echo Setup complete! Next steps:
echo 1. Copy the SHA-1 fingerprint above
echo 2. Go to Firebase Console: https://console.firebase.google.com/
echo 3. Add Android app with package name: com.lectoemocion.game
echo 4. Download google-services.json and place it in android/build/
echo 5. Install Android Studio and configure Godot paths
echo.
pause 