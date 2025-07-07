# Android Export Container for LectoEmoción
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    git \
    build-essential \
    libssl-dev \
    pkg-config \
    libasound2-dev \
    libudev-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libpulse-dev \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 17
RUN apt-get update && apt-get install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*

# Set up environment variables AFTER Java installation
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Verify Java installation
RUN java -version && javac -version && keytool -help > /dev/null

# Create Android SDK directory
RUN mkdir -p $ANDROID_HOME

# Install Android Command Line Tools
WORKDIR /tmp
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools-linux-9477386_latest.zip \
    && mkdir -p $ANDROID_HOME/cmdline-tools \
    && mv cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm commandlinetools-linux-9477386_latest.zip

# Verify Android SDK tools are accessible
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --version

# Accept Android SDK licenses and install required packages
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;33.0.2" "build-tools;34.0.0" "platforms;android-33" "platforms;android-34" "platforms;android-21"

# Install Godot 4.4 (headless for export)
WORKDIR /opt
RUN wget https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip \
    && unzip Godot_v4.4-stable_linux.x86_64.zip \
    && mv Godot_v4.4-stable_linux.x86_64 godot \
    && chmod +x godot \
    && rm Godot_v4.4-stable_linux.x86_64.zip

# Download Godot export templates
RUN wget https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_export_templates.tpz \
    && mkdir -p ~/.local/share/godot/export_templates/4.4.stable \
    && cd ~/.local/share/godot/export_templates/4.4.stable \
    && unzip /opt/Godot_v4.4-stable_export_templates.tpz \
    && mv templates/* . \
    && rmdir templates \
    && rm /opt/Godot_v4.4-stable_export_templates.tpz

# Create keystore directory
RUN mkdir -p /opt/keystores

# Generate debug keystore
RUN keytool -genkey -v -keystore /opt/keystores/debug.keystore \
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass android -keypass android \
    -dname "CN=Android Debug,O=Android,C=US"

# Create export script
COPY export_minimal.sh /opt/export_android.sh
RUN chmod +x /opt/export_android.sh

# Set working directory for project
WORKDIR /project

# Create Godot editor settings for Android export
RUN mkdir -p ~/.config/godot
COPY editor_settings.tres /root/.config/godot/editor_settings-4.tres

# Add Godot to PATH
ENV PATH=$PATH:/opt

# Expose volumes for project and output
VOLUME ["/project", "/output"]

# Default command
CMD ["/opt/export_android.sh"] 