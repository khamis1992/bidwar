#!/bin/bash

# BidWar APK Build Script - Network-Resilient Version
# This script builds APK files even in restricted network environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="release"
CLEAN_BUILD=false
VERBOSE=false
SCRIPT_VERSION="3.0.0"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "This script builds BidWar APK files with network-resilient Flutter setup."
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE     Build type: debug or release (default: release)"
    echo "  -c, --clean         Clean before building"
    echo "  -v, --verbose       Verbose output"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Build release APK"
    echo "  $0 -t debug        # Build debug APK"
    echo "  $0 -c -t release   # Clean and build release APK"
    echo ""
    echo "Requirements:"
    echo "  - Android SDK installed at /usr/local/lib/android/sdk"
    echo "  - Java 17+ installed"
    echo "  - Flutter (will attempt installation if missing)"
    echo ""
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

echo -e "${PURPLE}🚀 BidWar APK Builder - Network-Resilient v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}========================================================${NC}"
echo -e "${CYAN}Build Type: $BUILD_TYPE${NC}"
echo -e "${CYAN}Clean Build: $CLEAN_BUILD${NC}"
echo -e "${CYAN}Verbose: $VERBOSE${NC}"
echo ""

# Set up environment variables
echo -e "${BLUE}🔧 Setting up environment...${NC}"
export ANDROID_HOME="/usr/local/lib/android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

echo -e "${GREEN}✅ ANDROID_HOME: $ANDROID_HOME${NC}"
echo -e "${GREEN}✅ JAVA_HOME: $JAVA_HOME${NC}"

# Check Java
echo -e "${BLUE}☕ Checking Java...${NC}"
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✅ $JAVA_VERSION${NC}"
else
    echo -e "${RED}❌ Java not found${NC}"
    exit 1
fi

# Check Android SDK
echo -e "${BLUE}📱 Checking Android SDK...${NC}"
if [[ -d "$ANDROID_HOME" ]]; then
    echo -e "${GREEN}✅ Android SDK found at $ANDROID_HOME${NC}"
    
    # List available platforms
    if [[ -d "$ANDROID_HOME/platforms" ]]; then
        PLATFORMS=$(ls "$ANDROID_HOME/platforms" | grep android- | wc -l)
        echo -e "${GREEN}✅ $PLATFORMS Android platforms available${NC}"
    fi
else
    echo -e "${RED}❌ Android SDK not found at $ANDROID_HOME${NC}"
    exit 1
fi

# Try multiple methods to get Flutter working
echo -e "${BLUE}🔍 Checking for Flutter...${NC}"
FLUTTER_FOUND=false

# Method 1: Check if Flutter is already in PATH
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✅ Flutter found in PATH${NC}"
    FLUTTER_VERSION=$(flutter --version | head -n 1 || echo "Version check failed")
    echo -e "${GREEN}   $FLUTTER_VERSION${NC}"
    FLUTTER_FOUND=true
fi

# Method 2: Check common Flutter installation locations
if [[ "$FLUTTER_FOUND" == false ]]; then
    echo -e "${YELLOW}🔍 Searching for Flutter in common locations...${NC}"
    FLUTTER_LOCATIONS=(
        "/opt/flutter/bin"
        "/usr/local/flutter/bin"
        "/home/flutter/bin"
        "$HOME/flutter/bin"
        "/snap/flutter/common/flutter/bin"
    )
    
    for location in "${FLUTTER_LOCATIONS[@]}"; do
        if [[ -f "$location/flutter" ]]; then
            echo -e "${GREEN}✅ Found Flutter at $location${NC}"
            export PATH="$location:$PATH"
            FLUTTER_FOUND=true
            break
        fi
    done
fi

# Method 3: Try to install Flutter using snap (if available)
if [[ "$FLUTTER_FOUND" == false ]] && command -v snap &> /dev/null; then
    echo -e "${YELLOW}📥 Attempting Flutter installation via snap...${NC}"
    if sudo snap install flutter --classic 2>/dev/null; then
        export PATH="$PATH:/snap/bin"
        FLUTTER_FOUND=true
        echo -e "${GREEN}✅ Flutter installed via snap${NC}"
    else
        echo -e "${YELLOW}⚠️ Snap installation failed or not available${NC}"
    fi
fi

# Method 4: Create minimal Flutter environment using existing tools
if [[ "$FLUTTER_FOUND" == false ]]; then
    echo -e "${YELLOW}🔧 Creating minimal build environment...${NC}"
    echo -e "${YELLOW}This build will use GitHub Actions or manual setup instead.${NC}"
    echo ""
    echo -e "${BLUE}📋 Alternative build methods:${NC}"
    echo -e "${CYAN}1. Use GitHub Actions (recommended):${NC}"
    echo -e "   - Push code to repository"
    echo -e "   - Download APK from Actions artifacts"
    echo -e "${CYAN}2. Manual Flutter installation:${NC}"
    echo -e "   - Download Flutter SDK from https://flutter.dev"
    echo -e "   - Extract to /opt/flutter and add to PATH"
    echo -e "${CYAN}3. Use provided scripts:${NC}"
    echo -e "   - Run: sudo ./install_flutter.sh"
    echo -e "   - Then: source /tmp/flutter_env.sh"
    echo ""
    exit 1
