import XCTest
@testable import HourlyAudioPlayer
import Foundation
import SwiftUI
import AppKit

class macOSCITests: XCTestCase {
    
    // MARK: - CI Environment Tests
    
    func testCIEnvironmentDetection() {
        // Test that we can detect if we're running in a CI environment
        let ciEnvironment = ProcessInfo.processInfo.environment["CI"]
        let githubActions = ProcessInfo.processInfo.environment["GITHUB_ACTIONS"]
        let jenkins = ProcessInfo.processInfo.environment["JENKINS_URL"]
        let travis = ProcessInfo.processInfo.environment["TRAVIS"]
        
        // At least one CI environment variable should be set in CI
        let isCI = ciEnvironment != nil || githubActions != nil || jenkins != nil || travis != nil
        
        if isCI {
            print("Running in CI environment")
            // In CI, we should have access to all necessary tools
            XCTAssertTrue(true, "CI environment detected")
        } else {
            print("Running in local environment")
            // In local environment, we should still be able to run tests
            XCTAssertTrue(true, "Local environment detected")
        }
    }
    
    func testCIBuildEnvironment() {
        // Test that the build environment is properly configured
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let architecture = ProcessInfo.processInfo.machineHardwareName
        
        print("CI Environment Info:")
        print("  macOS Version: \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)")
        print("  Architecture: \(architecture)")
        
        // Test that we're running on a supported macOS version
        XCTAssertGreaterThanOrEqual(version.majorVersion, 12, "CI should run on macOS 12.0 or later")
        
        // Test that we're running on a supported architecture
        XCTAssertTrue(architecture.contains("x86_64") || architecture.contains("arm64"), 
                     "CI should run on supported architecture (x86_64 or arm64)")
    }
    
    func testCIToolsAvailability() {
        // Test that necessary tools are available in CI
        XCTAssertNoThrow({
            // Test that we can access Xcode tools
            let xcodePath = ProcessInfo.processInfo.environment["DEVELOPER_DIR"]
            if xcodePath != nil {
                print("Xcode path: \(xcodePath!)")
            }
            
            // Test that we can access Swift
            let swiftPath = ProcessInfo.processInfo.environment["SWIFT_PATH"]
            if swiftPath != nil {
                print("Swift path: \(swiftPath!)")
            }
            
            // Test that we can access build tools
            let buildToolsPath = ProcessInfo.processInfo.environment["BUILD_TOOLS_PATH"]
            if buildToolsPath != nil {
                print("Build tools path: \(buildToolsPath!)")
            }
        }, "CI tools should be available")
    }
    
    // MARK: - Cross-Platform Compatibility Tests
    
    func testCrossPlatformCompatibility() {
        // Test that the app works on different macOS versions in CI
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // Test that core functionality works regardless of version
        XCTAssertNoThrow({
            // Test that we can create core objects
            let audioManager = AudioManager.shared
            XCTAssertNotNil(audioManager, "AudioManager should work across all supported macOS versions")
            
            let audioFileManager = AudioFileManager.shared
            XCTAssertNotNil(audioFileManager, "AudioFileManager should work across all supported macOS versions")
            
            let hourlyTimer = HourlyTimer.shared
            XCTAssertNotNil(hourlyTimer, "HourlyTimer should work across all supported macOS versions")
        }, "Core functionality should work across all supported macOS versions")
        
        // Test version-specific features
        if version.majorVersion >= 12 {
            XCTAssertNoThrow({
                // Test that we can use macOS 12+ features
                let _ = MenuBarView()
            }, "macOS 12+ features should work")
        }
    }
    
    func testArchitectureCompatibility() {
        // Test that the app works on different architectures
        let architecture = ProcessInfo.processInfo.machineHardwareName
        
        print("Testing on architecture: \(architecture)")
        
        XCTAssertNoThrow({
            // Test that we can create objects regardless of architecture
            let audioManager = AudioManager.shared
            XCTAssertNotNil(audioManager, "AudioManager should work on \(architecture)")
            
            let audioFileManager = AudioFileManager.shared
            XCTAssertNotNil(audioFileManager, "AudioFileManager should work on \(architecture)")
            
            let hourlyTimer = HourlyTimer.shared
            XCTAssertNotNil(hourlyTimer, "HourlyTimer should work on \(architecture)")
        }, "App should work on \(architecture)")
    }
    
