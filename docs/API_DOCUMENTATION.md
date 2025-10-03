# Hourly Audio Player - API Documentation

## 📚 Overview

This document provides comprehensive API documentation for the Hourly Audio Player project, including class interfaces, method signatures, and usage examples.

## 🏗️ Architecture

### Core Components

#### HourlyAudioPlayerApp
Main application entry point and lifecycle management.

#### MenuBarView
Main user interface displayed in the menu bar popover.

#### ContentView
Settings and configuration interface.

#### HourlyTimer
Core timing and scheduling logic.

#### AudioFileManager
Audio file management and storage.

#### AudioManager
Audio playback control and management.

## 🎯 HourlyAudioPlayerApp

### Overview
Main application class that manages the app lifecycle, menu bar integration, and popover display.

### Properties

#### `shared`
```swift
static let shared = HourlyAudioPlayerApp()
```
Shared instance of the application.

#### `statusItem`
```swift
private var statusItem: NSStatusItem?
```
The status bar item for the menu bar.

#### `popover`
```swift
private var popover: NSPopover?
```
The popover displayed when clicking the menu bar icon.

### Methods

#### `applicationDidFinishLaunching(_:)`
```swift
func applicationDidFinishLaunching(_ notification: Notification)
```
Called when the application finishes launching. Sets up the menu bar item and popover.

**Parameters:**
- `notification`: The launch notification

#### `createMenuBarItem()`
```swift
private func createMenuBarItem()
```
Creates and configures the menu bar status item.

#### `showPopover()`
```swift
private func showPopover()
```
Shows the popover when the menu bar item is clicked.

#### `hidePopover()`
```swift
private func hidePopover()
```
Hides the popover when clicking outside of it.

## 🎵 MenuBarView

### Overview
Main user interface displayed in the menu bar popover, showing current time, next audio time, and navigation options.

### Properties

#### `hourlyTimer`
```swift
@StateObject private var hourlyTimer = HourlyTimer.shared
```
Shared instance of the hourly timer.

#### `showSettings`
```swift
@State private var showSettings = false
```
Controls whether the settings window is displayed.

#### `showAbout`
```swift
@State private var showAbout = false
```
Controls whether the about window is displayed.

### Methods

#### `body`
```swift
var body: some View
```
The main view body containing the popover content.

#### `formatTime(_:)`
```swift
private func formatTime(_ date: Date) -> String
```
Formats a date for display in the UI.

**Parameters:**
- `date`: The date to format

**Returns:**
- `String`: Formatted time string

## ⚙️ ContentView

### Overview
Settings and configuration interface allowing users to manage audio files for each hour.

### Properties

#### `audioFileManager`
```swift
@StateObject private var audioFileManager = AudioFileManager.shared
```
Shared instance of the audio file manager.

#### `selectedHour`
```swift
@State private var selectedHour: Int?
```
Currently selected hour for audio file management.

#### `showFilePicker`
```swift
@State private var showFilePicker = false
```
Controls whether the file picker is displayed.

### Methods

#### `body`
```swift
var body: some View
```
The main view body containing the settings interface.

#### `addAudioFile(for:)`
```swift
private func addAudioFile(for hour: Int)
```
Opens the file picker for a specific hour.

**Parameters:**
- `hour`: The hour to add audio for

#### `removeAudioFile(for:)`
```swift
private func removeAudioFile(for hour: Int)
```
Removes the audio file for a specific hour.

**Parameters:**
- `hour`: The hour to remove audio for

#### `testCurrentHour()`
```swift
private func testCurrentHour()
```
Tests audio playback for the current hour.

## ⏰ HourlyTimer

### Overview
Core timing and scheduling logic that manages hourly audio playback and notifications.

### Properties

#### `shared`
```swift
static let shared = HourlyTimer()
```
Shared instance of the hourly timer.

#### `currentTime`
```swift
@Published var currentTime: Date = Date()
```
Current time, updated every second.

