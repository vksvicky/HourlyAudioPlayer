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

# Create docs directory if it doesn't exist
DOCS_DIR="docs"
mkdir -p "$DOCS_DIR"

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

# Create comprehensive release notes in docs folder
RELEASE_NOTES="$DOCS_DIR/RELEASE_NOTES_v$VERSION.txt"
cat > "$RELEASE_NOTES" << EOF
Hourly Audio Player v$VERSION
============================

Build Date: $BUILD_DATE
Build Type: Release
Architecture: Universal (Intel & Apple Silicon)

🎵 FEATURES
===========
• Menu bar app with speaker icon
• 24-hour audio file configuration (0:00 - 23:00)
• Automatic hourly audio playback
• Support for multiple audio formats (MP3, WAV, M4A, AIFF, AAC, FLAC, OGG)
• Smart filename-based hour detection (e.g., "12_midday.mp3" → 12:00)
• User notifications for audio playback
• Manual testing functionality
• Persistent audio file storage
• Real-time clock display
• Debug mode for development testing
• File validation (size limits, format checking)
• Missing file detection with fallback to system sounds

📦 INSTALLATION
===============
1. Download the DMG file: $DMG_NAME
2. Double-click the DMG to mount it
3. Drag HourlyAudioPlayer.app to your Applications folder
4. Launch the app from Applications or Spotlight
5. Grant necessary permissions when prompted

📚 DOCUMENTATION INCLUDED
==========================
The DMG/ZIP package includes:
• RELEASE_NOTES_v$VERSION.txt - Complete documentation
• troubleshoot.sh - Automated diagnostic script
• QUICK_START_GUIDE.txt - 5-minute setup guide
• RELEASE_CHECKLIST.txt - Quality assurance checklist

💻 SYSTEM REQUIREMENTS
======================
• macOS 12.0 or later
• Intel or Apple Silicon processor
• Audio files in supported formats
• Microphone/audio output device
• Internet connection (for notifications)

🎯 USAGE GUIDE
==============
1. Look for the speaker icon in your menu bar
2. Click the icon to open the app interface
3. Use "Open Settings" to configure audio files for each hour
4. The app will automatically play audio at the top of each hour
5. Use "Test Current Hour" to verify audio playback

🔧 TROUBLESHOOTING
==================

Common Issues & Solutions:

1. APP NOT APPEARING IN MENU BAR
   • Check System Preferences > Security & Privacy > Privacy > Accessibility
   • Ensure HourlyAudioPlayer has accessibility permissions
   • Restart the app or reboot your Mac
   • Check if the app is running in Activity Monitor

2. AUDIO NOT PLAYING
   • Verify audio files are assigned to the current hour
   • Check System Preferences > Sound > Output
   • Ensure audio files are in supported formats
   • Use "Test Current Hour" to verify playback
   • Check Console.app for error messages

3. NOTIFICATIONS NOT WORKING
   • Go to System Preferences > Notifications & Focus
   • Find HourlyAudioPlayer and enable notifications
   • Check "Allow notifications" is turned on
   • Verify notification permissions in System Preferences

4. AUDIO FILES NOT LOADING
   • Check file format (MP3, WAV, M4A, AIFF, AAC, FLAC, OGG)
   • Verify file size is under 2.5MB
   • Ensure file is not corrupted
   • Check file permissions (read access required)

5. APP CRASHES OR FREEZES
   • Check Console.app for crash logs
   • Restart the app
   • Clear app data: ~/Library/Application Support/HourlyAudioPlayer/
   • Reinstall the app

6. DEBUGGING ISSUES
   • Run with debug mode: ./build_and_run.sh minor debug
   • Check Console.app for log messages
   • Look for "HourlyAudioPlayer" in system logs
   • Use Activity Monitor to check app status

7. PERFORMANCE ISSUES
   • Close other audio applications
   • Check available disk space
   • Restart the app periodically
   • Monitor CPU usage in Activity Monitor

🔍 ADVANCED TROUBLESHOOTING
===========================

