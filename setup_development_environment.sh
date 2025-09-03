#!/bin/bash

# BidWar Development Environment Setup Script
# Complete setup for Flutter development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_VERSION="1.0.0"

echo -e "${PURPLE}🛠️  BidWar Development Environment Setup v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}======================================================${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to add to PATH if not already present
add_to_path() {
    local path_to_add="$1"
    if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$PATH:$path_to_add"
        echo "export PATH=\"\$PATH:$path_to_add\"" >> ~/.bashrc
    fi
}

# Update system packages
echo -e "${BLUE}📦 Updating system packages...${NC}"
sudo apt update -qq

# Install essential development tools
echo -e "${BLUE}🔧 Installing essential development tools...${NC}"
sudo apt install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    build-essential \
    libssl-dev \
    pkg-config \
    cmake \
    ninja-build \
    clang \
    libgtk-3-dev

echo -e "${GREEN}✅ Essential tools installed${NC}"

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc

# Install Flutter if not present
if ! command_exists flutter; then
    echo -e "${BLUE}📱 Installing Flutter SDK...${NC}"
    
    if [[ ! -d "/home/ubuntu/flutter" ]]; then
        cd /home/ubuntu
        git clone https://github.com/flutter/flutter.git -b stable
    fi
    
    add_to_path "/home/ubuntu/flutter/bin"
    export PATH="$PATH:/home/ubuntu/flutter/bin"
    
    echo -e "${GREEN}✅ Flutter SDK installed${NC}"
else
    echo -e "${GREEN}✅ Flutter SDK already available${NC}"
fi

# Install Android SDK components
echo -e "${BLUE}📱 Setting up Android SDK...${NC}"

# Create Android SDK directory
sudo mkdir -p /usr/lib/android-sdk
export ANDROID_HOME="/usr/lib/android-sdk"
export ANDROID_SDK_ROOT="/usr/lib/android-sdk"
echo "export ANDROID_HOME=\"/usr/lib/android-sdk\"" >> ~/.bashrc
echo "export ANDROID_SDK_ROOT=\"/usr/lib/android-sdk\"" >> ~/.bashrc

# Download and install Android command line tools
if [[ ! -d "/usr/lib/android-sdk/cmdline-tools/latest" ]]; then
    echo -e "${YELLOW}Downloading Android command line tools...${NC}"
    cd /tmp
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip -q commandlinetools-linux-11076708_latest.zip
    sudo mkdir -p /usr/lib/android-sdk/cmdline-tools
    sudo mv cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest
    sudo chown -R $USER:$USER /usr/lib/android-sdk
    rm commandlinetools-linux-11076708_latest.zip
fi

add_to_path "/usr/lib/android-sdk/cmdline-tools/latest/bin"
export PATH="$PATH:/usr/lib/android-sdk/cmdline-tools/latest/bin"

# Install required Android SDK packages
echo -e "${BLUE}📦 Installing Android SDK packages...${NC}"
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null 2>&1 || true

add_to_path "/usr/lib/android-sdk/platform-tools"

# Configure Flutter
echo -e "${BLUE}⚙️  Configuring Flutter...${NC}"
flutter config --android-sdk /usr/lib/android-sdk
flutter config --no-analytics

# Run Flutter doctor
echo -e "${BLUE}🏥 Running Flutter doctor...${NC}"
flutter doctor

# Install additional useful tools
echo -e "${BLUE}🛠️  Installing additional development tools...${NC}"

# Install VS Code extensions helper (if VS Code is available)
if command_exists code; then
    echo -e "${YELLOW}Installing VS Code Flutter extensions...${NC}"
    code --install-extension Dart-Code.flutter || true
    code --install-extension Dart-Code.dart-code || true
fi

# Create development aliases
echo -e "${BLUE}📝 Creating development aliases...${NC}"
cat >> ~/.bashrc << 'EOF'

