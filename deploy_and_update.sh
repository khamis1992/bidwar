#!/bin/bash

# BidWar Deploy and Update Script
# Handles Git operations, building, and deployment

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

# Default values
COMMIT_MESSAGE=""
PUSH_TO_REMOTE=false
BUILD_APK=true
BUILD_TYPE="release"
DEPLOY_TO_GITHUB=false
CREATE_RELEASE=false
TAG_VERSION=""

# Function to display usage
usage() {
    echo -e "${BLUE}BidWar Deploy and Update Script v${SCRIPT_VERSION}${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -m, --message MSG      Commit message (required for commit)"
    echo "  -p, --push            Push changes to remote repository"
    echo "  -b, --build           Build APK after commit (default: true)"
    echo "  -t, --type TYPE       Build type: debug or release (default: release)"
    echo "  -d, --deploy          Deploy to GitHub releases"
    echo "  -r, --release TAG     Create GitHub release with tag"
    echo "  --no-build           Skip APK building"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -m \"Fix UI issues\" -p              # Commit, push, and build"
    echo "  $0 -m \"Version 1.2.0\" -r v1.2.0 -d   # Commit, tag, release, and deploy"
    echo "  $0 --no-build -m \"Update docs\" -p     # Commit and push without building"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        -p|--push)
            PUSH_TO_REMOTE=true
            shift
            ;;
        -b|--build)
            BUILD_APK=true
            shift
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -d|--deploy)
            DEPLOY_TO_GITHUB=true
            shift
            ;;
        -r|--release)
            CREATE_RELEASE=true
            TAG_VERSION="$2"
            shift 2
            ;;
        --no-build)
            BUILD_APK=false
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

echo -e "${PURPLE}🚀 BidWar Deploy and Update Script v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}===================================================${NC}"

# Check if we're in a git repository
if ! git status &>/dev/null; then
    echo -e "${RED}❌ Not in a Git repository${NC}"
    exit 1
fi

# Get current branch and status
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${CYAN}📍 Current branch: $CURRENT_BRANCH${NC}"

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}📝 Uncommitted changes detected${NC}"
    git status --short
    
    if [[ -n "$COMMIT_MESSAGE" ]]; then
        echo -e "${BLUE}💾 Committing changes...${NC}"
        
        # Add all changes
        git add .
        
        # Commit with message
        git commit -m "$COMMIT_MESSAGE"
        echo -e "${GREEN}✅ Changes committed: $COMMIT_MESSAGE${NC}"
        
        # Create tag if requested
        if [[ "$CREATE_RELEASE" == true && -n "$TAG_VERSION" ]]; then
            echo -e "${BLUE}🏷️  Creating tag: $TAG_VERSION${NC}"
            git tag -a "$TAG_VERSION" -m "Release $TAG_VERSION"
            echo -e "${GREEN}✅ Tag created: $TAG_VERSION${NC}"
        fi
        
    else
        echo -e "${YELLOW}⚠️  Use -m option to commit changes${NC}"
    fi
else
    echo -e "${GREEN}✅ Working directory clean${NC}"
fi

# Push to remote if requested
if [[ "$PUSH_TO_REMOTE" == true ]]; then
    echo -e "${BLUE}📤 Pushing to remote repository...${NC}"
    
    # Push commits
    git push origin "$CURRENT_BRANCH"
    echo -e "${GREEN}✅ Pushed commits to origin/$CURRENT_BRANCH${NC}"
    
    # Push tags if any
    if [[ "$CREATE_RELEASE" == true && -n "$TAG_VERSION" ]]; then
        git push origin "$TAG_VERSION"
        echo -e "${GREEN}✅ Pushed tag: $TAG_VERSION${NC}"
    fi
fi

# Build APK if requested
if [[ "$BUILD_APK" == true ]]; then
    echo -e "${BLUE}🏗️  Building APK...${NC}"
    
    if [[ -f "./update_and_build.sh" ]]; then
        chmod +x ./update_and_build.sh
        ./update_and_build.sh -t "$BUILD_TYPE" --no-fix
    else
        echo -e "${YELLOW}⚠️  update_and_build.sh not found, using direct Flutter build${NC}"
        
        # Set up environment
        export PATH="$PATH:/home/ubuntu/flutter/bin"
        export ANDROID_HOME="/usr/lib/android-sdk"
        
        # Build APK
        flutter build apk --"$BUILD_TYPE" --dart-define-from-file=env.json --android-skip-build-dependency-validation
    fi
    
    echo -e "${GREEN}✅ APK build completed${NC}"
