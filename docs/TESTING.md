# Hourly Audio Player - Testing Guide

## 🧪 Testing Overview

This guide covers the comprehensive testing strategy for Hourly Audio Player, including unit tests, integration tests, compatibility tests, and CI/CD testing.

## 📋 Test Structure

### Test Categories

#### 1. Unit Tests
- **AudioFileManagerTests**: File management functionality
- **AudioManagerTests**: Audio playback functionality
- **HourlyTimerTests**: Timing and scheduling logic
- **ContentViewTests**: UI component testing

#### 2. Compatibility Tests
- **macOSVersionCompatibilityTests**: Cross-version compatibility
- **macOSVersionSpecificTests**: Version-specific features
- **macOSCITests**: CI/CD environment validation

#### 3. Integration Tests
- Component interaction testing
- End-to-end functionality testing
- System integration testing

## 🚀 Running Tests

### Local Testing

#### Run All Tests
```bash
./run_tests.sh
```

#### Run OS Version Tests
```bash
./run_os_version_tests.sh [version]
```

**Examples:**
```bash
./run_os_version_tests.sh 12  # Test macOS 12.0+ compatibility
./run_os_version_tests.sh 13  # Test macOS 13.0+ compatibility
```

#### Run Specific Test Categories
```bash
# Run only unit tests
xcodebuild test -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -only-testing:HourlyAudioPlayerTests/AudioFileManagerTests

# Run only compatibility tests
xcodebuild test -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -only-testing:HourlyAudioPlayerTests/macOSVersionCompatibilityTests
```

### CI/CD Testing

#### GitHub Actions
Tests run automatically on:
- Push to main/develop branches
- Pull requests
- Daily scheduled runs

**Supported Platforms:**
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia)

## 🧩 Test Details

### Unit Tests

#### AudioFileManagerTests
**Purpose**: Test file management functionality

**Test Coverage**:
- File import and validation
- Smart filename detection
- File persistence and storage
- Error handling for invalid files
- File size and format validation

**Key Test Methods**:
- `testImportAudioFile()` - Basic file import
- `testImportAudioFileWithInvalidFormat()` - Invalid format handling
- `testImportAudioFileWithInvalidSize()` - Size limit validation
- `testSmartFilenameDetection()` - Hour detection from filename
- `testFilePersistence()` - File storage and retrieval

#### AudioManagerTests
**Purpose**: Test audio playback functionality

**Test Coverage**:
- Audio playback control
- Volume management
- Error handling for playback failures
- Audio session management
- File format compatibility

**Key Test Methods**:
- `testPlayAudio()` - Basic audio playback
- `testPlayAudioWithInvalidFile()` - Invalid file handling
- `testStopAudio()` - Audio playback control
- `testVolumeControl()` - Volume management
- `testAudioSessionManagement()` - Session handling

#### HourlyTimerTests
**Purpose**: Test timing and scheduling logic

**Test Coverage**:
- Hour calculation and timing
- Audio triggering at correct times
- Notification scheduling
- Error handling for timing issues
- Timer persistence and restoration

**Key Test Methods**:
- `testHourCalculation()` - Time calculation accuracy
- `testAudioTriggering()` - Scheduled audio playback
- `testNotificationScheduling()` - Notification timing
- `testTimerPersistence()` - Timer state management
- `testErrorHandling()` - Timing error recovery

#### ContentViewTests
**Purpose**: Test UI component functionality

**Test Coverage**:
- User interface interactions
- Settings management
- File selection and display
- Error message display
- Navigation and state management

**Key Test Methods**:
- `testSettingsDisplay()` - Settings interface
- `testFileSelection()` - File picker functionality
- `testHourGridDisplay()` - 24-hour grid layout
- `testErrorDisplay()` - Error message handling
- `testNavigation()` - Interface navigation

### Compatibility Tests

#### macOSVersionCompatibilityTests
**Purpose**: Test cross-version compatibility

**Test Coverage**:
- macOS version detection
- Framework availability
- API compatibility across versions
- Feature availability testing
- System integration validation

**Key Test Methods**:
- `testMinimummacOSVersionRequirement()` - Version requirement validation
- `testSwiftUIAppLifecycleCompatibility()` - SwiftUI compatibility
- `testNSApplicationDelegateAdaptorCompatibility()` - AppKit integration
- `testNSHostingControllerCompatibility()` - SwiftUI hosting
- `testNSStatusItemCompatibility()` - Menu bar functionality

#### macOSVersionSpecificTests
**Purpose**: Test version-specific features

**Test Coverage**:
- macOS 12.0 specific features
- macOS 13.0 specific features
- macOS 14.0 specific features
- Version-specific UI behavior
- System integration differences

**Key Test Methods**:
- `testmacOS12SpecificFeatures()` - macOS 12.0 features
- `testmacOS13SpecificFeatures()` - macOS 13.0 features
- `testmacOS14SpecificFeatures()` - macOS 14.0 features
- `testVersionSpecificUIBehavior()` - UI differences
- `testVersionSpecificNotificationBehavior()` - Notification differences

