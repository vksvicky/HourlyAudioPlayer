# Hourly Audio Player - Development Guide

## 🚀 Getting Started

### Prerequisites

- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 13.0 or later
- **Swift**: 5.5 or later
- **Git**: For version control

### Development Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/cycleruncode/HourlyAudioPlayer.git
   cd HourlyAudioPlayer
   ```

2. **Open Project**
   ```bash
   open HourlyAudioPlayer.xcodeproj
   ```

3. **Build and Run**
   ```bash
   ./build_and_run.sh
   ```

## 🏗️ Project Structure

```
HourlyAudioPlayer/
├── src/                          # Source code
│   ├── HourlyAudioPlayerApp.swift    # Main app entry point
│   ├── MenuBarView.swift             # Menu bar popover interface
│   ├── ContentView.swift             # Settings window
│   ├── AboutWindow.swift             # About dialog
│   ├── HourlyTimer.swift             # Core timing logic
│   ├── AudioFileManager.swift        # File management
│   ├── AudioManager.swift            # Audio playback
│   ├── Assets.xcassets/              # App icons and assets
│   ├── Info.plist                    # App configuration
│   └── HourlyAudioPlayer.entitlements # App permissions
├── test/                         # Test files
│   ├── AudioFileManagerTests.swift
│   ├── AudioManagerTests.swift
│   ├── ContentViewTests.swift
│   ├── HourlyTimerTests.swift
│   ├── macOSVersionCompatibilityTests.swift
│   ├── macOSVersionSpecificTests.swift
│   └── macOSCITests.swift
├── docs/                         # Documentation
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── USER_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   ├── RELEASE_NOTES_v1.0.0.txt
│   └── OS_VERSION_TESTS_SUMMARY.md
├── releases/                     # Release packages
├── .github/workflows/            # CI/CD pipelines
├── build_and_run.sh              # Development build script
├── build_release.sh              # Release build script
├── run_tests.sh                  # Test runner
├── run_os_version_tests.sh       # OS version specific tests
└── README.md                     # Project overview
```

## 🧩 Architecture

### Core Components

#### HourlyAudioPlayerApp
- **Purpose**: Main app entry point and lifecycle management
- **Responsibilities**: App initialization, menu bar setup, popover management
- **Key Features**: NSApplicationDelegate integration, status bar item

#### MenuBarView
- **Purpose**: Main user interface in menu bar popover
- **Responsibilities**: Status display, navigation, real-time updates
- **Key Features**: SwiftUI interface, timer updates, settings access

#### ContentView
- **Purpose**: Settings and configuration interface
- **Responsibilities**: Audio file management, hour configuration
- **Key Features**: 24-hour grid, file import, validation

#### HourlyTimer
- **Purpose**: Core timing and scheduling logic
- **Responsibilities**: Hour calculation, audio triggering, notifications
- **Key Features**: Precise timing, notification management, error handling

#### AudioFileManager
- **Purpose**: Audio file management and storage
- **Responsibilities**: File import, validation, persistence
- **Key Features**: Smart filename detection, file validation, UserDefaults

#### AudioManager
- **Purpose**: Audio playback control
- **Responsibilities**: Audio playback, volume control, session management
- **Key Features**: AVAudioPlayer integration, error handling

### Data Flow

```
User Interaction → MenuBarView → ContentView → AudioFileManager
                                    ↓
HourlyTimer ← AudioManager ← AudioFileManager
     ↓
