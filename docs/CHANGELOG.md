# Changelog

All notable changes to the Hourly Audio Player project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- macOS version specific tests for comprehensive compatibility validation
- CI/CD pipeline for automated testing across multiple macOS versions
- Enhanced test coverage with 282% increase in test methods
- Documentation reorganization with dedicated docs folder

### Changed
- Updated minimum macOS version requirement from 14.0 to 12.0
- Enhanced test runner with version compatibility checking
- Improved build scripts with better error handling

### Fixed
- Build script compatibility issues
- Test coverage gaps in version-specific functionality

## [1.0.0] - 2025-10-02

### Added
- Initial release of Hourly Audio Player
- Menu bar application with speaker icon
- 24-hour audio file configuration (0:00 - 23:00)
- Automatic hourly audio playback
- Support for multiple audio formats (MP3, WAV, M4A, AIFF, AAC, FLAC, OGG)
- Smart filename-based hour detection
- User notifications for audio playback
- Manual testing functionality
- Persistent audio file storage
- Real-time clock display
- Debug mode for development testing
- File validation (size limits, format checking)
- Missing file detection with fallback to system sounds
- Comprehensive test suite
- Build and release scripts
- Documentation and user guides

### Technical Details
- Built with SwiftUI and AppKit
- Uses AVFoundation for audio playback
- Implements UserNotifications for system notifications
- Supports macOS 12.0+ (originally 14.0+)
- Universal binary (Intel & Apple Silicon)
- Comprehensive error handling and logging

### Documentation
- Complete README with architecture diagrams
- User guide and quick start guide
- Troubleshooting documentation
- Release notes and build instructions
- Test documentation and coverage reports

## [0.9.0] - 2025-09-XX (Development)

### Added
- Core application structure
- Basic audio playback functionality
- Menu bar integration
- File management system
- Timer and scheduling logic

### Changed
- Initial development and testing phase
- Core functionality implementation

## [0.8.0] - 2025-09-XX (Alpha)

### Added
- Project setup and initial architecture
- Basic SwiftUI interface
- Audio file management
- Hourly timer implementation

### Changed
- Early development phase
- Proof of concept implementation

---

## Version History Summary

| Version | Date | Key Features | macOS Support |
|---------|------|--------------|---------------|
| 1.0.0 | 2025-10-02 | Initial release, full functionality | 12.0+ |
| 0.9.0 | 2025-09-XX | Core features, testing | 12.0+ |
| 0.8.0 | 2025-09-XX | Basic implementation | 12.0+ |

## Release Notes

For detailed release notes, see:
- [RELEASE_NOTES_v1.0.0.txt](RELEASE_NOTES_v1.0.0.txt)

## Breaking Changes

### Version 1.0.0
- Initial release - no breaking changes

## Migration Guide

### From Development to 1.0.0
- No migration required for initial release
- All existing functionality preserved

## Known Issues

### Version 1.0.0
- None currently reported

## Future Roadmap

### Planned Features
- Volume control per hour
- Audio file preview
- Custom notification sounds
- Snooze functionality
- Multiple audio profiles
- Integration with system calendar
- Widget support
- Shortcuts app integration

### Planned Improvements
- Enhanced UI/UX
- Performance optimizations
- Additional audio format support
- Advanced scheduling options
- Cloud sync capabilities