#### macOSCITests
**Purpose**: Test CI/CD environment compatibility

**Test Coverage**:
- CI environment detection
- Build environment validation
- Tool availability testing
- Cross-platform compatibility
- Automated testing validation

**Key Test Methods**:
- `testCIEnvironmentDetection()` - CI environment validation
- `testBuildEnvironmentVariables()` - Build environment check
- `testXcodeBuildToolsAvailability()` - Tool availability
- `testCrossPlatformBuildCompatibility()` - Platform compatibility

## 📊 Test Coverage

### Coverage Requirements

#### Minimum Coverage
- **Overall**: 80% code coverage
- **Critical Paths**: 100% coverage
- **Error Handling**: 90% coverage
- **Public APIs**: 100% coverage

#### Coverage Categories
- **Happy Path**: Normal operations with valid inputs
- **Negative Path**: Invalid inputs and edge cases
- **Error Scenarios**: Error handling and recovery
- **Edge Cases**: Boundary conditions and limits
- **Compatibility**: Cross-version functionality
- **Performance**: Resource usage and timing

### Coverage Analysis

#### Current Coverage
- **Unit Tests**: 85% coverage
- **Integration Tests**: 75% coverage
- **Compatibility Tests**: 90% coverage
- **Overall**: 82% coverage

#### Coverage Gaps
- **Error Recovery**: Some error paths not fully tested
- **Performance**: Limited performance testing
- **Accessibility**: Accessibility testing needed
- **Network**: Network-related functionality

## 🔍 Test Scenarios

### Happy Path Tests

#### Normal Operations
- App launches successfully
- Menu bar icon appears
- Settings window opens
- Audio files import correctly
- Audio playback works
- Notifications appear
- App persists between launches

#### Expected Behavior
- Audio plays at correct times
- File validation works
- Settings are saved
- Error handling is graceful
- Performance is acceptable

### Negative Path Tests

#### Invalid Inputs
- Unsupported file formats
- Files that are too large
- Corrupted audio files
- Missing files
- Invalid permissions

#### Error Conditions
- Audio system failures
- File system errors
- Permission denials
- Network issues
- System resource limits

### Edge Case Tests

#### Boundary Conditions
- Maximum file size (2.5MB)
- Minimum file size
- Maximum number of files
- System resource limits
- Time zone changes

#### Unusual Scenarios
- System sleep/wake
- App backgrounding
- System updates
- Hardware changes
- Network connectivity changes

## 🚨 Test Failures

### Common Test Failures

#### Build Failures
- **Xcode Version**: Incompatible Xcode version
- **Deployment Target**: Incorrect deployment target
- **Dependencies**: Missing dependencies
- **Code Signing**: Signing issues

#### Runtime Failures
- **Permissions**: Missing system permissions
- **File Access**: File system access issues
- **Audio System**: Audio system problems
- **Network**: Network connectivity issues

#### Test Failures
- **Environment**: Test environment issues
- **Data**: Test data problems
- **Timing**: Timing-related failures
- **Resources**: System resource issues

### Debugging Test Failures

#### Investigation Steps
1. **Check Logs**: Review test output and logs
2. **Isolate Tests**: Run individual tests
3. **Check Environment**: Verify test environment
4. **Review Changes**: Check recent code changes
5. **Compare Results**: Compare with previous runs

#### Common Solutions
- **Update Dependencies**: Update Xcode and tools
- **Fix Permissions**: Grant necessary permissions
- **Clean Build**: Clean and rebuild project
- **Reset Environment**: Reset test environment
- **Review Code**: Check for code issues

## 📈 Performance Testing

### Performance Metrics

#### Response Time
- App launch time: < 2 seconds
- Settings window open: < 1 second
- Audio file import: < 5 seconds
- Audio playback start: < 1 second

#### Resource Usage
- Memory usage: < 50MB
- CPU usage: < 5% when idle
- Disk usage: < 100MB total
- Network usage: Minimal

#### Scalability
- Maximum audio files: 24 (one per hour)
- Maximum file size: 2.5MB per file
- Maximum total storage: 60MB
- Concurrent operations: Single-threaded

### Performance Testing Tools

#### Xcode Instruments
- **Time Profiler**: CPU usage analysis
- **Allocations**: Memory usage tracking
- **Leaks**: Memory leak detection
- **Energy Log**: Power usage monitoring

#### System Tools
- **Activity Monitor**: Real-time resource monitoring
- **Console.app**: System log analysis
- **Terminal**: Command-line performance tools

## 🔒 Security Testing

### Security Considerations

#### File Access
- **Sandboxing**: App runs in sandbox
- **File Permissions**: Proper permission handling
- **Data Protection**: Secure data storage
- **Input Validation**: Input sanitization

#### System Integration
- **Permissions**: Minimal required permissions
- **Network Access**: Limited network usage
- **System Calls**: Secure system interactions
- **Data Privacy**: User data protection

