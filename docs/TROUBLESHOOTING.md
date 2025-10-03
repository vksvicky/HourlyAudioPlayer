# Hourly Audio Player - Troubleshooting Guide

## 🔧 Quick Diagnostics

### Automated Troubleshooting Script
Run the included troubleshooting script for automatic diagnostics:
```bash
./troubleshoot.sh
```

This script will:
- Check if the app is running
- Verify installation
- Check audio file directory
- Validate system permissions
- Generate a diagnostic report

## 🚨 Common Issues & Solutions

### 1. App Not Appearing in Menu Bar

**Symptoms:**
- No speaker icon in menu bar
- App appears to be running but no interface

**Solutions:**
1. **Check Accessibility Permissions**
   - Go to System Preferences > Security & Privacy > Privacy > Accessibility
   - Ensure HourlyAudioPlayer is checked
   - If not listed, add it manually

2. **Restart the App**
   - Quit the app completely
   - Launch from Applications folder
   - Check menu bar for icon

3. **Check System Status**
   - Open Activity Monitor
   - Look for HourlyAudioPlayer process
   - If running but no icon, restart the app

4. **System Restart**
   - Restart your Mac
   - Launch the app after restart
   - Check menu bar for icon

### 2. Audio Not Playing

**Symptoms:**
- No sound when audio should play
- Test Current Hour doesn't work
- Silent playback

**Solutions:**
1. **Check Audio Output**
   - Go to System Preferences > Sound > Output
   - Verify correct audio device is selected
   - Test with other applications

2. **Verify Audio Files**
   - Check that audio files are assigned to current hour
   - Use "Test Current Hour" to verify playback
   - Ensure files are in supported formats

3. **Check File Format**
   - Supported: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG
   - Unsupported formats won't play
   - Convert files to supported format

4. **File Size Check**
   - Maximum file size: 2.5MB
   - Large files may not load properly
   - Compress files if necessary

5. **System Audio Reset**
   ```bash
   sudo killall coreaudiod
   ```
   - This resets the audio system
   - May require administrator password

### 3. Notifications Not Working

**Symptoms:**
- No visual notifications appear
- Audio plays but no notification
- Notification permissions denied

**Solutions:**
1. **Check Notification Settings**
   - Go to System Preferences > Notifications & Focus
   - Find HourlyAudioPlayer in the list
   - Ensure "Allow notifications" is enabled

2. **Grant Permissions**
   - When prompted, click "Allow" for notifications
   - If denied, manually enable in System Preferences
   - Restart the app after granting permissions

3. **Check Focus Mode**
   - Ensure Focus mode isn't blocking notifications
   - Check Do Not Disturb settings
   - Temporarily disable Focus to test

4. **Internet Connection**
   - Notifications may require internet connection
   - Check network connectivity
   - Test with other apps that use notifications

### 4. Audio Files Not Loading

**Symptoms:**
- Files won't import
- Import errors or failures
- Files appear but don't play

**Solutions:**
1. **File Format Validation**
   - Check file extension matches content
   - Use supported formats: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG
   - Convert unsupported formats

2. **File Size Check**
   - Maximum size: 2.5MB per file
   - Check file size in Finder
   - Compress large files

3. **File Permissions**
   - Ensure you have read access to files
   - Check file permissions in Finder
   - Move files to accessible location

4. **File Corruption**
   - Test files in other applications
   - Re-download or re-encode files
   - Use different source files

5. **Storage Space**
   - Check available disk space
   - Ensure sufficient space for file copying
   - Free up space if necessary

### 5. App Crashes or Freezes

**Symptoms:**
- App quits unexpectedly
- Interface becomes unresponsive
- System becomes slow

**Solutions:**
1. **Check Console Logs**
   - Open Console.app (Applications > Utilities)
   - Search for "HourlyAudioPlayer"
   - Look for error messages or crashes

2. **Restart the App**
   - Force quit the app (Cmd+Option+Esc)
   - Wait a few seconds
   - Launch the app again

3. **Clear App Data**
   ```bash
   rm -rf ~/Library/Application\ Support/HourlyAudioPlayer/
   ```
   - This removes all app data
   - You'll need to reconfigure settings

4. **System Resources**
   - Check Activity Monitor for high CPU/memory usage
   - Close other applications
   - Restart your Mac if necessary

5. **Reinstall the App**
   - Delete the app from Applications
   - Download fresh copy
   - Install and configure again

### 6. Performance Issues

**Symptoms:**
- Slow app response
- High CPU usage
- System lag

**Solutions:**
1. **Close Other Audio Apps**
   - Close other audio applications
   - Free up audio system resources
   - Test with minimal apps running