Log Analysis:
• Open Console.app (Applications > Utilities)
• Search for "HourlyAudioPlayer"
• Look for error messages or warnings
• Check system.log for related entries

File System Issues:
• Verify audio directory exists: ~/Library/Application Support/HourlyAudioPlayer/
• Check file permissions: ls -la ~/Library/Application\ Support/HourlyAudioPlayer/
• Clear corrupted data: rm -rf ~/Library/Application\ Support/HourlyAudioPlayer/

Network Issues:
• Check internet connection for notifications
• Verify firewall settings
• Test with different network connections

Audio System Issues:
• Reset audio system: sudo killall coreaudiod
• Check audio drivers and hardware
• Test with different audio output devices

🆘 SUPPORT & FEEDBACK
=====================
• Check the project repository for updates
• Report issues with detailed logs
• Include system information (macOS version, hardware)
• Provide steps to reproduce problems

📋 KNOWN LIMITATIONS
====================
• Maximum file size: 2.5MB per audio file
• Supported formats: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG
• Requires macOS 12.0 or later
• Menu bar icon may not appear immediately after installation
• Some audio formats may require additional codecs

🔄 UPDATES
==========
• Check for updates regularly
• Backup your audio files before updating
• New versions may require re-granting permissions

For technical support, please provide:
• macOS version (System Information)
• App version: $VERSION
• Error messages from Console.app
• Steps to reproduce the issue
EOF

# Create troubleshooting script in docs folder
TROUBLESHOOT_SCRIPT="$DOCS_DIR/troubleshoot.sh"
cat > "$TROUBLESHOOT_SCRIPT" << 'EOF'
#!/bin/bash

# Hourly Audio Player Troubleshooting Script
# This script helps diagnose common issues

echo "🔧 Hourly Audio Player Troubleshooting Script"
echo "=============================================="
echo ""

# Check if app is running
echo "1. Checking if HourlyAudioPlayer is running..."
if pgrep -f "HourlyAudioPlayer" > /dev/null; then
    echo "   ✅ HourlyAudioPlayer is running"
    echo "   Process ID: $(pgrep -f "HourlyAudioPlayer")"
else
    echo "   ❌ HourlyAudioPlayer is not running"
    echo "   💡 Try launching the app from Applications"
fi
echo ""

# Check app installation
echo "2. Checking app installation..."
if [ -d "/Applications/HourlyAudioPlayer.app" ]; then
    echo "   ✅ App is installed in Applications"
    echo "   Version: $(defaults read /Applications/HourlyAudioPlayer.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "Unknown")"
else
    echo "   ❌ App not found in Applications"
    echo "   💡 Please install the app from the DMG"
fi
echo ""

