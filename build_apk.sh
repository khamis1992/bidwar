#!/bin/bash

# BidWar APK Build Script
# This script helps build APK files locally with proper environment setup

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

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
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

echo -e "${BLUE}🔨 BidWar APK Builder${NC}"
echo -e "${BLUE}=====================${NC}"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found in PATH${NC}"
    echo -e "${YELLOW}Please install Flutter and add it to your PATH${NC}"
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

# Clean if requested
if [[ "$CLEAN_BUILD" == true ]]; then
    echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
    flutter clean
    echo -e "${GREEN}✅ Clean completed${NC}"
fi

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Analyze code (optional)
echo -e "${BLUE}🔍 Analyzing code...${NC}"
if flutter analyze --no-fatal-infos; then
    echo -e "${GREEN}✅ Code analysis passed${NC}"
else
    echo -e "${YELLOW}⚠️  Code analysis found issues, but continuing...${NC}"
fi

# Build APK
echo -e "${BLUE}🏗️  Building $BUILD_TYPE APK...${NC}"
BUILD_START=$(date +%s)

BUILD_ARGS="--$BUILD_TYPE --dart-define-from-file=env.json"
if [[ "$VERBOSE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --verbose"
fi

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
EOF
        
        echo -e "${BLUE}🎉 Build Summary:${NC}"
        echo -e "${BLUE}   Type: $BUILD_TYPE${NC}"
        echo -e "${BLUE}   Size: $APK_SIZE${NC}"
        echo -e "${BLUE}   Time: ${BUILD_TIME}s${NC}"
        echo -e "${BLUE}   File: artifacts/$NEW_NAME${NC}"
        
    else
        echo -e "${RED}❌ APK file not found at expected location: $APK_PATH${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ APK build failed${NC}"
    exit 1
fi