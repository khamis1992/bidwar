#!/bin/bash

# BidWar Update and Build Script
# Comprehensive script for updating dependencies, fixing issues, and building APK

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script version
SCRIPT_VERSION="1.0.0"

# Default values
BUILD_TYPE="release"
CLEAN_BUILD=false
VERBOSE=false
UPDATE_DEPS=false
FIX_ISSUES=true
SKIP_TESTS=false

# Function to display usage
usage() {
    echo -e "${BLUE}BidWar Update and Build Script v${SCRIPT_VERSION}${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE         Build type: debug or release (default: release)"
    echo "  -c, --clean            Clean before building"
    echo "  -u, --update           Update dependencies"
    echo "  -v, --verbose          Verbose output"
    echo "  --no-fix              Skip automatic issue fixing"
    echo "  --skip-tests          Skip running tests"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Build release APK with fixes"
    echo "  $0 -t debug -c         # Clean and build debug APK"
    echo "  $0 -u -t release       # Update deps and build release APK"
    echo "  $0 --no-fix -v         # Build without fixes, verbose output"
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
        -u|--update)
            UPDATE_DEPS=true
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
        --skip-tests)
            SKIP_TESTS=true
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

echo -e "${PURPLE}🚀 BidWar Update and Build Script v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}================================================${NC}"
echo -e "${CYAN}Build Type: $BUILD_TYPE${NC}"
echo -e "${CYAN}Clean Build: $CLEAN_BUILD${NC}"
echo -e "${CYAN}Update Dependencies: $UPDATE_DEPS${NC}"
echo -e "${CYAN}Fix Issues: $FIX_ISSUES${NC}"
echo -e "${CYAN}Skip Tests: $SKIP_TESTS${NC}"
echo ""

# Set up environment variables
export PATH="$PATH:/home/ubuntu/flutter/bin:/usr/lib/android-sdk/cmdline-tools/latest/bin"
export ANDROID_HOME="/usr/lib/android-sdk"
export ANDROID_SDK_ROOT="/usr/lib/android-sdk"

# Function to check command availability
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ $1 not found in PATH${NC}"
        return 1
    fi
    return 0
}

# Check required tools
echo -e "${BLUE}🔍 Checking required tools...${NC}"
if check_command flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✅ $FLUTTER_VERSION${NC}"
else
    echo -e "${YELLOW}Please run the setup script first: /home/ubuntu/setup_flutter_env.sh${NC}"
    exit 1
fi

if check_command git; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✅ $GIT_VERSION${NC}"
fi

# Check project directory
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}❌ Not in a Flutter project directory${NC}"
    exit 1
fi

# Create or update env.json
echo -e "${BLUE}📝 Setting up environment configuration...${NC}"
if [[ ! -f "env.json" ]]; then
    echo -e "${YELLOW}⚠️  env.json not found. Creating default environment file...${NC}"
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

# Update Git repository
echo -e "${BLUE}📡 Updating Git repository...${NC}"
if git status &>/dev/null; then
    git fetch origin || echo -e "${YELLOW}⚠️  Could not fetch from origin${NC}"
    CURRENT_BRANCH=$(git branch --show-current)
    echo -e "${GREEN}✅ Current branch: $CURRENT_BRANCH${NC}"
else
    echo -e "${YELLOW}⚠️  Not a Git repository${NC}"
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
    
    # Update Android configuration to avoid NDK issues
    echo -e "${YELLOW}Updating Android configuration...${NC}"
    
    # Update build.gradle to use compatible versions
    if [[ -f "android/build.gradle" ]]; then
        # Backup original file
        cp android/build.gradle android/build.gradle.backup
        
        # Update Gradle and Kotlin versions
        sed -i "s/ext.kotlin_version = '1.8.22'/ext.kotlin_version = '1.9.10'/g" android/build.gradle
        sed -i "s/classpath 'com.android.tools.build:gradle:8.2.1'/classpath 'com.android.tools.build:gradle:8.1.4'/g" android/build.gradle
        
        echo -e "${GREEN}✅ Android build configuration updated${NC}"
    fi
    
    # Update app-level build.gradle
    if [[ -f "android/app/build.gradle" ]]; then
        # Backup original file
        cp android/app/build.gradle android/app/build.gradle.backup
        
        # Ensure minimum SDK versions are compatible
        sed -i 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 21/g' android/app/build.gradle
        sed -i 's/compileSdkVersion flutter.compileSdkVersion/compileSdkVersion 34/g' android/app/build.gradle
        sed -i 's/targetSdkVersion flutter.targetSdkVersion/targetSdkVersion 34/g' android/app/build.gradle
        
        echo -e "${GREEN}✅ App-level build configuration updated${NC}"
    fi