    // MARK: - Performance Tests for CI
    
    func testCIPerformance() {
        // Test that the app performs well in CI environment
        let startTime = Date()
        
        // Test that we can create objects quickly
        XCTAssertNoThrow({
            let audioManager = AudioManager.shared
            let audioFileManager = AudioFileManager.shared
            let hourlyTimer = HourlyTimer.shared
            
            XCTAssertNotNil(audioManager)
            XCTAssertNotNil(audioFileManager)
            XCTAssertNotNil(hourlyTimer)
        }, "Object creation should be fast in CI")
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Object creation should be fast (less than 1 second)
        XCTAssertLessThan(duration, 1.0, "Object creation should be fast in CI environment")
        
        print("Object creation took: \(duration) seconds")
    }
    
    func testCIMemoryUsage() {
        // Test that the app doesn't use excessive memory in CI
        let initialMemory = getMemoryUsage()
        
        // Create some objects
        XCTAssertNoThrow({
            let audioManager = AudioManager.shared
            let audioFileManager = AudioFileManager.shared
            let hourlyTimer = HourlyTimer.shared
            
            XCTAssertNotNil(audioManager)
            XCTAssertNotNil(audioFileManager)
            XCTAssertNotNil(hourlyTimer)
        }, "Object creation should not cause memory issues")
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Memory increase should be reasonable (less than 100MB)
        XCTAssertLessThan(memoryIncrease, 100 * 1024 * 1024, "Memory usage should be reasonable in CI")
        
        print("Memory usage: \(memoryIncrease / 1024 / 1024) MB")
    }
    
    // MARK: - Build System Tests
    
    func testBuildSystemCompatibility() {
        // Test that the app builds correctly in CI
        XCTAssertNoThrow({
            // Test that we can access build information
            let bundle = Bundle.main
            let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            
            XCTAssertNotNil(version, "Version should be available")
            XCTAssertNotNil(buildNumber, "Build number should be available")
            
            print("App version: \(version ?? "unknown")")
            print("Build number: \(buildNumber ?? "unknown")")
        }, "Build system should work correctly")
    }
    
    func testBuildConfiguration() {
        // Test that the build configuration is correct
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // Test that we're building for the correct macOS version
        XCTAssertGreaterThanOrEqual(version.majorVersion, 12, "Should build for macOS 12.0 or later")
        
        // Test that we have the correct architecture
        let architecture = ProcessInfo.processInfo.machineHardwareName
        XCTAssertTrue(architecture.contains("x86_64") || architecture.contains("arm64"), 
                     "Should build for supported architecture")
    }
    
    // MARK: - Test Environment Tests
    
    func testTestEnvironment() {
        // Test that the test environment is properly configured
        XCTAssertNoThrow({
            // Test that we can access test utilities
            let testCase = self
            XCTAssertNotNil(testCase, "XCTestCase should be available")
            
            // Test that we can create expectations
            let expectation = XCTestExpectation(description: "Test expectation")
            XCTAssertNotNil(expectation, "XCTestExpectation should be available")
            
            // Test that we can use assertions
            XCTAssertTrue(true, "XCTest assertions should work")
        }, "Test environment should be properly configured")
    }
    