# BidWar Development Aliases
alias flutter-doctor='flutter doctor -v'
alias flutter-clean='flutter clean && flutter pub get'
alias flutter-build-debug='flutter build apk --debug'
alias flutter-build-release='flutter build apk --release'
alias android-devices='adb devices'
alias flutter-logs='flutter logs'

# Quick navigation
alias bidwar='cd /home/ubuntu/bidwar'
EOF

# Create project-specific configuration
echo -e "${BLUE}📋 Creating project configuration...${NC}"

# Create .vscode settings if directory exists
if [[ -d "/home/ubuntu/bidwar" ]]; then
    cd /home/ubuntu/bidwar
    
    mkdir -p .vscode
    cat > .vscode/settings.json << 'EOF'
{
    "dart.flutterSdkPath": "/home/ubuntu/flutter",
    "dart.androidSdkPath": "/usr/lib/android-sdk",
    "dart.debugExternalPackageLibraries": true,
    "dart.debugSdkLibraries": false,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll": true
    },
    "files.associations": {
        "*.dart": "dart"
    }
}
EOF

    cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter Debug",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart",
            "args": ["--dart-define-from-file=env.json"]
        },
        {
            "name": "Flutter Release",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart",
            "flutterMode": "release",
            "args": ["--dart-define-from-file=env.json"]
        }
    ]
}
EOF

    echo -e "${GREEN}✅ VS Code configuration created${NC}"
fi

# Create environment validation script
cat > /home/ubuntu/validate_environment.sh << 'EOF'
#!/bin/bash

echo "🔍 Validating BidWar Development Environment..."
echo "=============================================="

# Check Flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter: $(flutter --version | head -n 1)"
else
    echo "❌ Flutter: Not found"
fi

# Check Java
if command -v java &> /dev/null; then
    echo "✅ Java: $(java -version 2>&1 | head -n 1)"
else
    echo "❌ Java: Not found"
fi

# Check Android SDK
if [[ -d "$ANDROID_HOME" ]]; then
    echo "✅ Android SDK: $ANDROID_HOME"
else
    echo "❌ Android SDK: Not found"
fi

# Check ADB
if command -v adb &> /dev/null; then
    echo "✅ ADB: Available"
else
    echo "❌ ADB: Not found"
fi

# Check Git
if command -v git &> /dev/null; then
    echo "✅ Git: $(git --version)"
else
    echo "❌ Git: Not found"
fi

echo ""
echo "🏥 Running Flutter Doctor..."
flutter doctor
EOF

chmod +x /home/ubuntu/validate_environment.sh

# Final setup
echo -e "${BLUE}🔄 Finalizing setup...${NC}"
source ~/.bashrc

echo -e "${PURPLE}🎉 Development Environment Setup Complete!${NC}"
echo -e "${CYAN}================================================${NC}"
echo -e "${GREEN}✅ Flutter SDK installed and configured${NC}"
echo -e "${GREEN}✅ Android SDK installed and configured${NC}"
echo -e "${GREEN}✅ Development tools installed${NC}"
echo -e "${GREEN}✅ Project configuration created${NC}"
echo -e "${GREEN}✅ Useful aliases added${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo -e "${CYAN}1. Restart your terminal or run: source ~/.bashrc${NC}"
echo -e "${CYAN}2. Navigate to project: cd /home/ubuntu/bidwar${NC}"
echo -e "${CYAN}3. Run environment validation: /home/ubuntu/validate_environment.sh${NC}"
echo -e "${CYAN}4. Build APK: ./update_and_build.sh${NC}"
echo ""
echo -e "${YELLOW}🔧 Useful Commands:${NC}"
echo -e "${CYAN}flutter-doctor    - Check Flutter installation${NC}"
echo -e "${CYAN}flutter-clean     - Clean and get dependencies${NC}"
echo -e "${CYAN}flutter-build-debug   - Build debug APK${NC}"
echo -e "${CYAN}flutter-build-release - Build release APK${NC}"
echo -e "${CYAN}bidwar           - Navigate to project directory${NC}"

