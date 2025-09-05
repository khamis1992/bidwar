#!/bin/bash

# BidWar APK Build Script - Comprehensive Fix
# This script handles Flutter installation, environment setup, and APK building

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="release"
CLEAN_BUILD=false
VERBOSE=false
INSTALL_FLUTTER=true
SCRIPT_VERSION="2.0.0"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --type TYPE     Build type: debug or release (default: release)"
    echo "  -c, --clean         Clean before building"
    echo "  -v, --verbose       Verbose output"
    echo "  --no-flutter        Skip Flutter installation"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Install Flutter and build release APK"
    echo "  $0 -t debug        # Install Flutter and build debug APK"
    echo "  $0 -c -t release   # Clean, install Flutter and build release APK"
    echo "  $0 --no-flutter -t debug  # Build debug APK without Flutter installation"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --no-flutter)
            INSTALL_FLUTTER=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate build type
if [[ "$BUILD_TYPE" != "debug" && "$BUILD_TYPE" != "release" ]]; then
    echo -e "${RED}Error: Build type must be 'debug' or 'release'${NC}"
    exit 1
fi

echo -e "${PURPLE}🚀 BidWar APK Builder - Comprehensive Fix v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}=============================================================${NC}"
echo -e "${CYAN}Build Type: $BUILD_TYPE${NC}"
echo -e "${CYAN}Clean Build: $CLEAN_BUILD${NC}"
echo -e "${CYAN}Install Flutter: $INSTALL_FLUTTER${NC}"
echo -e "${CYAN}Verbose: $VERBOSE${NC}"
echo ""

# Set up environment variables
export ANDROID_HOME="/usr/local/lib/android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

echo -e "${BLUE}🔧 Setting up environment...${NC}"
echo -e "${GREEN}✅ ANDROID_HOME: $ANDROID_HOME${NC}"
echo -e "${GREEN}✅ ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT${NC}"

# Install Flutter if requested
if [[ "$INSTALL_FLUTTER" == true ]]; then
    echo -e "${BLUE}📱 Installing Flutter...${NC}"
    
    FLUTTER_VERSION="3.24.3"
    FLUTTER_DIR="/tmp/flutter"
    
    if [[ ! -d "$FLUTTER_DIR" ]]; then
        echo -e "${YELLOW}Downloading Flutter $FLUTTER_VERSION...${NC}"
        cd /tmp
        
        # Try multiple download methods
        if command -v wget &> /dev/null; then
            wget -q -O flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" || {
                echo -e "${YELLOW}⚠️ wget failed, trying curl...${NC}"
                curl -L -o flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" || {
                    echo -e "${YELLOW}⚠️ Direct download failed, trying git clone...${NC}"
                    git clone https://github.com/flutter/flutter.git -b stable flutter
                }
            }
        else
            curl -L -o flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" || {
                echo -e "${YELLOW}⚠️ curl failed, trying git clone...${NC}"
                git clone https://github.com/flutter/flutter.git -b stable flutter
            }
        fi
        
        # Extract if we downloaded the archive
        if [[ -f "flutter.tar.xz" ]]; then
            echo -e "${YELLOW}Extracting Flutter...${NC}"
            tar xf flutter.tar.xz
            rm flutter.tar.xz
        fi
    else
        echo -e "${GREEN}✅ Flutter directory already exists${NC}"
    fi
    
    # Add Flutter to PATH
    export PATH="$PATH:$FLUTTER_DIR/bin"
    echo -e "${GREEN}✅ Flutter added to PATH${NC}"
else
    echo -e "${YELLOW}⚠️ Skipping Flutter installation${NC}"
fi

# Check if Flutter is available
if command -v flutter &> /dev/null; then
    echo -e "${BLUE}📋 Checking Flutter...${NC}"
    FLUTTER_VERSION_OUTPUT=$(flutter --version | head -n 1)
    echo -e "${GREEN}✅ $FLUTTER_VERSION_OUTPUT${NC}"
    
    # Configure Flutter
    echo -e "${BLUE}🔧 Configuring Flutter...${NC}"
    flutter config --no-analytics --no-cli-animations
    echo -e "${GREEN}✅ Flutter configured${NC}"
    
    # Check Flutter doctor
    echo -e "${BLUE}🏥 Running Flutter doctor...${NC}"
    flutter doctor || echo -e "${YELLOW}⚠️ Flutter doctor found some issues, but continuing...${NC}"
    
    # Accept Android licenses
    if command -v sdkmanager &> /dev/null; then
        echo -e "${BLUE}📜 Accepting Android licenses...${NC}"
        yes | flutter doctor --android-licenses || echo -e "${YELLOW}⚠️ Some licenses might not be accepted${NC}"
    fi
else
    echo -e "${RED}❌ Flutter not found. Please install Flutter manually.${NC}"
    echo -e "${YELLOW}You can run this script with Flutter in PATH or install it manually.${NC}"
    exit 1
fi

# Navigate to project directory
cd /home/runner/work/bidwar/bidwar

# Check if this is a Flutter project
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}❌ Not in a Flutter project directory${NC}"
    exit 1
fi