# Check audio directory
echo "3. Checking audio file directory..."
AUDIO_DIR="$HOME/Library/Application Support/HourlyAudioPlayer"
if [ -d "$AUDIO_DIR" ]; then
    echo "   ✅ Audio directory exists: $AUDIO_DIR"
    AUDIO_COUNT=$(find "$AUDIO_DIR" -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" -o -name "*.aiff" | wc -l)
    echo "   📁 Audio files found: $AUDIO_COUNT"
    if [ $AUDIO_COUNT -gt 0 ]; then
        echo "   📋 Audio files:"
        find "$AUDIO_DIR" -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" -o -name "*.aiff" | head -5 | while read file; do
            echo "      • $(basename "$file")"
        done
    fi
else
    echo "   ❌ Audio directory not found"
    echo "   💡 This is normal for first-time users"
fi
echo ""

# Check permissions
echo "4. Checking system permissions..."
echo "   📋 Accessibility permissions:"
if sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "SELECT service, client FROM access WHERE service='kTCCServiceAccessibility' AND client LIKE '%HourlyAudioPlayer%';" 2>/dev/null | grep -q HourlyAudioPlayer; then
    echo "      ✅ Accessibility permissions granted"
else
    echo "      ❌ Accessibility permissions not granted"
    echo "      💡 Go to System Preferences > Security & Privacy > Privacy > Accessibility"
fi

echo "   📋 Notification permissions:"
if sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "SELECT service, client FROM access WHERE service='kTCCServiceNotifications' AND client LIKE '%HourlyAudioPlayer%';" 2>/dev/null | grep -q HourlyAudioPlayer; then
    echo "      ✅ Notification permissions granted"
else
    echo "      ❌ Notification permissions not granted"
    echo "      💡 Go to System Preferences > Notifications & Focus"
fi
echo ""

# Check system info
echo "5. System Information:"
echo "   🖥️  macOS Version: $(sw_vers -productVersion)"
echo "   🏗️  Architecture: $(uname -m)"
echo "   💾 Available Disk Space: $(df -h / | tail -1 | awk '{print $4}')"
echo ""

# Check audio system
echo "6. Audio System Status:"
if system_profiler SPAudioDataType | grep -q "Default Output Device"; then
    echo "   ✅ Audio system is working"
    echo "   🔊 Default Output: $(system_profiler SPAudioDataType | grep -A1 "Default Output Device" | tail -1 | sed 's/^[[:space:]]*//')"
else
    echo "   ❌ Audio system issues detected"
    echo "   💡 Try: sudo killall coreaudiod"
fi
echo ""

# Generate diagnostic report
echo "7. Generating diagnostic report..."
DIAGNOSTIC_FILE="$HOME/Desktop/HourlyAudioPlayer_Diagnostic_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "Hourly Audio Player Diagnostic Report"
    echo "Generated: $(date)"
    echo "======================================"
    echo ""
    echo "System Information:"
    echo "macOS Version: $(sw_vers -productVersion)"
    echo "Architecture: $(uname -m)"
    echo "Available Disk Space: $(df -h / | tail -1 | awk '{print $4}')"
    echo ""
    echo "App Status:"
    if pgrep -f "HourlyAudioPlayer" > /dev/null; then
        echo "Status: Running (PID: $(pgrep -f "HourlyAudioPlayer"))"
    else
        echo "Status: Not Running"
    fi
    echo ""
    echo "Installation:"
    if [ -d "/Applications/HourlyAudioPlayer.app" ]; then
        echo "Installed: Yes"
        echo "Version: $(defaults read /Applications/HourlyAudioPlayer.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "Unknown")"
    else
        echo "Installed: No"
    fi
    echo ""
    echo "Audio Files:"
    if [ -d "$AUDIO_DIR" ]; then
        echo "Directory: $AUDIO_DIR"
        echo "File Count: $(find "$AUDIO_DIR" -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" -o -name "*.aiff" | wc -l)"
    else
        echo "Directory: Not found"
    fi
    echo ""
    echo "Recent Logs:"
    log show --predicate 'process == "HourlyAudioPlayer"' --last 1h --style compact 2>/dev/null | tail -10 || echo "No recent logs found"
} > "$DIAGNOSTIC_FILE"

echo "   📄 Diagnostic report saved to: $DIAGNOSTIC_FILE"
echo ""

echo "🎯 TROUBLESHOOTING RECOMMENDATIONS"
echo "=================================="
echo ""

if ! pgrep -f "HourlyAudioPlayer" > /dev/null; then
    echo "❌ App not running:"
    echo "   1. Launch HourlyAudioPlayer from Applications"
    echo "   2. Check if it appears in the menu bar"
    echo "   3. If not, check System Preferences > Security & Privacy"
    echo ""
fi

if [ ! -d "/Applications/HourlyAudioPlayer.app" ]; then
    echo "❌ App not installed:"
    echo "   1. Download and install from the DMG file"
    echo "   2. Drag to Applications folder"
    echo "   3. Launch from Applications or Spotlight"
    echo ""
fi

if [ $AUDIO_COUNT -eq 0 ] 2>/dev/null; then
    echo "❌ No audio files configured:"
    echo "   1. Click the menu bar icon"
    echo "   2. Select 'Open Settings'"
    echo "   3. Add audio files for each hour"
    echo "   4. Use 'Test Current Hour' to verify"
    echo ""
