# Hourly Audio Player - User Guide

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Getting Started](#getting-started)
4. [Features](#features)
5. [Configuration](#configuration)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Usage](#advanced-usage)
8. [FAQ](#faq)

## Introduction

Hourly Audio Player is a macOS menu bar application that plays custom audio files at the top of each hour, helping you stay aware of time throughout your day. It's perfect for time management, meditation reminders, or any hourly audio notifications.

### Key Benefits

- **Time Awareness**: Stay connected to the passage of time
- **Customizable**: Use your own audio files for different hours
- **Unobtrusive**: Runs quietly in the background
- **Reliable**: Automatic playback with system sound fallback
- **User-Friendly**: Simple, intuitive interface

## Installation

### System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Processor**: Intel or Apple Silicon
- **Storage**: 50MB available space
- **Audio**: Audio output device
- **Internet**: For notifications (optional)

### Installation Steps

1. **Download**: Get the latest version from the releases page
2. **Mount**: Double-click the DMG file to mount it
3. **Install**: Drag `HourlyAudioPlayer.app` to your Applications folder
4. **Launch**: Open the app from Applications or Spotlight
5. **Permissions**: Grant necessary permissions when prompted

### First Launch

When you first launch the app:
1. Look for the speaker icon in your menu bar (top-right)
2. Click the icon to open the app interface
3. Grant accessibility permissions if prompted
4. Grant notification permissions if prompted

## Getting Started

### Basic Setup (5 Minutes)

1. **Open Settings**: Click the menu bar icon → "Open Settings"
2. **Add Audio Files**: Click "Add Audio" for any hour (0-23)
3. **Select Files**: Choose your audio files (MP3, WAV, M4A, etc.)
4. **Test Playback**: Click "Test Current Hour" to verify audio
5. **Automatic Playback**: Audio will play automatically at the top of each hour

### Quick Start Tips

- **Smart Naming**: Name files like "12_midday.mp3" for automatic hour assignment
- **File Size**: Keep files under 2.5MB for best performance
- **Format**: Use MP3, WAV, or M4A for best compatibility
- **Length**: Short clips (5-30 seconds) work best

## Features

### Core Features

#### 🎵 Audio Playback
- **Automatic**: Plays at the top of each hour
- **Manual**: Test current hour audio anytime
- **Fallback**: Uses system sounds when no custom audio is set
- **Formats**: Supports MP3, WAV, M4A, AIFF, AAC, FLAC, OGG

#### ⏰ Time Management
- **24-Hour Support**: Configure audio for any hour (0:00 - 23:00)
- **Real-Time Clock**: Always shows current time
- **Next Audio Display**: Shows when next audio will play
- **Precise Timing**: Plays exactly at the top of each hour

#### 🔔 Notifications
- **Audio Notifications**: Visual notifications when audio plays
- **Missing File Alerts**: Warns when audio files are missing
- **System Integration**: Uses macOS notification system

#### 📁 File Management
- **Smart Import**: Automatically detects hour from filename
- **File Validation**: Checks format and size before importing
- **Persistent Storage**: Files stored in app's Documents directory
- **Easy Removal**: Remove audio files with one click

### Advanced Features

#### 🐛 Debug Mode
- **Development Testing**: Additional test buttons in debug builds
- **Notification Testing**: Test notifications with audio
- **Logging**: Detailed logging for troubleshooting

#### 🔧 File Validation
- **Size Limits**: Maximum 2.5MB per file
- **Format Checking**: Validates supported audio formats
- **Error Handling**: Graceful handling of corrupted files

#### 💾 Data Persistence
- **Settings Storage**: All settings saved between launches
- **File Management**: Audio files persist across app restarts
- **User Preferences**: Remembers last selected directory

## Configuration

### Audio File Setup

#### Adding Audio Files

1. **Open Settings**: Click menu bar icon → "Open Settings"
2. **Select Hour**: Click "Add Audio" for desired hour
3. **Choose File**: Select audio file from file picker
4. **Automatic Assignment**: File automatically assigned to selected hour

#### Smart Filename Detection

The app automatically detects hour from filename patterns:
- `12_midday.mp3` → 12:00
- `12.mp3` → 12:00
- `hour12.mp3` → 12:00
- `12hour.mp3` → 12:00

#### File Requirements

- **Formats**: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG
- **Size**: Maximum 2.5MB per file
- **Quality**: Any quality supported by macOS
- **Length**: Recommended 5-30 seconds

### Hour Configuration

#### 24-Hour Grid
- **Visual Layout**: 4x6 grid showing all 24 hours
- **Current Status**: Shows assigned audio or "macOS Default"
- **Easy Management**: Add/remove audio with one click
- **Real-Time Updates**: Changes reflected immediately

#### Default Behavior
- **No Custom Audio**: Plays system sound (beep)
- **Missing Files**: Falls back to system sound
- **Error Handling**: Graceful fallback for any issues

### Settings Management

#### Persistent Storage
- **Location**: `~/Documents/HourlyAudioPlayer/`
- **Automatic**: Files copied to app directory
- **Backup**: Original files remain in original location
- **Cleanup**: Removed files deleted from app directory

#### User Preferences
- **Last Directory**: Remembers last selected folder
- **File Associations**: Maintains hour-to-file mappings
- **Settings**: All preferences saved automatically

## Troubleshooting

### Common Issues

#### App Not Appearing in Menu Bar
**Symptoms**: No speaker icon in menu bar
**Solutions**:
1. Check System Preferences > Security & Privacy > Privacy > Accessibility
2. Ensure HourlyAudioPlayer has accessibility permissions
3. Restart the app or reboot your Mac
4. Check if the app is running in Activity Monitor

#### Audio Not Playing
**Symptoms**: No sound when audio should play
**Solutions**:
1. Verify audio files are assigned to the current hour
2. Check System Preferences > Sound > Output
3. Ensure audio files are in supported formats
4. Use "Test Current Hour" to verify playback
5. Check Console.app for error messages

#### Notifications Not Working
**Symptoms**: No visual notifications appear
**Solutions**:
1. Go to System Preferences > Notifications & Focus
2. Find HourlyAudioPlayer and enable notifications
3. Check "Allow notifications" is turned on
4. Verify notification permissions in System Preferences

#### Audio Files Not Loading
**Symptoms**: Files won't import or show errors
**Solutions**:
1. Check file format (MP3, WAV, M4A, AIFF, AAC, FLAC, OGG)
2. Verify file size is under 2.5MB
3. Ensure file is not corrupted
4. Check file permissions (read access required)

### Advanced Troubleshooting

#### Diagnostic Tools
- **Troubleshoot Script**: Run included `troubleshoot.sh` script
- **Console Logs**: Check Console.app for error messages
- **Activity Monitor**: Monitor app performance and resource usage

#### System-Level Issues
- **Audio System**: Reset with `sudo killall coreaudiod`
- **Permissions**: Re-grant accessibility and notification permissions
- **File System**: Check disk space and file permissions
- **Network**: Verify internet connection for notifications

## Advanced Usage

### Debug Mode

#### Enabling Debug Mode
1. Build app with debug flag: `./build_and_run.sh minor debug`
2. Additional test buttons appear in settings
3. Enhanced logging and error reporting

#### Debug Features
- **Test Notification**: Test notifications with audio
- **Test Current Hour**: Manual audio playback testing
- **Enhanced Logging**: Detailed system logs
- **Error Reporting**: Comprehensive error information

### File Management

#### Manual File Management
- **Location**: `~/Documents/HourlyAudioPlayer/`
- **Backup**: Copy files before making changes
- **Cleanup**: Remove unused files to save space
- **Organization**: Use descriptive filenames

#### Batch Operations
- **Multiple Files**: Import multiple files at once
- **Bulk Assignment**: Assign files to multiple hours
- **File Validation**: Check all files for issues

### Performance Optimization

#### Best Practices
- **File Size**: Keep audio files under 2.5MB
- **Format**: Use MP3 or M4A for best performance
- **Length**: Short clips (5-30 seconds) work best
- **Quality**: Balance quality vs. file size

#### System Resources
- **Memory**: App uses minimal memory
- **CPU**: Low CPU usage during operation
- **Storage**: Audio files stored locally
- **Network**: Minimal network usage

## FAQ

### General Questions

**Q: What audio formats are supported?**
A: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG

**Q: What's the maximum file size?**
A: 2.5MB per audio file

**Q: Can I use the same audio file for multiple hours?**
A: Yes, you can assign the same file to multiple hours

**Q: Does the app work without internet?**
A: Yes, but notifications may not work without internet

### Technical Questions

**Q: What macOS versions are supported?**
A: macOS 12.0 (Monterey) or later

**Q: Does it work on both Intel and Apple Silicon?**
A: Yes, it's a universal binary

**Q: Can I run multiple instances?**
A: No, only one instance can run at a time

**Q: How much disk space does it use?**
A: About 50MB for the app, plus your audio files

### Usage Questions

**Q: Can I pause or stop the hourly audio?**
A: The app plays audio automatically, but you can remove audio files to stop playback

**Q: What happens if I'm not at my computer?**
A: The app continues to play audio at the scheduled times

**Q: Can I set different volumes for different hours?**
A: Not currently, but this is planned for future versions

**Q: How do I update the app?**
A: Download the latest version and replace the old app

### Troubleshooting Questions

**Q: The app won't start. What should I do?**
A: Check System Preferences > Security & Privacy for permissions

**Q: Audio files won't import. Why?**
A: Check file format, size, and permissions

**Q: Notifications aren't working. How do I fix it?**
A: Go to System Preferences > Notifications & Focus and enable notifications

**Q: The app crashes. What can I do?**
A: Check Console.app for error messages and contact support

## Support

### Getting Help

1. **Check Documentation**: Review this guide and troubleshooting section
2. **Run Diagnostics**: Use the included troubleshoot script
3. **Check Logs**: Look at Console.app for error messages
4. **Contact Support**: Email support@cycleruncode.club

### Reporting Issues

When reporting issues, please include:
- macOS version
- App version
- Steps to reproduce the problem
- Error messages from Console.app
- Screenshots if applicable

### Feature Requests

We welcome feature requests! Please email support@cycleruncode.club with:
- Clear description of the feature
- Use case and benefits
- Priority level (Low/Medium/High)

---

**Happy listening! 🎧**

For the latest updates and support, visit: https://cycleruncode.club
