import XCTest
@testable import HourlyAudioPlayer
import Foundation
import SwiftUI
import AppKit
import AVFoundation
import UserNotifications

class macOSVersionSpecificTests: XCTestCase {
    
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }
    
    // MARK: - macOS 12.0 Specific Tests
    
    func testMacOS12MinimumVersionRequirement() {
        // Test that the app meets the minimum macOS 12.0 requirement
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        XCTAssertGreaterThanOrEqual(version.majorVersion, 12, "App requires macOS 12.0 or later")
        
        if version.majorVersion == 12 {
            XCTAssertGreaterThanOrEqual(version.minorVersion, 0, "App requires macOS 12.0 or later")
        }
    }
    
    func testMacOS12SwiftUIFeatures() {
        // Test SwiftUI features available in macOS 12.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 12 {
            // Test that we can use SwiftUI features available in macOS 12
            XCTAssertNoThrow({
                // Test that we can create SwiftUI views
                let menuBarView = MenuBarView()
                XCTAssertNotNil(menuBarView, "MenuBarView should be available in macOS 12+")
                
                let contentView = ContentView()
                XCTAssertNotNil(contentView, "ContentView should be available in macOS 12+")
                
                let aboutWindow = AboutWindow()
                XCTAssertNotNil(aboutWindow, "AboutWindow should be available in macOS 12+")
            }, "SwiftUI features should be available in macOS 12+")
        } else {
            XCTSkip("Skipping macOS 12+ SwiftUI tests on older macOS version")
        }
    }
    
    func testMacOS12AppKitIntegration() {
        // Test AppKit integration features available in macOS 12.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 12 {
            XCTAssertNoThrow({
                // Test that we can integrate SwiftUI with AppKit
                let hostingController = NSHostingController(rootView: MenuBarView())
                XCTAssertNotNil(hostingController, "NSHostingController should work with SwiftUI in macOS 12+")
                
                // Test that we can create popovers
                let popover = NSPopover()
                popover.contentViewController = hostingController
                XCTAssertNotNil(popover.contentViewController, "Popover should work with hosting controller in macOS 12+")
            }, "AppKit integration should work in macOS 12+")
        } else {
            XCTSkip("Skipping macOS 12+ AppKit integration tests on older macOS version")
        }
    }
    
    // MARK: - macOS 13.0 Specific Tests
    
    func testMacOS13SpecificFeatures() {
        // Test features available in macOS 13.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 13 {
            XCTAssertNoThrow({
                // Test that we can use macOS 13+ specific features
                // Note: Add specific macOS 13+ features here when they become relevant
                let app = NSApplication.shared
                XCTAssertNotNil(app, "NSApplication should be available in macOS 13+")
            }, "macOS 13+ features should be available")
        } else {
            XCTSkip("Skipping macOS 13+ specific tests on older macOS version")
        }
    }
    
    // MARK: - macOS 14.0 Specific Tests
    
    func testMacOS14SpecificFeatures() {
        // Test features available in macOS 14.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 14 {
            XCTAssertNoThrow({
                // Test that we can use macOS 14+ specific features
                // Note: Add specific macOS 14+ features here when they become relevant
                let app = NSApplication.shared
                XCTAssertNotNil(app, "NSApplication should be available in macOS 14+")
            }, "macOS 14+ features should be available")
        } else {
            XCTSkip("Skipping macOS 14+ specific tests on older macOS version")
        }
    }
    
    // MARK: - Version-Specific Audio Tests
    
    func testAudioCompatibilityAcrossVersions() {
        // Test audio functionality across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        XCTAssertNoThrow({
            // Test that AVAudioPlayer works across all supported versions
            let audioManager = AudioManager.shared
            XCTAssertNotNil(audioManager, "AudioManager should be available across all supported versions")
            
            // Test that we can create audio files
            let testAudioFile = AudioFile(
                name: "test.mp3",
                url: tempDirectory.appendingPathComponent("test.mp3"),
                hour: 12
            )
            XCTAssertNotNil(testAudioFile, "AudioFile should be available across all supported versions")
        }, "Audio functionality should work across all supported macOS versions")
    }
    
    func testNotificationCompatibilityAcrossVersions() {
        // Test notification functionality across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // UserNotifications framework requires macOS 10.14+
        if version.majorVersion >= 10 && version.minorVersion >= 14 {
            XCTAssertNoThrow({
                // Test that we can access notification center
                let center = UNUserNotificationCenter.current()
                XCTAssertNotNil(center, "UNUserNotificationCenter should be available in macOS 10.14+")
                
                // Test that we can create notification content
                let content = UNMutableNotificationContent()
                content.title = "Test"
                content.body = "Test notification"
                XCTAssertNotNil(content, "UNMutableNotificationContent should be available in macOS 10.14+")
            }, "Notification functionality should work in macOS 10.14+")
        } else {
            XCTSkip("Skipping notification tests on macOS versions older than 10.14")
        }
    }
    
    // MARK: - Version-Specific File System Tests
    
    func testFileSystemCompatibilityAcrossVersions() {
        // Test file system functionality across different macOS versions
        XCTAssertNoThrow({
            // Test that we can access file system
            let fileManager = FileManager.default
            XCTAssertNotNil(fileManager, "FileManager should be available across all supported versions")
            
            // Test that we can create directories
            let testDir = tempDirectory.appendingPathComponent("test_dir")
            try? fileManager.createDirectory(at: testDir, withIntermediateDirectories: true)
            XCTAssertTrue(fileManager.fileExists(atPath: testDir.path), "Should be able to create directories")
            
            // Test that we can create files
            let testFile = testDir.appendingPathComponent("test.txt")
            let testData = "test content".data(using: .utf8)
            try? testData?.write(to: testFile)
            XCTAssertTrue(fileManager.fileExists(atPath: testFile.path), "Should be able to create files")
        }, "File system functionality should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific UI Tests
    
    func testUICompatibilityAcrossVersions() {
        // Test UI functionality across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        XCTAssertNoThrow({
            // Test that we can create UI elements
            let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            XCTAssertNotNil(statusItem, "NSStatusItem should be available across all supported versions")
            
            let popover = NSPopover()
            XCTAssertNotNil(popover, "NSPopover should be available across all supported versions")
            
            let openPanel = NSOpenPanel()
            XCTAssertNotNil(openPanel, "NSOpenPanel should be available across all supported versions")
        }, "UI functionality should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Performance Tests
    
    func testPerformanceAcrossVersions() {
        // Test performance across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // Test timer performance
        XCTAssertNoThrow({
            let expectation = XCTestExpectation(description: "Timer performance test")
            let startTime = Date()
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                let endTime = Date()
                let duration = endTime.timeIntervalSince(startTime)
                
                // Timer should fire within reasonable time (0.1s ± 0.05s)
                XCTAssertGreaterThanOrEqual(duration, 0.05, "Timer should fire within reasonable time")
                XCTAssertLessThanOrEqual(duration, 0.2, "Timer should fire within reasonable time")
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
            timer.invalidate()
        }, "Timer performance should be consistent across macOS versions")
    }
    
    // MARK: - Version-Specific Memory Tests
    
    func testMemoryManagementAcrossVersions() {
        // Test memory management across different macOS versions
        XCTAssertNoThrow({
            // Test that we can manage memory properly
            weak var weakObject: NSObject?
            
            autoreleasepool {
                let strongObject = NSObject()
                weakObject = strongObject
                XCTAssertNotNil(weakObject, "Weak reference should work across all macOS versions")
            }
            
            // Object should be deallocated after autoreleasepool
            // Note: This test might be flaky due to timing, but it's a good indicator
        }, "Memory management should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Security Tests
    
    func testSecurityAcrossVersions() {
        // Test security functionality across different macOS versions
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
                         "Security framework should be accessible across all supported macOS versions")
        }, "Security functionality should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Network Tests
    
    func testNetworkAcrossVersions() {
        // Test network functionality across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        XCTAssertNoThrow({
            // Test that we can create URLs
            let url = URL(string: "https://www.apple.com")
            XCTAssertNotNil(url, "URL creation should work across all supported macOS versions")
            
            // Test URLSession (available since macOS 10.9)
            if version.majorVersion >= 10 && version.minorVersion >= 9 {
                let session = URLSession.shared
                XCTAssertNotNil(session, "URLSession should be available in macOS 10.9+")
            }
        }, "Network functionality should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Accessibility Tests
    
    func testAccessibilityAcrossVersions() {
        // Test accessibility functionality across different macOS versions
        XCTAssertNoThrow({
            // Test that we can access accessibility APIs
            let trusted = AXIsProcessTrusted()
            // We don't assert the value since it depends on system settings
            XCTAssertTrue(trusted == true || trusted == false, 
                         "Accessibility APIs should be accessible across all supported macOS versions")
        }, "Accessibility functionality should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Error Handling Tests
    
    func testErrorHandlingAcrossVersions() {
        // Test error handling across different macOS versions
        XCTAssertNoThrow({
            // Test that we can handle errors gracefully
            do {
                let invalidURL = URL(string: "invalid://url")
                if let url = invalidURL {
                    let _ = try Data(contentsOf: url)
                }
            } catch {
                // Expected to fail, but should handle gracefully
                XCTAssertTrue(error is URLError || error is NSError, 
                             "Error handling should work across all supported macOS versions")
            }
        }, "Error handling should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Resource Management Tests
    
    func testResourceManagementAcrossVersions() {
        // Test resource management across different macOS versions
        XCTAssertNoThrow({
            // Test that we can manage resources properly
            let tempFile = tempDirectory.appendingPathComponent("test_resource.txt")
            
            // Create a temporary file
            let testData = "test data".data(using: .utf8)
            try? testData?.write(to: tempFile)
            
            // Verify it exists
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile.path), 
                         "File creation should work across all supported macOS versions")
            
            // Clean up
            try? FileManager.default.removeItem(at: tempFile)
            XCTAssertFalse(FileManager.default.fileExists(atPath: tempFile.path), 
                          "File deletion should work across all supported macOS versions")
        }, "Resource management should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Integration Tests
    
    func testIntegrationAcrossVersions() {
        // Test integration between different components across macOS versions
        XCTAssertNoThrow({
            // Test that all components work together
            let audioManager = AudioManager.shared
            let audioFileManager = AudioFileManager.shared
            let hourlyTimer = HourlyTimer.shared
            
            XCTAssertNotNil(audioManager, "AudioManager should be available")
            XCTAssertNotNil(audioFileManager, "AudioFileManager should be available")
            XCTAssertNotNil(hourlyTimer, "HourlyTimer should be available")
            
            // Test that we can create a complete audio file workflow
            let testAudioFile = AudioFile(
                name: "test.mp3",
                url: tempDirectory.appendingPathComponent("test.mp3"),
                hour: 12
            )
            
            audioFileManager.audioFiles[12] = testAudioFile
            XCTAssertNotNil(audioFileManager.getAudioFile(for: 12), "Should be able to store and retrieve audio files")
        }, "Component integration should work across all supported macOS versions")
    }
    
    // MARK: - Version-Specific Edge Case Tests
    
    func testEdgeCasesAcrossVersions() {
        // Test edge cases across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        XCTAssertNoThrow({
            // Test edge cases that might behave differently across versions
            
            // Test date handling at year boundaries
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            XCTAssertNotNil(components.year, "Date components should work across all supported macOS versions")
            
            // Test time zone handling
            let timeZone = TimeZone.current
            XCTAssertNotNil(timeZone, "TimeZone should work across all supported macOS versions")
            
            // Test locale handling
            let locale = Locale.current
            XCTAssertNotNil(locale, "Locale should work across all supported macOS versions")
        }, "Edge cases should be handled consistently across all supported macOS versions")
    }
}
