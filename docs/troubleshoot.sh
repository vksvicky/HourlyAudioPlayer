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