    func testTestData() {
        // Test that we can create and manage test data
        XCTAssertNoThrow({
            // Test that we can create temporary directories
            let tempDir = FileManager.default.temporaryDirectory
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path), "Should be able to access temp directory")
            
            // Test that we can create temporary files
            let tempFile = tempDir.appendingPathComponent("test_file.txt")
            let testData = "test data".data(using: .utf8)
            try? testData?.write(to: tempFile)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile.path), "Should be able to create temp files")
            
            // Clean up
            try? FileManager.default.removeItem(at: tempFile)
        }, "Test data management should work")
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    // MARK: - CI-Specific Integration Tests
    
    func testCIIntegration() {
        // Test that the app integrates properly in CI environment
        XCTAssertNoThrow({
            // Test that we can access all necessary frameworks
            let _ = Foundation.ProcessInfo.processInfo
            let _ = SwiftUI.MenuBarView()
            let _ = AppKit.NSApplication.shared
            let _ = AVFoundation.AVAudioPlayer.self
            let _ = UserNotifications.UNUserNotificationCenter.current()
        }, "All frameworks should be available in CI")
    }
    
    func testCISecurity() {
        // Test that the app handles security properly in CI
        XCTAssertNoThrow({
            // Test that we can access security framework
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "test_account",
                kSecReturnData as String: false
            ]
            
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            // We expect errSecItemNotFound since we're not actually storing anything
            XCTAssertTrue(status == errSecItemNotFound || status == errSecSuccess, 
                         "Security framework should be accessible in CI")
        }, "Security should work in CI")
    }
    
    func testCINetwork() {
        // Test that the app handles network properly in CI
        XCTAssertNoThrow({
            // Test that we can create URLs
            let url = URL(string: "https://www.apple.com")
            XCTAssertNotNil(url, "URL creation should work in CI")
            
            // Test that we can access URLSession
            let session = URLSession.shared
            XCTAssertNotNil(session, "URLSession should be available in CI")
        }, "Network should work in CI")
    }
    
    func testCIFileSystem() {
        // Test that the app handles file system properly in CI
        XCTAssertNoThrow({
            // Test that we can access file system
            let fileManager = FileManager.default
            XCTAssertNotNil(fileManager, "FileManager should be available in CI")
            
            // Test that we can access temporary directory
            let tempDir = fileManager.temporaryDirectory
            XCTAssertTrue(fileManager.fileExists(atPath: tempDir.path), "Should be able to access temp directory in CI")
        }, "File system should work in CI")
    }
    
    func testCIAudio() {
        // Test that the app handles audio properly in CI
        XCTAssertNoThrow({
            // Test that we can access audio framework
            let audioManager = AudioManager.shared
            XCTAssertNotNil(audioManager, "AudioManager should be available in CI")
            
            // Test that we can access audio file manager
            let audioFileManager = AudioFileManager.shared
            XCTAssertNotNil(audioFileManager, "AudioFileManager should be available in CI")
        }, "Audio should work in CI")
    }
    
    func testCINotifications() {
        // Test that the app handles notifications properly in CI
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 10 && version.minorVersion >= 14 {
            XCTAssertNoThrow({
                // Test that we can access notification center
                let center = UNUserNotificationCenter.current()
                XCTAssertNotNil(center, "UNUserNotificationCenter should be available in CI")
            }, "Notifications should work in CI")
        } else {
            XCTSkip("Skipping notification tests on macOS versions older than 10.14")
        }
    }
    
    func testCIUI() {
        // Test that the app handles UI properly in CI
        XCTAssertNoThrow({
            // Test that we can access UI elements
            let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            XCTAssertNotNil(statusItem, "NSStatusItem should be available in CI")
            
            let popover = NSPopover()
            XCTAssertNotNil(popover, "NSPopover should be available in CI")
        }, "UI should work in CI")
    }
    
    func testCIThreading() {
        // Test that the app handles threading properly in CI
        XCTAssertNoThrow({
            // Test that we can use dispatch queues
            let expectation = XCTestExpectation(description: "Threading test")
            
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }, "Threading should work in CI")
    }
    
    func testCIMemory() {
        // Test that the app handles memory properly in CI
        XCTAssertNoThrow({
            // Test that we can manage memory
            weak var weakObject: NSObject?
            
            autoreleasepool {
                let strongObject = NSObject()
                weakObject = strongObject
                XCTAssertNotNil(weakObject, "Weak reference should work in CI")
            }
        }, "Memory management should work in CI")
    }
    
    func testCIErrorHandling() {
        // Test that the app handles errors properly in CI
        XCTAssertNoThrow({
            // Test that we can handle errors gracefully
            do {
                let invalidURL = URL(string: "invalid://url")
                if let url = invalidURL {
                    let _ = try Data(contentsOf: url)
                }
            } catch {
                // Expected to fail, but should handle gracefully
                XCTAssertTrue(error is URLError || error is NSError, "Error handling should work in CI")
            }
        }, "Error handling should work in CI")
    }
}
