# Hourly Audio Player - Frequently Asked Questions

## 🎵 General Questions

### What is Hourly Audio Player?
Hourly Audio Player is a macOS menu bar application that plays custom audio files at the top of each hour, helping you stay aware of time throughout your day. It's perfect for time management, meditation reminders, or any hourly audio notifications.

### What audio formats are supported?
The app supports the following audio formats:
- **MP3** - Most common format, recommended
- **WAV** - Uncompressed audio, high quality
- **M4A** - Apple's audio format, good compression
- **AIFF** - Apple's uncompressed format
- **AAC** - Advanced audio coding
- **FLAC** - Free lossless audio codec
- **OGG** - Open source audio format

### What's the maximum file size?
The maximum file size per audio file is **2.5MB**. This limit ensures good performance and prevents the app from using too much disk space.

### Can I use the same audio file for multiple hours?
Yes, you can assign the same audio file to multiple hours. The app will copy the file for each hour assignment.

### Does the app work without internet?
Yes, the app works without internet for audio playback. However, notifications may not work without internet connection.

## 💻 Technical Questions

### What macOS versions are supported?
The app requires **macOS 12.0 (Monterey) or later**. This includes:
- macOS 12.0 (Monterey)
- macOS 13.0 (Ventura)
- macOS 14.0 (Sonoma)
- macOS 15.0 (Sequoia)

### Does it work on both Intel and Apple Silicon?
Yes, the app is a universal binary that works on both Intel and Apple Silicon Macs.

### Can I run multiple instances?
No, only one instance of the app can run at a time. If you try to launch a second instance, it will bring the existing instance to the foreground.

### How much disk space does it use?
The app itself uses about 50MB of disk space, plus the size of your audio files. Audio files are stored in the app's Documents directory.

### What permissions does the app need?
The app requires:
- **Accessibility permissions** - To display the menu bar icon
- **Notification permissions** - To show audio playback notifications
- **File access permissions** - To read your audio files

## 🎯 Usage Questions

### How do I add audio files?
1. Click the speaker icon in your menu bar
2. Click "Open Settings"
3. Click "Add Audio" for any hour (0-23)
4. Select your audio file from the file picker
5. The file will be automatically assigned to that hour

### Can I pause or stop the hourly audio?
The app plays audio automatically at the scheduled times. To stop audio for a specific hour, remove the audio file assignment in settings.

### What happens if I'm not at my computer?
The app continues to play audio at the scheduled times even if you're not actively using your computer.

### Can I set different volumes for different hours?
Not currently, but this feature is planned for future versions. The app uses your system volume setting.

### How do I update the app?
1. Download the latest version from the releases page
2. Replace the old app in your Applications folder
3. Launch the new version
4. Your settings and audio files will be preserved

### Can I backup my audio files and settings?
Yes, your audio files are stored in `~/Documents/HourlyAudioPlayer/` and can be backed up like any other files. Settings are stored in the app's preferences.

## 🔧 Troubleshooting Questions

### The app won't start. What should I do?
1. Check System Preferences > Security & Privacy > Privacy > Accessibility
2. Ensure HourlyAudioPlayer has accessibility permissions
3. Try launching from Applications folder
4. Restart your Mac if the issue persists

### Audio files won't import. Why?
Common reasons include:
- **Unsupported format** - Use MP3, WAV, M4A, AIFF, AAC, FLAC, or OGG
- **File too large** - Keep files under 2.5MB
- **File corrupted** - Try a different audio file
- **Permission issues** - Ensure you have read access to the file

### Notifications aren't working. How do I fix it?
1. Go to System Preferences > Notifications & Focus
2. Find HourlyAudioPlayer in the list
3. Ensure "Allow notifications" is enabled
4. Check that Focus mode isn't blocking notifications

### The app crashes. What can I do?
1. Check Console.app for error messages
2. Restart the app
3. Clear app data: `rm -rf ~/Library/Application\ Support/HourlyAudioPlayer/`
4. Reinstall the app if the issue persists

### Audio plays but I can't hear it. Why?
1. Check your system volume
2. Verify the correct audio output device is selected
3. Test with other applications
4. Try resetting the audio system: `sudo killall coreaudiod`

### The menu bar icon disappeared. How do I get it back?
1. Check if the app is still running in Activity Monitor
2. Restart the app
3. Check accessibility permissions in System Preferences
4. Reboot your Mac if necessary

## 🚀 Advanced Questions

### Can I use the app for development or testing?
Yes, the app has a debug mode that provides additional features:
- Additional test buttons in settings
- Enhanced logging and error reporting
- Notification testing functionality
- Detailed system information

To enable debug mode, build the app with the debug flag.

### How do I customize the app's behavior?
The app is designed to be simple and focused. Current customization options include:
- Audio file selection for each hour
- Test current hour functionality
- Debug mode for development

More customization options are planned for future versions.

### Can I integrate with other apps or services?
Currently, the app is standalone. Future versions may include:
- Shortcuts app integration
- Calendar integration
- Widget support
- Cloud sync capabilities

### How do I contribute to the project?
The project is open source and welcomes contributions:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Where can I get help or report issues?
- **GitHub Issues**: For bug reports and feature requests
- **Email**: support@cycleruncode.club
- **Documentation**: Check the user guide and troubleshooting guide

## 🔮 Future Features

### What features are planned?
Planned features include:
- Volume control per hour
- Audio file preview
- Custom notification sounds
- Snooze functionality
- Multiple audio profiles
- Integration with system calendar
- Widget support
- Shortcuts app integration

### When will new features be released?
New features are released as they're developed and tested. Follow the project on GitHub for updates and release announcements.

### Can I request specific features?
Yes! Feature requests are welcome. Please email support@cycleruncode.club with:
- Clear description of the feature
- Use case and benefits
- Priority level (Low/Medium/High)

## 📞 Support

### How do I contact support?
- **Email**: support@cycleruncode.club
- **GitHub Issues**: For bug reports and feature requests
- **Documentation**: Check the user guide and troubleshooting guide

### What information should I include when contacting support?
When contacting support, please include:
- **macOS version** (System Information > Software)
- **App version** (About dialog or Info.plist)
- **Error messages** (from Console.app)
- **Steps to reproduce** the issue
- **System information** (hardware and software details)

### How quickly will I get a response?
We aim to respond to support requests within 24-48 hours. For urgent issues, please mark them as high priority.

---

**Still have questions?** Contact support@cycleruncode.club and we'll be happy to help!