#### `nextAudioTime`
```swift
@Published var nextAudioTime: Date?
```
Time when the next audio will play.

#### `isPlaying`
```swift
@Published var isPlaying: Bool = false
```
Whether audio is currently playing.

### Methods

#### `start()`
```swift
func start()
```
Starts the hourly timer and begins monitoring for audio playback times.

#### `stop()`
```swift
func stop()
```
Stops the hourly timer.

#### `playAudioForCurrentHour()`
```swift
func playAudioForCurrentHour()
```
Plays audio for the current hour.

#### `scheduleNotification(for:)`
```swift
private func scheduleNotification(for date: Date)
```
Schedules a notification for a specific time.

**Parameters:**
- `date`: The time to schedule the notification for

#### `requestNotificationPermission()`
```swift
private func requestNotificationPermission()
```
Requests notification permissions from the user.

## 📁 AudioFileManager

### Overview
Manages audio file storage, validation, and retrieval for each hour.

### Properties

#### `shared`
```swift
static let shared = AudioFileManager()
```
Shared instance of the audio file manager.

#### `audioFiles`
```swift
@Published var audioFiles: [Int: URL] = [:]
```
Dictionary mapping hours to audio file URLs.

#### `documentsDirectory`
```swift
private let documentsDirectory: URL
```
Directory where audio files are stored.

### Methods

#### `importAudioFile(_:for:)`
```swift
func importAudioFile(_ url: URL, for hour: Int) throws
```
Imports an audio file for a specific hour.

**Parameters:**
- `url`: The URL of the audio file to import
- `hour`: The hour to assign the file to

**Throws:**
- `AudioFileError.invalidFormat`: If the file format is not supported
- `AudioFileError.fileTooLarge`: If the file exceeds size limits
- `AudioFileError.importFailed`: If the import process fails

#### `removeAudioFile(for:)`
```swift
func removeAudioFile(for hour: Int)
```
Removes the audio file for a specific hour.

**Parameters:**
- `hour`: The hour to remove audio for

#### `getAudioFile(for:)`
```swift
func getAudioFile(for hour: Int) -> URL?
```
Gets the audio file URL for a specific hour.

**Parameters:**
- `hour`: The hour to get audio for

**Returns:**
- `URL?`: The audio file URL, or nil if no file is assigned

#### `validateAudioFile(_:)`
```swift
private func validateAudioFile(_ url: URL) throws
```
Validates an audio file for format and size.

**Parameters:**
- `url`: The URL of the file to validate

**Throws:**
- `AudioFileError.invalidFormat`: If the file format is not supported
- `AudioFileError.fileTooLarge`: If the file exceeds size limits

#### `detectHourFromFilename(_:)`
```swift
private func detectHourFromFilename(_ filename: String) -> Int?
```
Detects the hour from a filename using smart naming patterns.

**Parameters:**
- `filename`: The filename to analyze

**Returns:**
- `Int?`: The detected hour, or nil if no hour is detected

#### `loadAudioFiles()`
```swift
private func loadAudioFiles()
```
Loads audio files from the documents directory.

#### `saveAudioFiles()`
```swift
private func saveAudioFiles()
```
Saves audio file mappings to UserDefaults.

## 🎵 AudioManager

### Overview
Manages audio playback, volume control, and audio session management.

### Properties

#### `shared`
```swift
static let shared = AudioManager()
```
Shared instance of the audio manager.

#### `audioPlayer`
```swift
private var audioPlayer: AVAudioPlayer?
```
The current audio player instance.

#### `isPlaying`
```swift
@Published var isPlaying: Bool = false
```
Whether audio is currently playing.

### Methods

#### `playAudio(from:)`
```swift
func playAudio(from url: URL) throws
```
Plays audio from a specific URL.

**Parameters:**
- `url`: The URL of the audio file to play

**Throws:**
- `AudioError.playbackFailed`: If audio playback fails
- `AudioError.fileNotFound`: If the audio file is not found

#### `stopAudio()`
```swift
func stopAudio()
```
Stops the current audio playback.

