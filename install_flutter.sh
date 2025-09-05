#!/bin/bash

# Flutter Installation Script for BidWar APK Build
# This script downloads and sets up Flutter reliably

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Installing Flutter for BidWar APK Build${NC}"
echo -e "${BLUE}===========================================${NC}"

# Set environment
export ANDROID_HOME="/usr/local/lib/android/sdk"
export ANDROID_SDK_ROOT="/usr/local/lib/android/sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

FLUTTER_DIR="/opt/flutter"
FLUTTER_VERSION="3.24.3"

# Clean up any existing broken installation
if [[ -d "/tmp/flutter" ]]; then
    echo -e "${YELLOW}Removing broken Flutter installation...${NC}"
    rm -rf /tmp/flutter
fi

# Create Flutter directory
echo -e "${BLUE}📁 Creating Flutter directory: $FLUTTER_DIR${NC}"
sudo mkdir -p $FLUTTER_DIR
sudo chown $USER:$USER $FLUTTER_DIR

# Download Flutter using Git (more reliable)
echo -e "${BLUE}📥 Downloading Flutter via Git...${NC}"
cd /opt
sudo git clone https://github.com/flutter/flutter.git -b stable flutter

# Set permissions
sudo chown -R $USER:$USER $FLUTTER_DIR

# Add to PATH
export PATH="$PATH:$FLUTTER_DIR/bin"

# Pre-download Flutter tools to avoid runtime issues
echo -e "${BLUE}🔧 Pre-downloading Flutter tools...${NC}"
cd $FLUTTER_DIR

# Download Dart SDK manually to avoid corruption issues
echo -e "${BLUE}📥 Downloading Dart SDK manually...${NC}"
DART_SDK_URL="https://storage.googleapis.com/dart-archive/channels/stable/release/3.5.3/sdk/dartsdk-linux-x64-release.zip"
mkdir -p bin/cache
cd bin/cache

if command -v wget &> /dev/null; then
    wget -O dart-sdk.zip "$DART_SDK_URL"
else
    curl -L -o dart-sdk.zip "$DART_SDK_URL"
fi

unzip -q dart-sdk.zip
mv dart-sdk dart-sdk-linux-x64
rm dart-sdk.zip

# Return to Flutter directory
cd $FLUTTER_DIR

# Configure Flutter
echo -e "${BLUE}🔧 Configuring Flutter...${NC}"
./bin/flutter config --no-analytics --no-cli-animations

# Pre-cache Flutter
echo -e "${BLUE}📦 Pre-caching Flutter...${NC}"
./bin/flutter precache --linux

# Verify installation
echo -e "${BLUE}✅ Verifying Flutter installation...${NC}"
./bin/flutter --version

echo -e "${GREEN}🎉 Flutter installation completed successfully!${NC}"
echo -e "${GREEN}Flutter path: $FLUTTER_DIR/bin${NC}"
echo -e "${YELLOW}Add this to your PATH: export PATH=\"\$PATH:$FLUTTER_DIR/bin\"${NC}"

# Create environment script
cat > /tmp/flutter_env.sh << EOF
#!/bin/bash
export ANDROID_HOME="/usr/local/lib/android/sdk"
export ANDROID_SDK_ROOT="/usr/local/lib/android/sdk"
export PATH="\$PATH:$FLUTTER_DIR/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools"
EOF

echo -e "${GREEN}Environment script created at: /tmp/flutter_env.sh${NC}"
echo -e "${YELLOW}Source it with: source /tmp/flutter_env.sh${NC}"