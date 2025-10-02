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

## Running Tests

### Using the Test Script
```bash
./run_tests.sh
```

### Using Xcode
1. Open `HourlyAudioPlayer.xcodeproj` in Xcode
2. Select the test target
3. Press `Cmd+U` to run all tests

### Using Command Line
```bash
xcodebuild test -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -destination 'platform=macOS'
```

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