UserNotifications
```

## 🛠️ Development Workflow

### Building

#### Development Build
```bash
./build_and_run.sh [major|minor] [debug]
```

**Parameters:**
- `major`: Updates version number (1.0.0 → 2.0.0)
- `minor`: Updates build number (Build 46 → Build 47)
- `debug`: Enables debug mode with additional features

#### Release Build
```bash
./build_release.sh [version_number]
```

**Example:**
```bash
./build_release.sh 1.1.0
```

### Testing

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

#### Test Categories
- **Unit Tests**: Individual component testing
- **Integration Tests**: Component interaction testing
- **Compatibility Tests**: macOS version compatibility
- **CI/CD Tests**: Automated testing pipeline

### Debugging

#### Debug Mode
Enable debug mode for additional features:
```bash
./build_and_run.sh minor debug
```

**Debug Features:**
- Additional test buttons in settings
- Enhanced logging and error reporting
- Notification testing functionality
- Detailed system information

#### Logging
The app uses structured logging with `os.log`:
```swift
private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "ComponentName")
```

**Log Categories:**
- `AppDelegate`: App lifecycle events
- `MenuBarView`: UI interactions
- `HourlyTimer`: Timing and scheduling
- `AudioFileManager`: File operations
- `AudioManager`: Audio playback

#### Console.app
View logs in Console.app:
1. Open Console.app (Applications > Utilities)
2. Search for "HourlyAudioPlayer"
3. Filter by category or process

## 🔧 Configuration

### Build Settings

#### Deployment Target
- **Minimum macOS**: 12.0
- **Architecture**: Universal (Intel & Apple Silicon)
- **Swift Version**: 5.5+

#### Code Signing
- **Development**: Automatic signing
- **Release**: Manual signing with distribution certificate
- **Entitlements**: Required for menu bar app

### App Configuration

#### Info.plist
Key configuration values:
- `CFBundleShortVersionString`: App version
- `CFBundleVersion`: Build number
- `LSMinimumSystemVersion`: Minimum macOS version
- `LSUIElement`: Menu bar app (true)

#### Entitlements
Required entitlements:
- `com.apple.security.app-sandbox`: App sandbox
- `com.apple.security.files.user-selected.read-only`: File access

## 🧪 Testing

### Test Structure

#### Unit Tests
- **AudioFileManagerTests**: File management functionality
- **AudioManagerTests**: Audio playback functionality
- **HourlyTimerTests**: Timing and scheduling logic
- **ContentViewTests**: UI component testing

#### Compatibility Tests
- **macOSVersionCompatibilityTests**: Cross-version compatibility
- **macOSVersionSpecificTests**: Version-specific features
- **macOSCITests**: CI/CD environment validation

### Test Categories

#### Happy Path Tests
- Normal operations with valid inputs
- Expected behavior under ideal conditions
- Basic functionality verification

#### Negative Path Tests
- Invalid inputs and edge cases
- Boundary conditions
- Error handling for expected failures

#### Compatibility Tests
- macOS version compatibility validation
- Framework availability testing
- Cross-version functionality verification

#### Performance Tests
- Memory usage validation
- CPU usage monitoring
- Response time testing

### Running Tests

#### Local Testing
```bash
# Run all tests
./run_tests.sh