fi

echo "✅ If issues persist:"
echo "   1. Restart the app"
echo "   2. Reboot your Mac"
echo "   3. Check Console.app for error messages"
echo "   4. Contact support with the diagnostic report"
echo ""

echo "🔧 Quick Fixes:"
echo "   • Reset audio: sudo killall coreaudiod"
echo "   • Clear app data: rm -rf '$AUDIO_DIR'"
echo "   • Reinstall app: Delete from Applications and reinstall"
echo ""

echo "📞 Support Information:"
echo "   • Include the diagnostic report when contacting support"
echo "   • Provide steps to reproduce the issue"
echo "   • Include your macOS version and hardware info"
echo ""

echo "Troubleshooting complete! 🎉"
EOF

chmod +x "$TROUBLESHOOT_SCRIPT"


# Create quick start guide in docs folder
QUICK_START="$DOCS_DIR/QUICK_START_GUIDE.txt"
cat > "$QUICK_START" << EOF
Hourly Audio Player - Quick Start Guide
=======================================

🚀 GETTING STARTED (5 minutes)

1. INSTALLATION
   • Double-click the DMG file
   • Drag HourlyAudioPlayer.app to Applications
   • Launch from Applications or Spotlight

2. FIRST LAUNCH
   • Look for speaker icon in menu bar (top-right)
   • Click the icon to open the app
   • Grant permissions when prompted

3. ADD AUDIO FILES
   • Click "Open Settings" in the app
   • Click "Add Audio" for any hour (0-23)
   • Select your audio file (MP3, WAV, M4A, etc.)
   • Repeat for other hours as needed

4. TEST PLAYBACK
   • Click "Test Current Hour" to verify audio
   • Check that sound plays correctly
   • Adjust system volume if needed

5. AUTOMATIC PLAYBACK
   • App will play audio at the top of each hour
   • You'll see notifications when audio plays
   • No further action needed!

🎵 AUDIO FILE TIPS
==================
• Supported formats: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG
• Maximum file size: 2.5MB per file
• Smart naming: "12_midday.mp3" automatically assigns to 12:00
• Use short, clear audio clips for best results

⚡ QUICK TROUBLESHOOTING
========================
• No menu bar icon? Check System Preferences > Security & Privacy
• No sound? Use "Test Current Hour" and check system volume
• No notifications? Check System Preferences > Notifications & Focus
• App crashes? Restart the app or reboot your Mac

🔧 ADVANCED FEATURES
====================
• Debug mode: Run with debug flag for development
• File validation: Automatic checking of file formats and sizes
• Missing file detection: Falls back to system sounds
• Real-time clock: Always shows current time
• Persistent storage: Settings saved between app launches

📞 NEED HELP?
=============
• Run the included troubleshoot.sh script for diagnostics
• Check the included RELEASE_NOTES for detailed troubleshooting
• Use the included QUICK_START_GUIDE for setup help
• Include diagnostic report when contacting support

Happy listening! 🎧
EOF

# Create release checklist in docs folder
RELEASE_CHECKLIST="$DOCS_DIR/RELEASE_CHECKLIST.txt"
cat > "$RELEASE_CHECKLIST" << EOF
Hourly Audio Player Release Checklist
=====================================

📋 PRE-RELEASE CHECKLIST
========================
□ All tests pass (./run_tests.sh)
□ App builds successfully in Release mode
□ No compiler warnings or errors
□ All features tested manually
□ Documentation updated
□ Version number incremented
□ Release notes reviewed

🧪 TESTING CHECKLIST
====================
□ App launches without errors
□ Menu bar icon appears
□ Settings window opens
□ Audio file selection works
□ File validation works (size, format)
□ Audio playback works
□ Notifications appear
□ Test Current Hour works
□ App persists between launches
□ Quit functionality works

📦 DISTRIBUTION CHECKLIST
=========================
□ DMG file created successfully
□ ZIP file created successfully
□ Release notes included
□ Troubleshooting script included
□ Quick start guide included
□ All files in releases/ directory
□ File sizes reasonable (< 50MB total)
□ No sensitive information in files