2. **Check Disk Space**
   - Ensure sufficient free disk space
   - Clean up unnecessary files
   - Maintain at least 1GB free space

3. **Restart App Periodically**
   - Quit and restart the app daily
   - Clear memory usage
   - Refresh system resources

4. **Monitor Resource Usage**
   - Use Activity Monitor to check CPU/memory
   - Look for unusual spikes
   - Contact support if issues persist

## 🔍 Advanced Troubleshooting

### Log Analysis

#### Console.app
1. Open Console.app (Applications > Utilities)
2. Search for "HourlyAudioPlayer"
3. Look for error messages or warnings
4. Check system.log for related entries

#### Common Log Messages
- **"Audio file does not exist"**: File moved or deleted
- **"Failed to play audio file"**: File corrupted or unsupported
- **"Notification permission error"**: Permission denied
- **"File too large"**: File exceeds 2.5MB limit

### File System Issues

#### Audio Directory
- **Location**: `~/Documents/HourlyAudioPlayer/`
- **Check existence**: `ls -la ~/Documents/HourlyAudioPlayer/`
- **Check permissions**: `ls -la ~/Documents/HourlyAudioPlayer/`
- **Clear corrupted data**: `rm -rf ~/Documents/HourlyAudioPlayer/`

#### File Permissions
```bash
# Check file permissions
ls -la ~/Documents/HourlyAudioPlayer/

# Fix permissions if needed
chmod 755 ~/Documents/HourlyAudioPlayer/
chmod 644 ~/Documents/HourlyAudioPlayer/*
```

### Network Issues

#### Internet Connection
- Check internet connectivity
- Test with other network-dependent apps
- Verify firewall settings
- Test with different network connections

#### Notification Services
- Check Apple's notification servers
- Verify system time is correct
- Test with other notification apps

### Audio System Issues

#### Audio System Reset
```bash
# Reset audio system
sudo killall coreaudiod

# Check audio devices
system_profiler SPAudioDataType
```

#### Audio Driver Issues
- Check audio drivers and hardware
- Test with different audio output devices
- Verify audio hardware is working
- Update audio drivers if necessary

## 🛠️ Diagnostic Tools

### Built-in Diagnostics

#### Troubleshoot Script
```bash
./troubleshoot.sh
```

#### Test Current Hour
- Use "Test Current Hour" button in settings
- Verify audio playback
- Check for error messages

#### Debug Mode
- Build with debug flag: `./build_and_run.sh minor debug`
- Additional test buttons available
- Enhanced logging and error reporting

### System Diagnostics

#### Activity Monitor
- Monitor CPU and memory usage
- Check for resource-intensive processes
- Identify performance bottlenecks

#### Console.app
- View system and application logs
- Search for error messages
- Monitor app behavior

#### System Information
- Check macOS version compatibility
- Verify hardware specifications
- Identify potential compatibility issues

## 📞 Getting Help

### Before Contacting Support

1. **Run Diagnostics**
   - Use the troubleshooting script
   - Check Console.app for errors
   - Test with minimal configuration

2. **Document the Issue**
   - Note exact steps to reproduce
   - Record error messages
   - Take screenshots if helpful

3. **Try Basic Solutions**
   - Restart the app
   - Check permissions
   - Verify file formats

### Contacting Support

#### Information to Include
- **macOS Version**: System Information > Software
- **App Version**: About dialog or Info.plist
- **Error Messages**: From Console.app
- **Steps to Reproduce**: Detailed description
- **System Information**: Hardware and software details

#### Support Channels
- **Email**: support@cycleruncode.club
- **Subject**: `[Troubleshooting] Brief description`
- **Response Time**: Within 24-48 hours

### Community Support

#### GitHub Issues
- Check existing issues
- Create new issue if needed
- Provide detailed information
- Follow issue templates

#### Documentation
- Check this troubleshooting guide
- Review user guide and FAQ
- Search for similar issues

## 🔄 Prevention

### Best Practices

1. **Regular Maintenance**
   - Restart the app periodically
   - Keep macOS updated
   - Monitor system resources

2. **File Management**
   - Use supported audio formats
   - Keep files under 2.5MB
   - Organize files properly

3. **System Health**
   - Maintain sufficient disk space
   - Keep system updated
   - Monitor system performance

4. **Backup**
   - Backup audio files
   - Export settings if possible
   - Keep app installation files

### Monitoring

#### Regular Checks
- Verify app is running
- Check audio playback
- Monitor system resources
- Review error logs

#### Proactive Maintenance
- Update app when available
- Clean up old audio files
- Monitor disk space
- Check system updates

---

**Need more help?** Contact support@cycleruncode.club with detailed information about your issue.
