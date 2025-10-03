# Hourly Audio Player - Comprehensive Test Suite

This directory contains a comprehensive test suite for the Hourly Audio Player application, covering all major components and scenarios.

## Test Files

### 1. AudioFileManagerTests.swift
Tests for the `AudioFileManager` class, covering:
- **Happy Path Tests**: Normal operations with valid audio files
- **Negative Path Tests**: Invalid inputs and edge cases
- **Error Scenarios**: Corrupted files, invalid URLs, empty files
- **Exception Scenarios**: Concurrent access, memory pressure
- **File Manipulation Edge Cases**: Files removed/moved/renamed during operations
- **Odd Scenarios**: Very long names, special characters, Unicode, network URLs

### 2. HourlyTimerTests.swift
Tests for the `HourlyTimer` class, covering:
- **Happy Path Tests**: Normal audio playback operations
- **Negative Path Tests**: Invalid hours, corrupted files
- **Error Scenarios**: Non-existent files, empty files, large files
- **Exception Scenarios**: Concurrent playback, memory pressure
- **File Manipulation Edge Cases**: Files removed/moved/renamed during playback
- **Odd Scenarios**: Long names, special characters, Unicode, network URLs
- **Debug Mode Tests**: Debug-specific functionality

### 3. AudioManagerTests.swift
Tests for the `AudioManager` class, covering:
- **Happy Path Tests**: Valid audio file playback
- **Negative Path Tests**: Non-existent files, corrupted files
- **Error Scenarios**: Invalid URLs, network URLs, large files
- **Exception Scenarios**: Concurrent playback, memory pressure
- **File Manipulation Edge Cases**: Files removed/moved/renamed during playback
- **Odd Scenarios**: Long names, special characters, Unicode, edge hours

### 4. ContentViewTests.swift
Tests for the `ContentView` SwiftUI view, covering:
- **Happy Path Tests**: Normal view initialization and display
- **Negative Path Tests**: Invalid audio files, empty names
- **Error Scenarios**: Corrupted files, non-existent files, large files
- **Exception Scenarios**: Memory pressure, concurrent access
- **File Manipulation Edge Cases**: Files removed/moved/renamed during display
- **Odd Scenarios**: Long names, special characters, Unicode, edge hours

### 5. macOSVersionCompatibilityTests.swift
Tests for macOS version compatibility, covering:
- **Version Detection Tests**: Current macOS version validation
- **SwiftUI Compatibility Tests**: App protocol, NSApplicationDelegateAdaptor, NSHostingController
- **AppKit Compatibility Tests**: NSStatusItem, NSPopover, NSOpenPanel
- **AVFoundation Compatibility Tests**: AVAudioPlayer functionality
- **UserNotifications Compatibility Tests**: Notification center access
- **File System Compatibility Tests**: FileManager, UserDefaults
- **App Lifecycle Compatibility Tests**: Application delegate methods
- **Memory Management Compatibility Tests**: Weak references, autoreleasepool
- **Threading Compatibility Tests**: DispatchQueue functionality
- **Security Framework Compatibility Tests**: Keychain access
- **Performance Compatibility Tests**: Timer, Date operations
- **Network Compatibility Tests**: URL, URLSession
- **Accessibility Compatibility Tests**: AXIsProcessTrusted
- **Version-Specific Feature Tests**: macOS 12.0+, 13.0+, 14.0+ features
- **Cross-Version Compatibility Tests**: Core functionality across versions
- **Error Handling Compatibility Tests**: Graceful error handling
- **Resource Management Compatibility Tests**: File operations

### 6. macOSVersionSpecificTests.swift
Tests for macOS version-specific functionality, covering:
- **macOS 12.0 Specific Tests**: Minimum version requirement, SwiftUI features, AppKit integration
- **macOS 13.0 Specific Tests**: Version-specific features and enhancements
- **macOS 14.0 Specific Tests**: Latest features and capabilities
- **Version-Specific Audio Tests**: Audio functionality across versions
- **Version-Specific Notification Tests**: Notification system compatibility
- **Version-Specific File System Tests**: File operations across versions
- **Version-Specific UI Tests**: User interface components
- **Version-Specific Performance Tests**: Performance across versions
- **Version-Specific Memory Tests**: Memory management
- **Version-Specific Security Tests**: Security framework access
- **Version-Specific Network Tests**: Network functionality
- **Version-Specific Accessibility Tests**: Accessibility features
- **Version-Specific Error Handling Tests**: Error management
- **Version-Specific Resource Management Tests**: Resource handling
- **Version-Specific Integration Tests**: Component integration
- **Version-Specific Edge Case Tests**: Edge case handling