🔍 FINAL VERIFICATION
=====================
□ Test installation from DMG
□ Verify app works on clean system
□ Check all permissions work
□ Confirm audio playback
□ Test notification delivery
□ Verify menu bar functionality
□ Check app termination
□ Validate file cleanup

📊 RELEASE METRICS
==================
Version: $VERSION
Build Date: $BUILD_DATE
DMG Size: $DMG_SIZE
ZIP Size: $ZIP_SIZE
Total Files: 4 (DMG, ZIP, Release Notes, Troubleshoot Script)

✅ READY FOR DISTRIBUTION
========================
All checks completed successfully!
EOF

# Create temporary directory for DMG contents
TEMP_DMG_DIR="/tmp/HourlyAudioPlayer_DMG"
rm -rf "$TEMP_DMG_DIR"
mkdir -p "$TEMP_DMG_DIR"

# Copy app to temp directory
cp -R "$RELEASE_PACKAGE.app" "$TEMP_DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DMG_DIR/Applications"

# Copy documentation files to DMG from docs folder
cp "$RELEASE_NOTES" "$TEMP_DMG_DIR/"
cp "$TROUBLESHOOT_SCRIPT" "$TEMP_DMG_DIR/"
cp "$QUICK_START" "$TEMP_DMG_DIR/"
cp "$RELEASE_CHECKLIST" "$TEMP_DMG_DIR/"

# Create DMG
print_status "Creating DMG for distribution..."
hdiutil create -volname "Hourly Audio Player v$VERSION" -srcfolder "$TEMP_DMG_DIR" -ov -format UDZO "$DMG_PATH"

# Clean up temp directory
rm -rf "$TEMP_DMG_DIR"

# Create ZIP archive as alternative distribution method
print_status "Creating ZIP archive..."
ZIP_NAME="$RELEASE_NAME.zip"
ZIP_PATH="$RELEASE_DIR/$ZIP_NAME"
cd "$RELEASE_DIR"
zip -r "$ZIP_NAME" "$RELEASE_NAME.app" > /dev/null
cd ..
# Add documentation files from docs folder to ZIP
cd "$DOCS_DIR"
zip -r "../$RELEASE_DIR/$ZIP_NAME" "RELEASE_NOTES_v$VERSION.txt" "troubleshoot.sh" "QUICK_START_GUIDE.txt" "RELEASE_CHECKLIST.txt" > /dev/null
cd ..

# Get file sizes
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)

# Optional: Open release directory in Finder
if command -v open &> /dev/null; then
    print_status "Opening release directory in Finder..."
    open "$RELEASE_DIR"
fi

# Display final summary with all files
print_success "🎉 Release build completed successfully!"
echo ""
print_header "Release Package Created:"
echo "  📦 DMG: $DMG_NAME ($DMG_SIZE)"
echo "  📦 ZIP: $ZIP_NAME ($ZIP_SIZE)"
echo "  📄 Release Notes: RELEASE_NOTES_v$VERSION.txt"
echo "  🔧 Troubleshoot Script: troubleshoot.sh"
echo "  🚀 Quick Start Guide: QUICK_START_GUIDE.txt"
echo "  📋 Release Checklist: RELEASE_CHECKLIST.txt"
echo ""
print_header "Release Location:"
echo "  📁 $RELEASE_DIR/"
echo ""
print_header "Documentation Location:"
echo "  📁 $DOCS_DIR/"
echo ""
print_header "Distribution Files:"
echo "  🎵 $DMG_PATH"
echo "  🎵 $ZIP_PATH"
echo "  📋 $RELEASE_NOTES"
echo "  🔧 $TROUBLESHOOT_SCRIPT"
echo "  🚀 $QUICK_START"
echo "  📋 $RELEASE_CHECKLIST"
echo ""
print_status "You can now distribute the DMG or ZIP file to users."
print_status "The DMG provides the best user experience for installation."
print_status "All documentation and troubleshooting tools are included in the packages."