# Create or update env.json
echo -e "${BLUE}📝 Setting up environment configuration...${NC}"
if [[ ! -f "env.json" ]]; then
    echo -e "${YELLOW}⚠️ env.json not found. Creating default environment file...${NC}"
    cat > env.json << 'EOF'
{
  "SUPABASE_URL": "https://lelkttetaguswijpdnsb.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlbGt0dGV0YWd1c3dpanBkbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyMzA2OTgsImV4cCI6MjA3MTgwNjY5OH0.wS2ko7O7glbg0Ekw-QHY9WB7HkFOGwohlO_Zwr8ByLw",
  "OPENAI_API_KEY": "your-openai-api-key-here",
  "GEMINI_API_KEY": "your-gemini-api-key-here",
  "ANTHROPIC_API_KEY": "your-anthropic-api-key-here",
  "PERPLEXITY_API_KEY": "your-perplexity-api-key-here"
}
EOF
    echo -e "${GREEN}✅ Created env.json with default values${NC}"
else
    echo -e "${GREEN}✅ env.json already exists${NC}"
fi

# Fix Gradle wrapper permissions
if [[ -f "android/gradlew" ]]; then
    chmod +x android/gradlew
    echo -e "${GREEN}✅ Gradle wrapper permissions fixed${NC}"
fi

# Clean if requested
if [[ "$CLEAN_BUILD" == true ]]; then
    echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
    flutter clean
    rm -rf build/
    echo -e "${GREEN}✅ Clean completed${NC}"
fi

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Check for dependency conflicts
echo -e "${BLUE}🔍 Checking for dependency conflicts...${NC}"
flutter pub deps || echo -e "${YELLOW}⚠️ Some dependency issues found, but continuing...${NC}"

# Analyze code
echo -e "${BLUE}🔍 Analyzing code...${NC}"
flutter analyze --no-fatal-infos || echo -e "${YELLOW}⚠️ Code analysis found issues, but continuing...${NC}"

# Run tests (optional)
echo -e "${BLUE}🧪 Running tests...${NC}"
flutter test || echo -e "${YELLOW}⚠️ Some tests failed, but continuing...${NC}"

# Build APK
echo -e "${BLUE}🏗️ Building $BUILD_TYPE APK...${NC}"
BUILD_START=$(date +%s)

BUILD_ARGS="--$BUILD_TYPE --dart-define-from-file=env.json --android-skip-build-dependency-validation --no-tree-shake-icons"

if [[ "$VERBOSE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --verbose"
fi

# Build with comprehensive error handling
echo -e "${YELLOW}Starting APK build with args: $BUILD_ARGS${NC}"

if flutter build apk $BUILD_ARGS; then
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    
    # Verify APK was created
    APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
    
    if [[ -f "$APK_PATH" ]]; then
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        echo -e "${GREEN}🎉 APK build completed successfully!${NC}"
        echo -e "${GREEN}📱 APK Path: $APK_PATH${NC}"
        echo -e "${GREEN}📏 APK Size: $APK_SIZE${NC}"
        echo -e "${GREEN}⏱️ Build Time: ${BUILD_TIME}s${NC}"
        
        # Create artifacts directory and copy APK
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        COMMIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        NEW_NAME="bidwar-$BUILD_TYPE-$TIMESTAMP-$COMMIT_SHA.apk"
        
        mkdir -p artifacts
        cp "$APK_PATH" "artifacts/$NEW_NAME"
        echo -e "${GREEN}📋 APK copied to: artifacts/$NEW_NAME${NC}"
        
        # Create build info
        cat > artifacts/build_info_$TIMESTAMP.txt << EOF
BidWar APK Build Information
============================
Build Type: $BUILD_TYPE
Build Date: $(date)
APK Size: $APK_SIZE
APK Path: $APK_PATH
Commit SHA: $COMMIT_SHA
Flutter Version: $FLUTTER_VERSION_OUTPUT
Build Time: ${BUILD_TIME}s
Script Version: $SCRIPT_VERSION
Android Home: $ANDROID_HOME
Java Version: $(java -version 2>&1 | head -n 1)
EOF
        
        echo -e "${BLUE}🎉 Build Summary:${NC}"
        echo -e "${BLUE}   Type: $BUILD_TYPE${NC}"
        echo -e "${BLUE}   Size: $APK_SIZE${NC}"
        echo -e "${BLUE}   Time: ${BUILD_TIME}s${NC}"
        echo -e "${BLUE}   Path: artifacts/$NEW_NAME${NC}"
        echo ""
        echo -e "${GREEN}✅ Build completed successfully!${NC}"
        
    else
        echo -e "${RED}❌ APK file not found at expected location: $APK_PATH${NC}"
        echo -e "${YELLOW}🔍 Searching for APK files...${NC}"
        find build -name "*.apk" -type f 2>/dev/null || echo "No APK files found"
        exit 1
    fi
else
    echo -e "${RED}❌ APK build failed${NC}"
    
    # Show debugging information
    echo -e "${BLUE}🔍 Debugging information:${NC}"
    echo -e "${BLUE}Flutter doctor:${NC}"
    flutter doctor -v || true
    
    echo -e "${BLUE}Build directory contents:${NC}"
    ls -la build/ 2>/dev/null || echo "No build directory"
    
    echo -e "${BLUE}Android build directory:${NC}"
    ls -la build/app/ 2>/dev/null || echo "No app build directory"
    
    exit 1
fi