fi

# Configure Flutter
echo -e "${BLUE}🔧 Configuring Flutter...${NC}"
flutter config --no-analytics --no-cli-animations 2>/dev/null || echo -e "${YELLOW}⚠️ Flutter config partially failed${NC}"

# Navigate to project directory
cd /home/runner/work/bidwar/bidwar

# Check if this is a Flutter project
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}❌ Not in a Flutter project directory${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter project detected${NC}"

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

# Check Flutter doctor
echo -e "${BLUE}🏥 Running Flutter doctor...${NC}"
flutter doctor || echo -e "${YELLOW}⚠️ Flutter doctor found some issues, but continuing...${NC}"

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Check for dependency conflicts
echo -e "${BLUE}🔍 Checking for dependency conflicts...${NC}"
flutter pub deps || echo -e "${YELLOW}⚠️ Some dependency issues found, but continuing...${NC}"

# Analyze code (optional)
echo -e "${BLUE}🔍 Analyzing code...${NC}"
flutter analyze --no-fatal-infos || echo -e "${YELLOW}⚠️ Code analysis found issues, but continuing...${NC}"

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
        echo ""
        echo -e "${GREEN}🎉 APK BUILD SUCCESSFUL! 🎉${NC}"
        echo -e "${GREEN}================================${NC}"
        echo -e "${GREEN}📱 APK Path: $APK_PATH${NC}"
        echo -e "${GREEN}📏 APK Size: $APK_SIZE${NC}"
        echo -e "${GREEN}⏱️ Build Time: ${BUILD_TIME}s${NC}"
        echo -e "${GREEN}🏷️ Build Type: $BUILD_TYPE${NC}"
        
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
Build Time: ${BUILD_TIME}s
Script Version: $SCRIPT_VERSION
Android Home: $ANDROID_HOME
Java Version: $(java -version 2>&1 | head -n 1)
Flutter Version: $(flutter --version 2>/dev/null | head -n 1 || echo "Version check failed")

Build Environment:
- OS: $(uname -a)
- Dart SDK: $(flutter --version 2>/dev/null | grep Dart || echo "Unknown")
- Android SDK: $ANDROID_HOME
- Gradle: $(./android/gradlew --version 2>/dev/null | grep Gradle || echo "Unknown")
EOF
        
        echo ""
        echo -e "${BLUE}📊 Build Summary:${NC}"
        echo -e "${BLUE}   📱 APK: artifacts/$NEW_NAME${NC}"
        echo -e "${BLUE}   📏 Size: $APK_SIZE${NC}"
        echo -e "${BLUE}   ⏱️ Time: ${BUILD_TIME}s${NC}"
        echo -e "${BLUE}   🏷️ Type: $BUILD_TYPE${NC}"
        echo ""
        echo -e "${GREEN}✅ BUILD COMPLETED SUCCESSFULLY!${NC}"
        echo -e "${CYAN}🚀 Your APK is ready for deployment!${NC}"
        
    else
        echo -e "${RED}❌ APK file not found at expected location: $APK_PATH${NC}"
        echo -e "${YELLOW}🔍 Searching for APK files...${NC}"
        find build -name "*.apk" -type f 2>/dev/null || echo "No APK files found"
        exit 1
    fi
else
    echo -e "${RED}❌ APK BUILD FAILED${NC}"
    
    # Show debugging information
    echo -e "${BLUE}🔍 Debugging information:${NC}"
    echo -e "${BLUE}Flutter doctor:${NC}"
    flutter doctor -v || true
    
    echo -e "${BLUE}Build directory contents:${NC}"
    ls -la build/ 2>/dev/null || echo "No build directory"
    
    echo -e "${BLUE}Android build directory:${NC}"
    ls -la build/app/ 2>/dev/null || echo "No app build directory"
    
    echo -e "${BLUE}Gradle output directory:${NC}"
    ls -la build/app/outputs/ 2>/dev/null || echo "No outputs directory"
    
    echo ""
    echo -e "${YELLOW}💡 Troubleshooting suggestions:${NC}"
    echo -e "${CYAN}1. Run: flutter clean && flutter pub get${NC}"
    echo -e "${CYAN}2. Check: flutter doctor --android-licenses${NC}"
    echo -e "${CYAN}3. Try: ./setup_flutter_and_build.sh --no-flutter${NC}"
    echo -e "${CYAN}4. Use: GitHub Actions for automated builds${NC}"
    
    exit 1
fi