### 7. macOSCITests.swift
Tests for CI/CD environment compatibility, covering:
- **CI Environment Tests**: Environment detection, build environment, tools availability
- **Cross-Platform Compatibility Tests**: Different macOS versions, architectures
- **Performance Tests for CI**: Object creation speed, memory usage
- **Build System Tests**: Build configuration, build information
- **Test Environment Tests**: Test utilities, test data management
- **CI-Specific Integration Tests**: Framework access, security, network, file system
- **CI-Specific Audio Tests**: Audio system in CI
- **CI-Specific Notification Tests**: Notifications in CI
- **CI-Specific UI Tests**: User interface in CI
- **CI-Specific Threading Tests**: Threading in CI
- **CI-Specific Memory Tests**: Memory management in CI
- **CI-Specific Error Handling Tests**: Error handling in CI

## Test Categories

### Happy Path Tests
- Normal operations with valid inputs
- Expected behavior under ideal conditions
- Basic functionality verification

### Negative Path Tests
- Invalid inputs and edge cases
- Boundary conditions
- Error handling for expected failures

### Error Scenarios
- Corrupted or invalid files
- Network issues
- File system problems
- Invalid data formats

### Exception Scenarios
- Concurrent access and threading issues
- Memory pressure situations
- System resource constraints
- Race conditions

### File Manipulation Edge Cases
- Files removed during operations
- Files moved or renamed during operations
- Permission changes during operations
- File system corruption scenarios

### Odd Scenarios
- Very long file names
- Special characters in names
- Unicode characters
- Network URLs
- Edge hour values (0, 23)
- Multiple files for same hour

### macOS Version Compatibility Tests
- Version detection and validation
- SwiftUI framework compatibility
- AppKit integration across versions
- AVFoundation audio functionality
- UserNotifications framework access
- File system operations
- Memory management
- Threading and performance
- Security framework access
- Network functionality
- Accessibility features

### CI/CD Environment Tests
- Environment detection and validation
- Build system compatibility
- Cross-platform testing
- Performance benchmarks
- Resource management
- Error handling
- Integration testing

## Running Tests

### Using the Test Script
```bash
./run_tests.sh
```

### Using macOS Version Specific Tests
```bash
# Run tests for specific macOS version
./run_os_version_tests.sh 12  # Test macOS 12.0+ compatibility
./run_os_version_tests.sh 13  # Test macOS 13.0+ compatibility
./run_os_version_tests.sh 14  # Test macOS 14.0+ compatibility
./run_os_version_tests.sh 15  # Test macOS 15.0+ compatibility

# Run tests for current macOS version
./run_os_version_tests.sh
```

### Using Xcode
1. Open `HourlyAudioPlayer.xcodeproj` in Xcode
2. Select the test target
3. Press `Cmd+U` to run all tests

### Using Command Line
```bash
xcodebuild test -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -destination 'platform=macOS'
```

### Using CI/CD
The project includes GitHub Actions workflows for testing across different macOS versions:
- **macOS 12 (Monterey)**: Tests minimum version compatibility
- **macOS 13 (Ventura)**: Tests enhanced features
- **macOS 14 (Sonoma)**: Tests latest capabilities
- **macOS 15 (Sequoia)**: Tests cutting-edge features

The CI/CD pipeline automatically runs on:
- Push to main/develop branches
- Pull requests
- Daily scheduled runs

## Test Coverage

The test suite provides comprehensive coverage for:

- **Input Validation**: All input parameters and edge cases
- **Error Handling**: Graceful handling of errors and exceptions
- **File Operations**: File system interactions and edge cases
- **Concurrency**: Thread safety and concurrent access
- **Memory Management**: Memory pressure and resource constraints
- **User Interface**: SwiftUI view rendering and updates
- **Audio Playback**: Audio file handling and playback
- **Debug Features**: Debug-specific functionality
- **macOS Version Compatibility**: Cross-version functionality validation
- **CI/CD Environment**: Automated testing and build validation
- **Performance**: Performance benchmarks and optimization
- **Security**: Security framework access and validation
- **Accessibility**: Accessibility features and compliance
- **Network**: Network functionality and error handling

## Test Data

Tests use temporary directories and files to avoid affecting the actual application data. All test data is cleaned up after each test run.

## Debug Mode Tests

Some tests are only available when `DEBUG_MODE` is enabled. These tests cover debug-specific functionality like notification testing.

## Continuous Integration

The test suite is designed to run in CI/CD environments and provides clear pass/fail indicators for automated testing.

## Maintenance

When adding new features or modifying existing code:
1. Add corresponding tests for new functionality
2. Update existing tests if behavior changes
3. Ensure all tests pass before committing changes
4. Add edge cases and error scenarios for new features