fi

# Deploy to GitHub releases if requested
if [[ "$DEPLOY_TO_GITHUB" == true ]]; then
    echo -e "${BLUE}🚀 Deploying to GitHub releases...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub CLI not found. Installing...${NC}"
        
        # Install GitHub CLI
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        echo -e "${YELLOW}⚠️  Please authenticate with GitHub CLI:${NC}"
        echo -e "${CYAN}Run: gh auth login${NC}"
        exit 1
    fi
    
    # Create release if tag is provided
    if [[ "$CREATE_RELEASE" == true && -n "$TAG_VERSION" ]]; then
        echo -e "${BLUE}📦 Creating GitHub release: $TAG_VERSION${NC}"
        
        # Find APK file
        APK_FILE=$(find artifacts -name "*.apk" -type f | head -n 1)
        
        if [[ -n "$APK_FILE" ]]; then
            # Create release with APK
            gh release create "$TAG_VERSION" \
                --title "BidWar $TAG_VERSION" \
                --notes "Release $TAG_VERSION - Built on $(date)" \
                "$APK_FILE"
            
            echo -e "${GREEN}✅ GitHub release created with APK${NC}"
        else
            # Create release without APK
            gh release create "$TAG_VERSION" \
                --title "BidWar $TAG_VERSION" \
                --notes "Release $TAG_VERSION - Built on $(date)"
            
            echo -e "${GREEN}✅ GitHub release created${NC}"
        fi
    fi
fi

# Generate deployment report
echo -e "${BLUE}📊 Generating deployment report...${NC}"

REPORT_FILE="deployment_report_$(date +'%Y%m%d_%H%M%S').md"

cat > "$REPORT_FILE" << EOF
# BidWar Deployment Report

**Date:** $(date)
**Script Version:** $SCRIPT_VERSION
**Branch:** $CURRENT_BRANCH

## Actions Performed

- **Commit Message:** ${COMMIT_MESSAGE:-"No commit made"}
- **Push to Remote:** $PUSH_TO_REMOTE
- **Build APK:** $BUILD_APK
- **Build Type:** $BUILD_TYPE
- **Create Release:** $CREATE_RELEASE
- **Tag Version:** ${TAG_VERSION:-"No tag created"}
- **Deploy to GitHub:** $DEPLOY_TO_GITHUB

## Git Status

\`\`\`
$(git log --oneline -5)
\`\`\`

## Build Artifacts

$(if [[ -d "artifacts" ]]; then
    echo "Available in artifacts/ directory:"
    ls -la artifacts/ | tail -n +2
else
    echo "No artifacts directory found"
fi)

## Environment Info

- **Flutter Version:** $(flutter --version | head -n 1 2>/dev/null || echo "Not available")
- **Git Version:** $(git --version)
- **Current Commit:** $(git rev-parse HEAD)

---
*Generated by BidWar Deploy Script v$SCRIPT_VERSION*
EOF

echo -e "${GREEN}✅ Deployment report saved: $REPORT_FILE${NC}"

# Summary
echo -e "${PURPLE}🎯 Deployment Summary${NC}"
echo -e "${PURPLE}===================${NC}"
echo -e "${CYAN}Branch: $CURRENT_BRANCH${NC}"
echo -e "${CYAN}Commit: ${COMMIT_MESSAGE:-"No new commit"}${NC}"
echo -e "${CYAN}Push: $PUSH_TO_REMOTE${NC}"
echo -e "${CYAN}Build: $BUILD_APK ($BUILD_TYPE)${NC}"
echo -e "${CYAN}Release: ${TAG_VERSION:-"No release"}${NC}"
echo -e "${CYAN}Deploy: $DEPLOY_TO_GITHUB${NC}"
echo -e "${CYAN}Report: $REPORT_FILE${NC}"

echo -e "${GREEN}🎉 Deployment process completed successfully!${NC}"

