#!/bin/bash

# Script to build and run the Hourly Audio Player app in development mode
# Usage: ./build_and_run.sh

set -e  # Exit on any error

echo "🚀 Building and running Hourly Audio Player..."
echo "=============================================="

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

# Clean previous build
print_status "Cleaning previous build..."
xcodebuild clean -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer > /dev/null 2>&1 || true

# Build the project
print_status "Building Hourly Audio Player..."
if xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Debug build; then
    print_success "Build completed successfully!"
else
    print_error "Build failed!"
    exit 1
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
echo ""
echo "🔧 To stop the app:"
echo "   • Click the menu bar icon → Quit"
echo "   • Or run: pkill -f HourlyAudioPlayer"
echo ""
print_status "App launched successfully! Check your menu bar for the speaker icon."