# Run specific test categories
./run_os_version_tests.sh 12
```

#### CI/CD Testing
Tests run automatically on:
- Push to main/develop branches
- Pull requests
- Daily scheduled runs

**Supported Platforms:**
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia)

## 📦 Release Process

### Version Management

#### Version Numbers
- **Major**: Breaking changes (1.0.0 → 2.0.0)
- **Minor**: New features (1.0.0 → 1.1.0)
- **Patch**: Bug fixes (1.0.0 → 1.0.1)

#### Build Numbers
- Incremented for each build
- Used for internal tracking
- Displayed in About dialog

### Release Checklist

#### Pre-Release
- [ ] All tests pass
- [ ] App builds successfully
- [ ] No compiler warnings
- [ ] Documentation updated
- [ ] Version number incremented

#### Testing
- [ ] Manual testing completed
- [ ] Cross-platform testing
- [ ] Performance validation
- [ ] User acceptance testing

#### Release
- [ ] Release notes updated
- [ ] DMG/ZIP packages created
- [ ] Documentation included
- [ ] Distribution ready

### Release Scripts

#### build_release.sh
Creates complete release package:
- Builds release version
- Creates DMG installer
- Generates ZIP archive
- Includes documentation
- Creates troubleshooting tools

#### Generated Files
- `HourlyAudioPlayer-v1.0.0.app`: Application bundle
- `HourlyAudioPlayer-v1.0.0.dmg`: Disk image installer
- `HourlyAudioPlayer-v1.0.0.zip`: ZIP archive
- `RELEASE_NOTES_v1.0.0.txt`: Release documentation
- `troubleshoot.sh`: Diagnostic script
- `QUICK_START_GUIDE.txt`: User guide
- `RELEASE_CHECKLIST.txt`: QA checklist

## 🔄 CI/CD Pipeline

### GitHub Actions

#### Workflow Files
- `.github/workflows/macos-version-tests.yml`: Multi-version testing

#### Test Matrix
- **macOS Versions**: 12, 13, 14, 15
- **Architectures**: x86_64, arm64
- **Xcode Versions**: Latest stable

#### Automated Tasks
- Build validation
- Test execution
- Compatibility reporting
- Artifact generation

### Quality Gates

#### Build Requirements
- All tests must pass
- No compiler warnings
- Successful build on all platforms
- Documentation validation

#### Release Requirements
- Manual approval for releases
- Comprehensive testing
- Documentation review
- User acceptance testing

## 🐛 Debugging

### Common Issues

#### Build Failures
- Check Xcode version compatibility
- Verify deployment target settings
- Ensure all dependencies are available
- Check code signing configuration

#### Runtime Issues
- Check Console.app for error messages
- Verify app permissions
- Test with debug mode enabled
- Check system compatibility

#### Test Failures
- Review test logs for specific failures
- Check test environment setup
- Verify test data and fixtures
- Run tests individually for isolation

### Debug Tools

#### Xcode Debugger
- Set breakpoints in critical code paths
- Inspect variable values
- Step through execution
- Analyze memory usage

#### Instruments
- Profile memory usage
- Analyze performance bottlenecks
- Check for memory leaks
- Monitor system resources

#### Console.app
- View real-time logs
- Filter by process or category
- Search for specific error messages
- Monitor system events

## 📚 Code Standards

### Swift Style Guide

#### Naming Conventions
- **Classes**: PascalCase (`AudioManager`)
- **Functions**: camelCase (`playAudio`)
- **Variables**: camelCase (`audioPlayer`)
- **Constants**: camelCase (`maxFileSize`)

#### Code Organization
- **Single Responsibility**: Each class has one purpose
- **Dependency Injection**: Use shared instances
- **Error Handling**: Comprehensive error handling
- **Documentation**: Document public APIs

#### Best Practices
- Use `guard` statements for early returns
- Implement proper error handling
- Use weak references to prevent retain cycles
- Follow Swift naming conventions

### Testing Standards

#### Test Structure
- **Arrange**: Set up test data
- **Act**: Execute the code under test
- **Assert**: Verify expected outcomes

#### Test Naming
- **Format**: `test[What][When][ExpectedResult]`
- **Example**: `testPlayAudioWhenFileExistsReturnsTrue`

#### Coverage Requirements
- **Minimum**: 80% code coverage
- **Critical Paths**: 100% coverage
- **Edge Cases**: Comprehensive testing
- **Error Scenarios**: Full error path testing

## 🤝 Contributing

### Development Process

1. **Fork Repository**
2. **Create Feature Branch**
3. **Make Changes**
4. **Add Tests**
5. **Update Documentation**
6. **Submit Pull Request**

### Code Review

#### Review Checklist
- [ ] Code follows style guidelines
- [ ] Tests are included and pass
- [ ] Documentation is updated
- [ ] No breaking changes
- [ ] Performance impact considered

#### Review Process
- Automated testing runs
- Manual code review
- Documentation review
- User acceptance testing

### Contribution Guidelines

#### Bug Reports
- Include steps to reproduce
- Provide system information
- Include error messages
- Test with latest version

#### Feature Requests
- Describe the feature clearly
- Explain the use case
- Consider implementation complexity
- Discuss with maintainers first

#### Pull Requests
- Keep changes focused
- Include comprehensive tests
- Update documentation
- Follow coding standards

## 📞 Support

### Development Support

#### Getting Help
- Check documentation first
- Search existing issues
- Create detailed issue reports
- Contact maintainers

#### Communication
- **GitHub Issues**: Bug reports and feature requests
- **Email**: support@cycleruncode.club
- **Documentation**: Comprehensive guides available

### Resources

#### Documentation
- [User Guide](USER_GUIDE.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Testing Guide](TESTING.md)

#### External Resources
- [Swift Documentation](https://swift.org/documentation/)
- [macOS Development](https://developer.apple.com/macos/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

---

**Happy coding! 🚀**

For questions about development, contact support@cycleruncode.club
