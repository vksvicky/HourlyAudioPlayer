# Contributing to Hourly Audio Player

## 🤝 Welcome Contributors!

Thank you for your interest in contributing to Hourly Audio Player! This guide will help you get started with contributing to the project.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Contributing Process](#contributing-process)
4. [Code Standards](#code-standards)
5. [Testing Requirements](#testing-requirements)
6. [Documentation](#documentation)
7. [Pull Request Process](#pull-request-process)
8. [Issue Reporting](#issue-reporting)
9. [Feature Requests](#feature-requests)
10. [Community Guidelines](#community-guidelines)

## 🚀 Getting Started

### Prerequisites

- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 13.0 or later
- **Git**: For version control
- **GitHub Account**: For contributing

### Fork and Clone

1. **Fork the Repository**
   - Go to https://github.com/cycleruncode/HourlyAudioPlayer
   - Click the "Fork" button
   - This creates your own copy of the repository

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/HourlyAudioPlayer.git
   cd HourlyAudioPlayer
   ```

3. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/cycleruncode/HourlyAudioPlayer.git
   ```

## 🏗️ Development Setup

### Initial Setup

1. **Open Project**
   ```bash
   open HourlyAudioPlayer.xcodeproj
   ```

2. **Build and Run**
   ```bash
   ./build_and_run.sh
   ```

3. **Run Tests**
   ```bash
   ./run_tests.sh
   ```

### Development Workflow

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Implement your feature
   - Add tests
   - Update documentation

3. **Test Your Changes**
   ```bash
   ./run_tests.sh
   ./run_os_version_tests.sh 12
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "Add: Brief description of changes"
   ```

5. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

## 🔄 Contributing Process

### Types of Contributions

#### Bug Fixes
- Fix existing bugs
- Improve error handling
- Enhance stability
- Performance improvements

#### New Features
- Add new functionality
- Enhance existing features
- Improve user experience
- Add new integrations

#### Documentation
- Improve existing documentation
- Add new documentation
- Fix documentation errors
- Translate documentation

#### Testing
- Add new tests
- Improve test coverage
- Fix failing tests
- Add test utilities

#### Code Quality
- Refactor code
- Improve code style
- Optimize performance
- Reduce technical debt

### Contribution Guidelines

#### Before Contributing
1. **Check Existing Issues**: Look for existing issues or PRs
2. **Discuss Changes**: Open an issue for significant changes
3. **Follow Standards**: Adhere to code and documentation standards
4. **Test Thoroughly**: Ensure all tests pass

#### During Development
1. **Keep Changes Focused**: One feature/fix per PR
2. **Write Tests**: Add tests for new functionality
3. **Update Documentation**: Keep documentation current
4. **Follow Naming**: Use consistent naming conventions

#### After Development
1. **Test Locally**: Run all tests before submitting
2. **Update Documentation**: Ensure documentation is current
3. **Write Clear PR**: Provide clear description and context
4. **Respond to Feedback**: Address review comments promptly

## 📝 Code Standards

### Swift Style Guide

#### Naming Conventions
- **Classes**: PascalCase (`AudioManager`)
- **Functions**: camelCase (`playAudio`)
- **Variables**: camelCase (`audioPlayer`)
- **Constants**: camelCase (`maxFileSize`)
- **Enums**: PascalCase (`AudioFormat`)

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
- Keep functions small and focused

### Code Structure

#### File Organization
```
src/
├── HourlyAudioPlayerApp.swift      # Main app entry point
├── MenuBarView.swift               # Menu bar interface
├── ContentView.swift               # Settings interface
├── AboutWindow.swift               # About dialog
├── HourlyTimer.swift               # Core timing logic
├── AudioFileManager.swift          # File management
├── AudioManager.swift              # Audio playback
└── Assets.xcassets/                # App assets
```

#### Class Structure
```swift
class ClassName {
    // MARK: - Properties
    private let property: Type
    
    // MARK: - Initialization
    init() {
        // Initialization code
    }
    
    // MARK: - Public Methods
    func publicMethod() {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func privateMethod() {
        // Implementation
    }
}
```

### Documentation Standards

#### Code Documentation
```swift
/// Brief description of the function
/// - Parameter parameter: Description of parameter
/// - Returns: Description of return value
/// - Throws: Description of errors that can be thrown
func functionName(parameter: Type) throws -> ReturnType {
    // Implementation
}
```

#### README Updates
- Update relevant sections
- Add new features to feature list
- Update installation instructions
- Add new requirements

## 🧪 Testing Requirements

### Test Coverage

#### Minimum Requirements
- **New Code**: 90% test coverage
- **Critical Paths**: 100% test coverage
- **Error Handling**: 95% test coverage
- **Public APIs**: 100% test coverage

#### Test Types
- **Unit Tests**: Individual component testing
- **Integration Tests**: Component interaction testing
- **Compatibility Tests**: Cross-version testing
- **Performance Tests**: Performance validation

### Test Structure

#### Test Organization
```
test/
├── AudioFileManagerTests.swift
├── AudioManagerTests.swift
├── ContentViewTests.swift
├── HourlyTimerTests.swift
├── macOSVersionCompatibilityTests.swift
├── macOSVersionSpecificTests.swift
└── macOSCITests.swift
```

#### Test Naming
- **Format**: `test[What][When][ExpectedResult]`
- **Example**: `testPlayAudioWhenFileExistsReturnsTrue`

#### Test Structure
```swift
func testFunctionName() {
    // Arrange
    let input = "test input"
    let expectedOutput = "expected output"
    
    // Act
    let actualOutput = functionUnderTest(input)
    
    // Assert
    XCTAssertEqual(actualOutput, expectedOutput)
}
```

### Running Tests

#### Local Testing
```bash
# Run all tests
./run_tests.sh

# Run specific test categories
./run_os_version_tests.sh 12
```

#### CI/CD Testing
- Tests run automatically on PRs
- All tests must pass before merge
- Coverage requirements must be met
- Performance benchmarks must be met

## 📚 Documentation

### Documentation Requirements

#### Code Documentation
- Document all public APIs
- Include parameter descriptions
- Document return values
- Document possible errors

#### User Documentation
- Update user guide for new features
- Add troubleshooting information
- Update FAQ for common questions
- Maintain quick start guide

#### Developer Documentation
- Update development guide
- Document new build processes
- Update testing procedures
- Maintain API documentation

### Documentation Standards

#### Markdown Format
- Use proper markdown syntax
- Include table of contents
- Use consistent formatting
- Include code examples

#### Content Standards
- Clear and concise writing
- Accurate technical information
- Up-to-date information
- User-friendly language

## 🔀 Pull Request Process

### Creating a Pull Request

1. **Ensure Tests Pass**
   ```bash
   ./run_tests.sh
   ```

2. **Update Documentation**
   - Update relevant documentation
   - Add new features to guides
   - Update API documentation

3. **Create Pull Request**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Fill out the PR template

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Test improvement
- [ ] Code refactoring

## Testing
- [ ] All tests pass
- [ ] New tests added
- [ ] Manual testing completed
- [ ] Cross-platform testing

## Documentation
- [ ] Code documented
- [ ] User guide updated
- [ ] API documentation updated
- [ ] README updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes
```

### Review Process

#### Review Criteria
- **Code Quality**: Follows style guidelines
- **Functionality**: Works as expected
- **Testing**: Adequate test coverage
- **Documentation**: Documentation updated
- **Performance**: No performance regressions

#### Review Process
1. **Automated Checks**: CI/CD runs automatically
2. **Code Review**: Maintainers review code
3. **Testing**: Manual testing if needed
4. **Approval**: Maintainer approval required
5. **Merge**: Changes merged to main branch

## 🐛 Issue Reporting

### Bug Reports

#### Before Reporting
1. **Check Existing Issues**: Search for similar issues
2. **Test Latest Version**: Ensure you're using the latest version
3. **Reproduce Issue**: Confirm the issue is reproducible
4. **Gather Information**: Collect relevant system information

#### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- macOS Version: [e.g., 12.0]
- App Version: [e.g., 1.0.0]
- Hardware: [e.g., MacBook Pro M1]

## Additional Information
- Screenshots if applicable
- Error messages
- Console logs
- System information
```

### Feature Requests

#### Before Requesting
1. **Check Existing Requests**: Search for similar requests
2. **Consider Alternatives**: Look for existing solutions
3. **Think About Use Cases**: Consider broader use cases
4. **Discuss with Community**: Get community feedback

#### Feature Request Template

```markdown
## Feature Description
Clear description of the requested feature

## Use Case
Why is this feature needed?

## Proposed Solution
How should this feature work?

## Alternatives Considered
What alternatives have you considered?

## Additional Context
Any additional information or context
```

## 🎯 Feature Requests

### Feature Request Process

1. **Open Issue**: Create a feature request issue
2. **Community Discussion**: Discuss with community
3. **Design Review**: Review design and implementation
4. **Implementation**: Implement the feature
5. **Testing**: Test the feature thoroughly
6. **Documentation**: Update documentation
7. **Release**: Include in next release

### Feature Guidelines

#### Good Features
- **User-Focused**: Solves real user problems
- **Well-Designed**: Thoughtful design and implementation
- **Testable**: Can be thoroughly tested
- **Documented**: Well-documented and explained

#### Feature Criteria
- **Necessity**: Addresses a real need
- **Feasibility**: Technically feasible
- **Maintainability**: Can be maintained long-term
- **Compatibility**: Compatible with existing features

## 👥 Community Guidelines

### Code of Conduct

#### Be Respectful
- Treat everyone with respect
- Be constructive in feedback
- Avoid personal attacks
- Focus on the code, not the person

#### Be Collaborative
- Help others learn and grow
- Share knowledge and experience
- Be open to different approaches
- Work together toward common goals

#### Be Professional
- Use professional language
- Be clear and concise
- Follow project guidelines
- Respect project decisions

### Communication

#### GitHub Issues
- Use clear, descriptive titles
- Provide detailed descriptions
- Use appropriate labels
- Respond to comments promptly

#### Pull Requests
- Write clear descriptions
- Reference related issues
- Respond to review feedback
- Keep PRs focused and small

#### Discussions
- Be respectful and constructive
- Stay on topic
- Help others when possible
- Follow community guidelines

## 🏆 Recognition

### Contributor Recognition

#### Types of Contributions
- **Code Contributions**: Bug fixes, features, improvements
- **Documentation**: Guides, tutorials, API docs
- **Testing**: Test cases, bug reports, quality assurance
- **Community**: Help, support, discussions

#### Recognition Methods
- **Contributor List**: Listed in project contributors
- **Release Notes**: Mentioned in release notes
- **GitHub**: GitHub contributor statistics
- **Community**: Community recognition and thanks

### Getting Help

#### Where to Get Help
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and discussions
- **Email**: support@cycleruncode.club
- **Documentation**: Check existing documentation

#### How to Get Help
- **Be Specific**: Provide detailed information
- **Show Effort**: Demonstrate what you've tried
- **Be Patient**: Allow time for responses
- **Be Grateful**: Thank those who help you

## 📞 Contact

### Project Maintainers
- **Email**: support@cycleruncode.club
- **GitHub**: @cycleruncode
- **Website**: https://cycleruncode.club

### Community
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and discussions
- **Email**: support@cycleruncode.club

---

**Thank you for contributing to Hourly Audio Player! 🎉**

Your contributions help make this project better for everyone. We appreciate your time and effort in helping improve the app.