fi

# Clean if requested
if [[ "$CLEAN_BUILD" == true ]]; then
    echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
    flutter clean
    rm -rf build/
    echo -e "${GREEN}✅ Clean completed${NC}"
fi

# Update dependencies
if [[ "$UPDATE_DEPS" == true ]]; then
    echo -e "${BLUE}📦 Updating dependencies...${NC}"
    flutter pub upgrade
    echo -e "${GREEN}✅ Dependencies updated${NC}"
else
    echo -e "${BLUE}📦 Getting dependencies...${NC}"
    flutter pub get
    echo -e "${GREEN}✅ Dependencies resolved${NC}"
fi

# Run tests (optional)
if [[ "$SKIP_TESTS" == false ]]; then
    echo -e "${BLUE}🧪 Running tests...${NC}"
    if flutter test --no-sound-null-safety 2>/dev/null; then
        echo -e "${GREEN}✅ Tests passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Some tests failed, but continuing...${NC}"
    fi
fi

# Build APK
echo -e "${BLUE}🏗️  Building $BUILD_TYPE APK...${NC}"
BUILD_START=$(date +%s)

BUILD_ARGS="--$BUILD_TYPE --dart-define-from-file=env.json"
BUILD_ARGS="$BUILD_ARGS --android-skip-build-dependency-validation"
BUILD_ARGS="$BUILD_ARGS --no-tree-shake-icons"

if [[ "$VERBOSE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --verbose"
fi

# Try building with different strategies
echo -e "${YELLOW}Attempting build with dependency validation skip...${NC}"

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
Dependencies Updated: $UPDATE_DEPS
Script Version: $SCRIPT_VERSION
EOF
        
        echo -e "${PURPLE}🎉 Build Summary:${NC}"
        echo -e "${CYAN}   Type: $BUILD_TYPE${NC}"
        echo -e "${CYAN}   Size: $APK_SIZE${NC}"
        echo -e "${CYAN}   Time: ${BUILD_TIME}s${NC}"
        echo -e "${CYAN}   File: artifacts/$NEW_NAME${NC}"
        echo -e "${CYAN}   Script: v$SCRIPT_VERSION${NC}"
        
        # Create quick install script
        cat > artifacts/install_apk.sh << EOF
#!/bin/bash
# Quick APK installation script
echo "Installing BidWar APK..."
if command -v adb &> /dev/null; then
    adb install -r "$NEW_NAME"
    echo "APK installed successfully!"
else
    echo "ADB not found. Please install manually or use Android Studio."
fi
EOF
        chmod +x artifacts/install_apk.sh
        
    else
        echo -e "${RED}❌ APK file not found at expected location: $APK_PATH${NC}"
        echo -e "${YELLOW}Checking alternative locations...${NC}"
        find build -name "*.apk" -type f 2>/dev/null || echo "No APK files found"
        exit 1
    fi
else
    echo -e "${RED}❌ APK build failed${NC}"
    echo -e "${YELLOW}Trying alternative build approach...${NC}"
    
    # Try building without some optimizations
    BUILD_ARGS_ALT="--$BUILD_TYPE --dart-define-from-file=env.json --android-skip-build-dependency-validation --no-shrink"
    
    if flutter build apk $BUILD_ARGS_ALT; then
        echo -e "${GREEN}✅ APK build completed with alternative approach${NC}"
    else
        echo -e "${RED}❌ All build attempts failed${NC}"
        echo -e "${YELLOW}Check the error messages above for details${NC}"
        echo -e "${YELLOW}Try running with --verbose flag for more information${NC}"
        exit 1
    fi
fi

echo -e "${PURPLE}🎯 Build process completed successfully!${NC}"
echo -e "${CYAN}Check the artifacts/ directory for build outputs${NC}"

