# LectoEmoción Build System
# 
# Commands:
#   make android       - Build Android APK using Docker
#   make android-setup - Build Docker image only
#   make android-clean - Clean Android build artifacts
#   make help          - Show this help

.PHONY: help android android-setup android-clean android-shell

# Default target
help:
	@echo "🎮 LectoEmoción Build System"
	@echo ""
	@echo "Available commands:"
	@echo "  make android       - Build Android APK using Docker"
	@echo "  make android-setup - Build Docker image only"
	@echo "  make android-clean - Clean Android build artifacts"
	@echo "  make android-shell - Open shell in Android build container"
	@echo "  make help          - Show this help"
	@echo ""
	@echo "Requirements:"
	@echo "  - Docker installed and running"
	@echo "  - google-services.json in android/build/ (optional)"
	@echo ""
	@echo "First time setup:"
	@echo "  1. Run 'make android-setup' to build the Docker image"
	@echo "  2. Add google-services.json to android/build/"
	@echo "  3. Run 'make android' to build APK"

# Build Android APK
android: android-setup
	@echo "🚀 Building Android APK for LectoEmoción..."
	@mkdir -p android/output
	@docker run --rm \
		-v "$(CURDIR):/project" \
		-v "$(CURDIR)/android/output:/output" \
		lectoemocion-android:latest
	@echo "✅ APK built! Check android/output/lectoemocion.apk"

# Build Docker image for Android export
android-setup:
	@echo "🔧 Building Android export Docker image..."
	@docker build -t lectoemocion-android:latest android/
	@echo "✅ Docker image built successfully!"

# Clean Android build artifacts
android-clean:
	@echo "🧹 Cleaning Android build artifacts..."
	@rm -rf android/output
	@docker rmi lectoemocion-android:latest 2>/dev/null || true
	@rm -f export_presets.cfg
	@echo "✅ Cleanup completed!"

# Open shell in Android build container (for debugging)
android-shell: android-setup
	@echo "🐚 Opening shell in Android build container..."
	@docker run --rm -it \
		-v "$(CURDIR):/project" \
		-v "$(CURDIR)/android/output:/output" \
		lectoemocion-android:latest \
		/bin/bash

# Firebase setup helper
firebase-setup:
	@echo "🔥 Firebase Setup Helper"
	@echo ""
	@echo "Steps to set up Firebase for Android:"
	@echo "1. Go to: https://console.firebase.google.com/"
	@echo "2. Select project: lectoemocion-game"
	@echo "3. Add Android app with package name: com.lectoemocion.game"
	@echo "4. Download google-services.json to android/build/"
	@echo "5. Use SHA-1 fingerprint from build output"
	@echo ""
	@echo "Run 'make android' to get the SHA-1 fingerprint"

# Install local development tools (optional)
install-tools:
	@echo "🛠️  Installing development tools..."
	@echo "This will install Android development tools locally"
	@echo "Warning: This may conflict with existing Java installations"
	@read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ]
	@echo "Installing OpenJDK 17..."
	@winget install Microsoft.OpenJDK.17
	@echo "Installing Android Studio..."
	@winget install Google.AndroidStudio
	@echo "✅ Tools installed! Restart your terminal and configure Godot."

# Development helpers
dev-check:
	@echo "🔍 Development Environment Check"
	@echo ""
	@echo "Docker status:"
	@docker --version 2>/dev/null || echo "❌ Docker not installed"
	@echo ""
	@echo "Project structure:"
	@ls -la project.godot 2>/dev/null && echo "✅ Godot project found" || echo "❌ project.godot not found"
	@ls -la android/build/google-services.json 2>/dev/null && echo "✅ Firebase config found" || echo "⚠️  google-services.json not found"
	@echo ""
	@echo "Android build status:"
	@ls -la android/output/lectoemocion.apk 2>/dev/null && echo "✅ APK exists" || echo "⚠️  No APK built yet"

# Quick start
quick-start:
	@echo "🚀 Quick Start Guide"
	@echo ""
	@echo "1. Build Android export environment:"
	@echo "   make android-setup"
	@echo ""
	@echo "2. Add Firebase configuration (optional):"
	@echo "   - Download google-services.json from Firebase Console"
	@echo "   - Place it in android/build/google-services.json"
	@echo ""
	@echo "3. Build APK:"
	@echo "   make android"
	@echo ""
	@echo "4. Install on device:"
	@echo "   adb install android/output/lectoemocion.apk" 