#### `setVolume(_:)`
```swift
func setVolume(_ volume: Float)
```
Sets the audio playback volume.

**Parameters:**
- `volume`: The volume level (0.0 to 1.0)

#### `configureAudioSession()`
```swift
private func configureAudioSession()
```
Configures the audio session for playback.

## 🚨 Error Types

### AudioFileError
Errors related to audio file management.

```swift
enum AudioFileError: Error {
    case invalidFormat
    case fileTooLarge
    case importFailed
    case fileNotFound
    case permissionDenied
}
```

### AudioError
Errors related to audio playback.

```swift
enum AudioError: Error {
    case playbackFailed
    case fileNotFound
    case audioSessionError
    case volumeError
}
```

## 📊 Data Models

### AudioFile
Represents an audio file with metadata.

```swift
struct AudioFile {
    let url: URL
    let hour: Int
    let filename: String
    let size: Int64
    let format: String
}
```

### HourlyAudio
Represents audio configuration for a specific hour.

```swift
struct HourlyAudio {
    let hour: Int
    let audioFile: AudioFile?
    let isEnabled: Bool
}
```

## 🔧 Configuration

### Supported Audio Formats
- MP3 (.mp3)
- WAV (.wav)
- M4A (.m4a)
- AIFF (.aiff)
- AAC (.aac)
- FLAC (.flac)
- OGG (.ogg)

### File Size Limits
- Maximum file size: 2.5MB
- Recommended file size: 1MB or less
- Minimum file size: 1KB

### System Requirements
- macOS 12.0 or later
- Audio output device
- File system access permissions
- Notification permissions

## 🧪 Testing

### Unit Testing
All public APIs include comprehensive unit tests covering:
- Happy path scenarios
- Error conditions
- Edge cases
- Boundary conditions

### Integration Testing
Integration tests verify:
- Component interactions
- End-to-end functionality
- System integration
- Performance characteristics

### Compatibility Testing
Compatibility tests ensure:
- Cross-version compatibility
- Framework availability
- System integration
- Performance consistency

## 📚 Usage Examples

### Basic Audio File Management

```swift
// Import an audio file for hour 12
let audioURL = URL(fileURLWithPath: "/path/to/audio.mp3")
try AudioFileManager.shared.importAudioFile(audioURL, for: 12)

// Get audio file for hour 12
if let audioFile = AudioFileManager.shared.getAudioFile(for: 12) {
    print("Audio file for hour 12: \(audioFile)")
}

// Remove audio file for hour 12
AudioFileManager.shared.removeAudioFile(for: 12)
```

### Audio Playback

```swift
// Play audio from URL
let audioURL = URL(fileURLWithPath: "/path/to/audio.mp3")
try AudioManager.shared.playAudio(from: audioURL)

// Stop audio playback
AudioManager.shared.stopAudio()

// Set volume
AudioManager.shared.setVolume(0.8)
```

### Timer Management

```swift
// Start the hourly timer
HourlyTimer.shared.start()

// Play audio for current hour
HourlyTimer.shared.playAudioForCurrentHour()

// Stop the timer
HourlyTimer.shared.stop()
```

## 🔍 Debugging

### Logging
The app uses structured logging with `os.log`:

```swift
private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "ComponentName")
```

### Debug Mode
Enable debug mode for additional features:
- Additional test buttons
- Enhanced logging
- Notification testing
- System information

### Console Logs
View logs in Console.app:
1. Open Console.app
2. Search for "HourlyAudioPlayer"
3. Filter by category or process

## 📞 Support

### API Support
For questions about the API:
- Check this documentation
- Review the source code
- Contact support@cycleruncode.club

### Bug Reports
For API-related bugs:
- Include API usage examples
- Provide error messages
- Include system information
- Describe expected vs. actual behavior

### Feature Requests
For API enhancements:
- Describe the use case
- Propose the API design
- Consider backward compatibility
- Discuss with maintainers

---

**For API questions, contact support@cycleruncode.club**
