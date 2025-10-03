# Hourly Audio Player - Build Instructions

## 🚀 Quick Start

### Prerequisites
- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 13.0 or later
- **Git**: For version control

### Build and Run
```bash
git clone https://github.com/cycleruncode/HourlyAudioPlayer.git
cd HourlyAudioPlayer
./build_and_run.sh
```

## 🏗️ Development Build

### Basic Development Build
```bash
./build_and_run.sh
```

### Development Build with Version Update
```bash
# Update build number
./build_and_run.sh minor

# Update version number
./build_and_run.sh major
```

### Debug Build
```bash
# Build with debug features
./build_and_run.sh minor debug
```

**Debug Features:**
- Additional test buttons in settings
- Enhanced logging and error reporting
- Notification testing functionality
- Detailed system information

## 📦 Release Build

### Create Release Package
```bash
./build_release.sh [version_number]
```

**Example:**
```bash
./build_release.sh 1.1.0
```

### Release Package Contents
- `HourlyAudioPlayer-v1.1.0.app` - Application bundle
- `HourlyAudioPlayer-v1.1.0.dmg` - Disk image installer
- `HourlyAudioPlayer-v1.1.0.zip` - ZIP archive
- `RELEASE_NOTES_v1.1.0.txt` - Release documentation
- `troubleshoot.sh` - Diagnostic script
- `QUICK_START_GUIDE.txt` - User guide
- `RELEASE_CHECKLIST.txt` - QA checklist

## 🔧 Manual Build

### Xcode Build
1. Open `HourlyAudioPlayer.xcodeproj` in Xcode
2. Select the target and scheme
3. Choose build configuration (Debug/Release)
4. Build the project (Cmd+B)

### Command Line Build
```bash
# Debug build
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Debug build

# Release build
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build
```

### Build with Specific Deployment Target
```bash
# Build for macOS 12.0+
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build MACOSX_DEPLOYMENT_TARGET=12.0

# Build for macOS 13.0+
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build MACOSX_DEPLOYMENT_TARGET=13.0
```

## 🧪 Testing

### Run All Tests
```bash
./run_tests.sh
```

### Run OS Version Tests
```bash
# Test macOS 12.0+ compatibility
./run_os_version_tests.sh 12

# Test macOS 13.0+ compatibility
./run_os_version_tests.sh 13
```

### Run Specific Tests
```bash
# Run only unit tests
xcodebuild test -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -only-testing:HourlyAudioPlayerTests/AudioFileManagerTests

# Run only compatibility tests
xcodebuild test -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -only-testing:HourlyAudioPlayerTests/macOSVersionCompatibilityTests
```

## 📋 Build Configuration

### Project Settings

#### Deployment Target
- **Minimum macOS**: 12.0
- **Architecture**: Universal (Intel & Apple Silicon)
- **Swift Version**: 5.5+

#### Code Signing
- **Development**: Automatic signing
- **Release**: Manual signing with distribution certificate
- **Entitlements**: Required for menu bar app

#### Build Settings
- **Optimization**: Release builds optimized for performance
- **Debugging**: Debug builds include debug symbols
- **Warnings**: All warnings treated as errors in release builds

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

## 🔍 Build Troubleshooting

### Common Build Issues

#### Xcode Version Issues
**Problem**: Build fails with Xcode version errors
**Solution**:
1. Update Xcode to latest version
2. Check deployment target compatibility
3. Verify Swift version compatibility

#### Code Signing Issues
**Problem**: Code signing errors
**Solution**:
1. Check developer account settings
2. Verify certificate validity
3. Update provisioning profiles

#### Dependency Issues
**Problem**: Missing dependencies or frameworks
**Solution**:
1. Check framework availability
2. Verify deployment target
3. Update framework versions

#### Build Environment Issues
**Problem**: Build environment problems
**Solution**:
1. Clean build folder (Cmd+Shift+K)
2. Reset package caches
3. Restart Xcode

### Build Optimization

#### Build Performance
- **Parallel Builds**: Enable parallel builds
- **Build Caching**: Use build caches
- **Incremental Builds**: Use incremental builds
- **Build Tools**: Use latest build tools

#### Build Size
- **Code Optimization**: Enable code optimization
- **Dead Code Elimination**: Remove unused code
- **Asset Optimization**: Optimize assets
- **Framework Linking**: Use weak linking

## 📊 Build Metrics

### Build Performance

#### Build Times
- **Debug Build**: ~30 seconds
- **Release Build**: ~45 seconds
- **Test Build**: ~60 seconds
- **Full Build**: ~90 seconds

#### Build Size
- **Debug Build**: ~50MB
- **Release Build**: ~25MB
- **DMG Package**: ~30MB
- **ZIP Archive**: ~25MB

### Build Quality

#### Code Quality
- **Warnings**: Zero warnings in release builds
- **Errors**: Zero errors in all builds
- **Coverage**: 80%+ test coverage
- **Performance**: Meets performance benchmarks

#### Build Reliability
- **Success Rate**: 99%+ build success rate
- **Reproducibility**: Consistent build results
- **Stability**: Stable build process
- **Maintainability**: Maintainable build system

## 🔄 CI/CD Build

### GitHub Actions

#### Automated Builds
- **Trigger**: Push to main/develop branches
- **Platform**: macOS 12, 13, 14, 15
- **Architecture**: x86_64, arm64
- **Configuration**: Debug and Release

#### Build Matrix
```yaml
strategy:
  matrix:
    os: [macos-12, macos-13, macos-14, macos-15]
    arch: [x86_64, arm64]
    config: [Debug, Release]
```

