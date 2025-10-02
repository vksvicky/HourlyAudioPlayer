#!/bin/bash

# Script to build and run the Hourly Audio Player app in development mode
# Usage: ./build_and_run.sh [major|minor] [debug]
#   major: Updates CFBundleShortVersionString & NSApplicationVersion (e.g., 1.0.0 -> 2.0.0)
#   minor: Updates CFBundleVersion & NSVersion Build number (e.g., Build 46 -> Build 47)
#   debug: Enables debug mode with notification testing features
#   Default: minor

set -e  # Exit on any error

# Parse command line arguments
UPDATE_TYPE=${1:-minor}
DEBUG_MODE=${2:-false}

if [[ "$UPDATE_TYPE" != "major" && "$UPDATE_TYPE" != "minor" ]]; then
    echo "❌ Invalid update type. Use 'major' or 'minor'"
    echo "Usage: $0 [major|minor] [debug]"
    echo "  major: Updates version number (1.0.0 -> 2.0.0)"
    echo "  minor: Updates build number (Build 46 -> Build 47)"
    echo "  debug: Enables debug mode with notification testing features"
    exit 1
fi

echo "🚀 Building and running Hourly Audio Player..."
echo "=============================================="
echo "📋 Update type: $UPDATE_TYPE"
echo "🐛 Debug mode: $DEBUG_MODE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "HourlyAudioPlayer.xcodeproj/project.pbxproj" ]; then
    print_error "HourlyAudioPlayer.xcodeproj not found. Please run this script from the project root directory."
    exit 1
fi

# Version update functionality
update_version() {
    local update_type=$1
    local info_plist="src/Info.plist"
    
    if [ ! -f "$info_plist" ]; then
        print_error "Info.plist not found!"
        exit 1
    fi
    
    if [ "$update_type" = "major" ]; then
        # Update major version (CFBundleShortVersionString & NSApplicationVersion)
        print_status "Updating major version..."
        
        # Get current version
        current_version=$(plutil -extract CFBundleShortVersionString raw "$info_plist")
        echo "Current version: $current_version"
        
        # Parse version components
        IFS='.' read -r major minor patch <<< "$current_version"
        
        # Increment major version
        new_major=$((major + 1))
        new_version="$new_major.0.0"
        
        # Update CFBundleShortVersionString
        plutil -replace CFBundleShortVersionString -string "$new_version" "$info_plist"
        
        # Update NSApplicationVersion in NSAboutPanelOptions
        plutil -replace NSAboutPanelOptions.NSApplicationVersion -string "$new_version" "$info_plist"
        
        # Update NSVersion to include new version with build number
        current_build=$(plutil -extract CFBundleVersion raw "$info_plist")
        new_ns_version="$new_version (Build $current_build)"
        plutil -replace NSAboutPanelOptions.NSVersion -string "$new_ns_version" "$info_plist"
        
        # Update CFBundleGetInfoString
        new_info_string="Hourly Audio Player v$new_version - A menu bar app that plays custom audio files at the top of each hour."
        plutil -replace CFBundleGetInfoString -string "$new_info_string" "$info_plist"
        
        print_success "Major version updated: $current_version -> $new_version"
        
    elif [ "$update_type" = "minor" ]; then
        # Update build number (CFBundleVersion & NSVersion Build)
        print_status "Updating build number..."
        
        # Get current build number
        current_build=$(plutil -extract CFBundleVersion raw "$info_plist")
        echo "Current build: $current_build"
        
        # Increment build number
        new_build=$((current_build + 1))
        
        # Update CFBundleVersion
        plutil -replace CFBundleVersion -string "$new_build" "$info_plist"
        
        # Update NSVersion Build number
        current_version=$(plutil -extract CFBundleShortVersionString raw "$info_plist")
        new_ns_version="$current_version (Build $new_build)"
        plutil -replace NSAboutPanelOptions.NSVersion -string "$new_ns_version" "$info_plist"
        
        # Update Xcode project CURRENT_PROJECT_VERSION
        sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*/CURRENT_PROJECT_VERSION = $new_build/g" HourlyAudioPlayer.xcodeproj/project.pbxproj
        
        print_success "Build number updated: $current_build -> $new_build"
    fi
}

# Update version based on type
update_version "$UPDATE_TYPE"

# Clean previous build
print_status "Cleaning previous build..."
xcodebuild clean -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer > /dev/null 2>&1 || true

# Build the project
print_status "Building Hourly Audio Player..."
    if [ "$DEBUG_MODE" = "debug" ]; then
        print_status "Building with debug mode enabled..."
        if xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Debug build SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG_MODE"; then
        print_success "Build completed successfully with debug mode!"
    else
        print_error "Build failed!"
        exit 1
    fi
else
    if xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Debug build; then
        print_success "Build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi
fi

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "HourlyAudioPlayer.app" -path "*/Debug/*" | head -1)

if [ -z "$APP_PATH" ]; then
    print_error "Could not find the built app. Build may have failed."
    exit 1
fi

print_success "Found app at: $APP_PATH"

# Kill any existing instances
print_status "Stopping any existing instances..."
pkill -f "HourlyAudioPlayer" > /dev/null 2>&1 || true
sleep 1

# Launch the app
print_status "Launching Hourly Audio Player..."
open "$APP_PATH"

print_success "🎵 Hourly Audio Player is now running!"
echo ""
echo "📋 What to expect:"
echo "   • Look for the speaker icon in your menu bar"
echo "   • Click the icon to open the app interface"
echo "   • Use 'Open Settings' to configure audio files"
echo "   • The app will automatically play audio at the top of each hour"
if [ "$DEBUG_MODE" = "debug" ]; then
    echo "   • 🐛 DEBUG MODE: Test notification button available in settings"
fi
echo ""
echo "🔧 To stop the app:"
echo "   • Click the menu bar icon → Quit"
echo "   • Or run: pkill -f HourlyAudioPlayer"
echo ""
echo "📊 Version Information:"
if [ "$UPDATE_TYPE" = "major" ]; then
    current_version=$(plutil -extract CFBundleShortVersionString raw "src/Info.plist")
    current_build=$(plutil -extract CFBundleVersion raw "src/Info.plist")
    echo "   • Version: $current_version (Build $current_build)"
    echo "   • Major version was incremented"
else
    current_version=$(plutil -extract CFBundleShortVersionString raw "src/Info.plist")
    current_build=$(plutil -extract CFBundleVersion raw "src/Info.plist")
    echo "   • Version: $current_version (Build $current_build)"
    echo "   • Build number was incremented"
fi
echo ""
print_status "App launched successfully! Check your menu bar for the speaker icon."
