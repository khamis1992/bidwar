#!/bin/bash

# BidWar APK Build Script - Fixed Version
# This script fixes common issues and builds APK files with proper environment setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="release"
CLEAN_BUILD=false
VERBOSE=false
FIX_ISSUES=true

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --type TYPE     Build type: debug or release (default: release)"
    echo "  -c, --clean         Clean before building"
    echo "  -v, --verbose       Verbose output"
    echo "  --no-fix           Skip automatic issue fixing"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Build release APK with fixes"
    echo "  $0 -t debug        # Build debug APK with fixes"
    echo "  $0 -c -t release   # Clean and build release APK"
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
        --no-fix)
            FIX_ISSUES=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
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

echo -e "${BLUE}🔨 BidWar APK Builder - Fixed Version${NC}"
echo -e "${BLUE}=====================================${NC}"

# Set up environment variables
export ANDROID_HOME="/usr/local/lib/android/sdk"
export ANDROID_SDK_ROOT="/usr/local/lib/android/sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found in PATH${NC}"
    echo -e "${YELLOW}Please run the setup script first: ./setup_flutter_and_build.sh${NC}"
    echo -e "${YELLOW}Or install Flutter manually and ensure it's in your PATH${NC}"
    exit 1
fi

# Check Flutter version
echo -e "${BLUE}📋 Checking Flutter version...${NC}"
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}✅ $FLUTTER_VERSION${NC}"

# Check if env.json exists
if [[ ! -f "env.json" ]]; then
    echo -e "${YELLOW}⚠️  env.json not found. Creating default environment file...${NC}"
    cat > env.json << EOF
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
fi

# Fix common issues
if [[ "$FIX_ISSUES" == true ]]; then
    echo -e "${BLUE}🔧 Fixing common issues...${NC}"
    
    # Fix theme issues
    if [[ -f "lib/theme/app_theme.dart" ]]; then
        echo -e "${YELLOW}Fixing theme compatibility issues...${NC}"
        sed -i 's/CardTheme(/CardThemeData(/g' lib/theme/app_theme.dart
        sed -i 's/TabBarTheme(/TabBarThemeData(/g' lib/theme/app_theme.dart
        echo -e "${GREEN}✅ Theme issues fixed${NC}"
    fi
    
    # Fix routing issues
    if [[ -f "lib/widgets/custom_error_widget.dart" ]]; then
        echo -e "${YELLOW}Fixing routing issues...${NC}"
        sed -i 's/AppRoutes\.initial/AppRoutes.home/g' lib/widgets/custom_error_widget.dart
        echo -e "${GREEN}✅ Routing issues fixed${NC}"
    fi
    
    # Fix gradle wrapper permissions
    if [[ -f "android/gradlew" ]]; then
        chmod +x android/gradlew
        echo -e "${GREEN}✅ Gradle wrapper permissions fixed${NC}"
    fi
fi

# Clean if requested
if [[ "$CLEAN_BUILD" == true ]]; then
    echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
    flutter clean
    echo -e "${GREEN}✅ Clean completed${NC}"
fi

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Build APK with error handling
echo -e "${BLUE}🏗️  Building $BUILD_TYPE APK...${NC}"
BUILD_START=$(date +%s)

BUILD_ARGS="--$BUILD_TYPE --dart-define-from-file=env.json"
if [[ "$VERBOSE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --verbose"
fi

# Add specific flags for better compatibility
BUILD_ARGS="$BUILD_ARGS --target-platform android-arm,android-arm64,android-x64"

if flutter build apk $BUILD_ARGS; then
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    echo -e "${GREEN}✅ APK build completed in ${BUILD_TIME}s${NC}"
    
    # Find and display APK info
    APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
    if [[ -f "$APK_PATH" ]]; then
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        echo -e "${GREEN}📱 APK created: $APK_PATH${NC}"
        echo -e "${GREEN}📏 APK size: $APK_SIZE${NC}"
        
        # Create artifacts directory and copy APK with timestamp
        TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
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
Flutter Version: $FLUTTER_VERSION
Build Time: ${BUILD_TIME}s
Issues Fixed: $FIX_ISSUES
EOF
        
        echo -e "${BLUE}🎉 Build Summary:${NC}"
        echo -e "${BLUE}   Type: $BUILD_TYPE${NC}"
        echo -e "${BLUE}   Size: $APK_SIZE${NC}"
        echo -e "${BLUE}   Time: ${BUILD_TIME}s${NC}"
        echo -e "${BLUE}   File: artifacts/$NEW_NAME${NC}"
        
    else
        echo -e "${RED}❌ APK file not found at expected location: $APK_PATH${NC}"
        echo -e "${YELLOW}Checking alternative locations...${NC}"
        find build -name "*.apk" -type f 2>/dev/null || echo "No APK files found"
        exit 1
    fi
else
    echo -e "${RED}❌ APK build failed${NC}"
    echo -e "${YELLOW}Check the error messages above for details${NC}"
    exit 1
fi