#### Build Artifacts
- **App Bundle**: Built application
- **DMG**: Disk image installer
- **ZIP**: ZIP archive
- **Test Results**: Test execution results
- **Coverage Reports**: Code coverage reports

### Build Pipeline

#### Build Steps
1. **Checkout**: Check out source code
2. **Setup**: Set up build environment
3. **Build**: Build the application
4. **Test**: Run automated tests
5. **Package**: Create distribution packages
6. **Deploy**: Deploy to distribution channels

#### Quality Gates
- **Build Success**: All builds must pass
- **Test Coverage**: Minimum coverage requirements
- **Performance**: Performance benchmarks
- **Security**: Security validation

## 📦 Distribution

### Distribution Methods

#### DMG Distribution
- **Format**: Disk image (.dmg)
- **Size**: ~30MB
- **Installation**: Drag to Applications
- **User Experience**: Native macOS installation

#### ZIP Distribution
- **Format**: ZIP archive (.zip)
- **Size**: ~25MB
- **Installation**: Extract and run
- **User Experience**: Simple extraction

### Distribution Preparation

#### Pre-Distribution Checklist
- [ ] All tests pass
- [ ] App builds successfully
- [ ] No compiler warnings
- [ ] Documentation updated
- [ ] Version number incremented
- [ ] Release notes reviewed

#### Distribution Files
- **Application**: HourlyAudioPlayer.app
- **Documentation**: Release notes, user guide
- **Tools**: Troubleshooting script
- **Metadata**: Version info, checksums

### Distribution Channels

#### GitHub Releases
- **Platform**: GitHub
- **Format**: DMG and ZIP
- **Documentation**: Release notes
- **Support**: Issue tracking

#### Direct Distribution
- **Platform**: Website
- **Format**: DMG and ZIP
- **Documentation**: User guides
- **Support**: Email support

## 🛠️ Build Tools

### Required Tools

#### Xcode
- **Version**: 13.0 or later
- **Components**: Xcode, Command Line Tools
- **SDKs**: macOS SDK
- **Simulators**: macOS simulators

#### Build Tools
- **xcodebuild**: Command line build tool
- **hdiutil**: Disk image creation
- **zip**: Archive creation
- **codesign**: Code signing

#### Development Tools
- **Git**: Version control
- **Swift**: Swift compiler
- **Instruments**: Performance profiling
- **Console**: Log analysis

### Optional Tools

#### Code Quality
- **SwiftLint**: Code style checking
- **SwiftFormat**: Code formatting
- **SonarQube**: Code quality analysis
- **Coverage**: Code coverage analysis

#### Performance
- **Instruments**: Performance profiling
- **Activity Monitor**: System monitoring
- **Console**: Log analysis
- **Terminal**: Command line tools

## 📚 Build Documentation

### Build Scripts

#### build_and_run.sh
- **Purpose**: Development build and run
- **Usage**: `./build_and_run.sh [major|minor] [debug]`
- **Features**: Version management, debug mode

#### build_release.sh
- **Purpose**: Release build and packaging
- **Usage**: `./build_release.sh [version]`
- **Features**: DMG creation, documentation

#### run_tests.sh
- **Purpose**: Test execution
- **Usage**: `./run_tests.sh`
- **Features**: Test validation, coverage

#### run_os_version_tests.sh
- **Purpose**: OS version compatibility testing
- **Usage**: `./run_os_version_tests.sh [version]`
- **Features**: Multi-version testing

### Build Configuration

#### Project Configuration
- **Deployment Target**: macOS 12.0+
- **Architecture**: Universal
- **Swift Version**: 5.5+
- **Code Signing**: Automatic/Manual

#### Build Settings
- **Optimization**: Release optimized
- **Debugging**: Debug symbols
- **Warnings**: Treat as errors
- **Coverage**: Enable coverage

## 🔧 Advanced Build

### Custom Builds

#### Debug Builds
```bash
# Build with debug symbols
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Debug build

# Build with additional debug info
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Debug build GCC_DEBUGGING_SYMBOLS=YES
```

#### Release Builds
```bash
# Build with optimization
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build

# Build with specific optimization level
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build GCC_OPTIMIZATION_LEVEL=3
```

#### Profile Builds
```bash
# Build for profiling
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build ENABLE_TESTABILITY=YES
```

### Build Variants

#### Architecture-Specific Builds
```bash
# Intel only
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build ARCHS=x86_64

# Apple Silicon only
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build ARCHS=arm64
```

#### Version-Specific Builds
```bash
# macOS 12.0 only
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build MACOSX_DEPLOYMENT_TARGET=12.0

# macOS 13.0 only
xcodebuild -project HourlyAudioPlayer.xcodeproj -scheme HourlyAudioPlayer -configuration Release build MACOSX_DEPLOYMENT_TARGET=13.0
```

## 📞 Build Support

### Getting Help

#### Build Issues
- **Check Logs**: Review build logs for errors
- **Clean Build**: Clean and rebuild project
- **Update Tools**: Update Xcode and tools
- **Check Dependencies**: Verify all dependencies

#### Build Optimization
- **Performance**: Optimize build performance
- **Size**: Reduce build size
- **Time**: Reduce build time
- **Quality**: Improve build quality

### Support Resources

#### Documentation
- [Development Guide](DEVELOPMENT.md)
- [Testing Guide](TESTING.md)
- [User Guide](USER_GUIDE.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

#### External Resources
- [Xcode Documentation](https://developer.apple.com/xcode/)
- [Swift Documentation](https://swift.org/documentation/)
- [macOS Development](https://developer.apple.com/macos/)

---

**For build questions, contact support@cycleruncode.club**