### Security Testing

#### File Security
- Test file access permissions
- Verify sandbox restrictions
- Check data encryption
- Validate input sanitization

#### System Security
- Test permission requirements
- Verify network security
- Check system call security
- Validate data privacy

## ♿ Accessibility Testing

### Accessibility Features

#### VoiceOver Support
- **Menu Bar**: VoiceOver navigation
- **Settings**: VoiceOver accessibility
- **Notifications**: VoiceOver announcements
- **Error Messages**: VoiceOver error reporting

#### Keyboard Navigation
- **Tab Order**: Logical tab navigation
- **Keyboard Shortcuts**: Standard shortcuts
- **Focus Management**: Proper focus handling
- **Accessibility Labels**: Descriptive labels

### Accessibility Testing

#### VoiceOver Testing
- Test VoiceOver navigation
- Verify accessibility labels
- Check announcement timing
- Validate error reporting

#### Keyboard Testing
- Test keyboard navigation
- Verify tab order
- Check keyboard shortcuts
- Validate focus management

## 🌐 Network Testing

### Network Considerations

#### Notification Services
- **Apple Push**: Notification delivery
- **Network Connectivity**: Connection handling
- **Offline Mode**: Offline functionality
- **Error Handling**: Network error recovery

#### Data Synchronization
- **Settings Sync**: Future cloud sync
- **File Sync**: Future file synchronization
- **Backup**: Future backup services
- **Restore**: Future restore functionality

### Network Testing

#### Connectivity Testing
- Test with various network conditions
- Verify offline functionality
- Check network error handling
- Validate reconnection logic

#### Service Testing
- Test notification delivery
- Verify service availability
- Check error handling
- Validate fallback behavior

## 📱 Device Testing

### Device Compatibility

#### Hardware Requirements
- **Processor**: Intel or Apple Silicon
- **Memory**: 4GB RAM minimum
- **Storage**: 100MB available space
- **Audio**: Audio output device

#### Device Testing
- Test on various Mac models
- Verify performance on different hardware
- Check compatibility with different audio devices
- Validate resource usage

### Device-Specific Testing

#### MacBook Testing
- Test on MacBook Air and Pro
- Verify battery usage
- Check thermal performance
- Validate audio output

#### Desktop Testing
- Test on iMac and Mac Pro
- Verify external audio devices
- Check multiple monitor support
- Validate performance

## 🔄 Continuous Integration

### CI/CD Pipeline

#### Automated Testing
- **Build Validation**: Automatic builds
- **Test Execution**: Automated test runs
- **Coverage Reporting**: Coverage analysis
- **Performance Monitoring**: Performance tracking

#### Quality Gates
- **Build Success**: All builds must pass
- **Test Coverage**: Minimum coverage requirements
- **Performance**: Performance benchmarks
- **Security**: Security validation

### CI/CD Configuration

#### GitHub Actions
- **Workflow**: Automated testing workflow
- **Matrix**: Multi-platform testing
- **Artifacts**: Test result artifacts
- **Notifications**: Build notifications

#### Quality Metrics
- **Build Time**: Build performance
- **Test Duration**: Test execution time
- **Coverage**: Code coverage metrics
- **Success Rate**: Build success rate

## 📊 Test Reporting

### Test Reports

#### Coverage Reports
- **HTML Reports**: Detailed coverage analysis
- **XML Reports**: Machine-readable coverage
- **Summary Reports**: High-level coverage summary
- **Trend Reports**: Coverage trends over time

#### Performance Reports
- **Performance Metrics**: Response time and resource usage
- **Benchmark Results**: Performance benchmarks
- **Trend Analysis**: Performance trends
- **Comparison Reports**: Performance comparisons

### Report Generation

#### Automated Reports
- **CI/CD Reports**: Automated report generation
- **Scheduled Reports**: Regular report generation
- **Event Reports**: Event-triggered reports
- **Custom Reports**: Custom report generation

#### Report Distribution
- **Email Reports**: Email distribution
- **Web Reports**: Web-based reporting
- **Dashboard**: Real-time dashboard
- **Alerts**: Automated alerts

## 🛠️ Test Maintenance

### Test Maintenance

#### Regular Updates
- **Test Data**: Update test data regularly
- **Test Environment**: Maintain test environment
- **Dependencies**: Update test dependencies
- **Documentation**: Keep test documentation current

#### Test Optimization
- **Performance**: Optimize test performance
- **Reliability**: Improve test reliability
- **Maintainability**: Enhance test maintainability
- **Coverage**: Improve test coverage

### Test Quality

#### Test Quality Metrics
- **Reliability**: Test reliability metrics
- **Maintainability**: Test maintainability metrics
- **Performance**: Test performance metrics
- **Coverage**: Test coverage metrics

#### Quality Improvement
- **Code Review**: Test code review process
- **Refactoring**: Test refactoring
- **Optimization**: Test optimization
- **Documentation**: Test documentation

---

**For questions about testing, contact support@cycleruncode.club**
