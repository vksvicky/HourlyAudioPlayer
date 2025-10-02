#!/bin/bash

# Script to build a release version of Hourly Audio Player
# Usage: ./build_release.sh [version_number]
# Example: ./build_release.sh 1.0.0

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}[RELEASE]${NC} $1"
}

# Get version number from argument or use default
VERSION=${1:-"1.0.0"}
BUILD_DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo "🏗️  Building Hourly Audio Player Release v$VERSION"
echo "=================================================="
echo "Build Date: $BUILD_DATE"
echo ""

# Check if we're in the right directory
if [ ! -f "HourlyAudioPlayer.xcodeproj/project.pbxproj" ]; then
    print_error "HourlyAudioPlayer.xcodeproj not found. Please run this script from the project root directory."
    exit 1
fi

# Create release directory
RELEASE_DIR="releases"
mkdir -p "$RELEASE_DIR"

# Clean previous builds
print_status "Cleaning previous builds..."
xcodebuild clean -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer > /dev/null 2>&1 || true

# Build Release version
print_status "Building Release version..."
if xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build; then
    print_success "Release build completed successfully!"
else
    print_error "Release build failed!"
    exit 1
fi

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "HourlyAudioPlayer.app" -path "*/Release/*" | head -1)

if [ -z "$APP_PATH" ]; then
    print_error "Could not find the built app. Build may have failed."
    exit 1
fi

print_success "Found release app at: $APP_PATH"

# Create release package
RELEASE_NAME="HourlyAudioPlayer-v$VERSION"
RELEASE_PACKAGE="$RELEASE_DIR/$RELEASE_NAME"

print_status "Creating release package..."

# Copy app to release directory
cp -R "$APP_PATH" "$RELEASE_PACKAGE.app"

# Create a DMG (Disk Image) for easy distribution
print_status "Creating DMG for distribution..."

DMG_NAME="$RELEASE_NAME.dmg"
DMG_PATH="$RELEASE_DIR/$DMG_NAME"

# Remove existing DMG if it exists
rm -f "$DMG_PATH"

# Create temporary directory for DMG contents
TEMP_DMG_DIR="/tmp/HourlyAudioPlayer_DMG"
rm -rf "$TEMP_DMG_DIR"
mkdir -p "$TEMP_DMG_DIR"

# Copy app to temp directory
cp -R "$RELEASE_PACKAGE.app" "$TEMP_DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DMG_DIR/Applications"

# Create DMG
hdiutil create -volname "Hourly Audio Player v$VERSION" -srcfolder "$TEMP_DMG_DIR" -ov -format UDZO "$DMG_PATH"

# Clean up temp directory
rm -rf "$TEMP_DMG_DIR"

# Create release notes
RELEASE_NOTES="$RELEASE_DIR/RELEASE_NOTES_v$VERSION.txt"
cat > "$RELEASE_NOTES" << EOF
Hourly Audio Player v$VERSION
============================

Build Date: $BUILD_DATE

Features:
• Menu bar app with speaker icon
• 24-hour audio file configuration
• Automatic hourly audio playback
• Support for MP3, WAV, M4A, AIFF formats
• Smart filename-based hour detection
• User notifications for audio playback
• Manual testing functionality
• Persistent audio file storage

Installation:
1. Download the DMG file: $DMG_NAME
2. Double-click the DMG to mount it
3. Drag HourlyAudioPlayer.app to your Applications folder
4. Launch the app from Applications or Spotlight

Usage:
1. Look for the speaker icon in your menu bar
2. Click the icon to open the app interface
3. Use "Open Settings" to configure audio files for each hour
4. The app will automatically play audio at the top of each hour

System Requirements:
• macOS 14.0 or later
• Audio files in supported formats (MP3, WAV, M4A, AIFF)

Troubleshooting:
• If the app doesn't appear in the menu bar, check System Preferences > Security & Privacy
• Make sure you have audio files assigned to at least one hour
• Use "Test Current Hour" to verify audio playback

For support or feedback, please check the project repository.
EOF

# Create ZIP archive as alternative distribution method
print_status "Creating ZIP archive..."
ZIP_NAME="$RELEASE_NAME.zip"
ZIP_PATH="$RELEASE_DIR/$ZIP_NAME"
cd "$RELEASE_DIR"
zip -r "$ZIP_NAME" "$RELEASE_NAME.app" > /dev/null
cd ..

# Get file sizes
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)

print_success "🎉 Release build completed successfully!"
echo ""
print_header "Release Package Created:"
echo "  📦 DMG: $DMG_NAME ($DMG_SIZE)"
echo "  📦 ZIP: $ZIP_NAME ($ZIP_SIZE)"
echo "  📄 Release Notes: RELEASE_NOTES_v$VERSION.txt"
echo ""
print_header "Release Location:"
echo "  📁 $RELEASE_DIR/"
echo ""
print_header "Distribution Files:"
echo "  🎵 $DMG_PATH"
echo "  🎵 $ZIP_PATH"
echo "  📋 $RELEASE_NOTES"
echo ""
print_status "You can now distribute the DMG or ZIP file to users."
print_status "The DMG provides the best user experience for installation."

# Optional: Open release directory in Finder
if command -v open &> /dev/null; then
    print_status "Opening release directory in Finder..."
    open "$RELEASE_DIR"
fi
