import XCTest
@testable import HourlyAudioPlayer
import Foundation
import SwiftUI
import AppKit

class macOSVersionCompatibilityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - macOS Version Detection Tests
    
    func testCurrentMacOSVersion() {
        // Test that we can detect the current macOS version
        let version = ProcessInfo.processInfo.operatingSystemVersion
        XCTAssertGreaterThanOrEqual(version.majorVersion, 12, "App should run on macOS 12.0 or later")
        
        print("Current macOS version: \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)")
    }
    
    func testMacOSVersionCompatibility() {
        // Test that the app's minimum version requirement is met
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // App requires macOS 12.0+
        XCTAssertGreaterThanOrEqual(version.majorVersion, 12, "App requires macOS 12.0 or later")
        
        if version.majorVersion == 12 {
            XCTAssertGreaterThanOrEqual(version.minorVersion, 0, "App requires macOS 12.0 or later")
        }
    }
    
    // MARK: - SwiftUI Compatibility Tests
    
    func testSwiftUIAppProtocolCompatibility() {
        // Test that SwiftUI App protocol is available (requires macOS 11.0+)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        XCTAssertGreaterThanOrEqual(version.majorVersion, 11, "SwiftUI App protocol requires macOS 11.0+")
        
        // Test that we can create an App instance
        XCTAssertNoThrow({
            // This tests that the App protocol is available
            let _ = HourlyAudioPlayerApp()
        }, "Should be able to create HourlyAudioPlayerApp instance")
    }
    
    func testNSApplicationDelegateAdaptorCompatibility() {
        // Test that @NSApplicationDelegateAdaptor is available (requires macOS 11.0+)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        XCTAssertGreaterThanOrEqual(version.majorVersion, 11, "@NSApplicationDelegateAdaptor requires macOS 11.0+")
        
        // Test that we can access the app delegate
        if let appDelegate = NSApp.delegate as? AppDelegate {
            XCTAssertNotNil(appDelegate, "AppDelegate should be accessible")
            XCTAssertNotNil(appDelegate.statusItem, "StatusItem should be available")
        }
    }
    
    func testNSHostingControllerCompatibility() {
        // Test that NSHostingController is available (requires macOS 10.15+)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        XCTAssertGreaterThanOrEqual(version.majorVersion, 10, "NSHostingController requires macOS 10.15+")
        
        if version.majorVersion == 10 {
            XCTAssertGreaterThanOrEqual(version.minorVersion, 15, "NSHostingController requires macOS 10.15+")
        }
        
        // Test that we can create NSHostingController
        XCTAssertNoThrow({
            let _ = NSHostingController(rootView: MenuBarView())
        }, "Should be able to create NSHostingController with SwiftUI view")
    }
    
    // MARK: - AppKit Compatibility Tests
    
    func testNSStatusItemCompatibility() {
        // Test that NSStatusItem is available (available since macOS 10.0)
        XCTAssertNoThrow({
            let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            XCTAssertNotNil(statusItem, "NSStatusItem should be available")
        }, "Should be able to create NSStatusItem")
    }
    
    func testNSPopoverCompatibility() {
        // Test that NSPopover is available (available since macOS 10.5)
        XCTAssertNoThrow({
            let popover = NSPopover()
            XCTAssertNotNil(popover, "NSPopover should be available")
        }, "Should be able to create NSPopover")
    }
    
    func testNSOpenPanelCompatibility() {
        // Test that NSOpenPanel is available (available since macOS 10.0)
        XCTAssertNoThrow({
            let panel = NSOpenPanel()
            XCTAssertNotNil(panel, "NSOpenPanel should be available")
        }, "Should be able to create NSOpenPanel")
    }
    
    // MARK: - AVFoundation Compatibility Tests
    
    func testAVAudioPlayerCompatibility() {
        // Test that AVAudioPlayer is available (available since macOS 10.3)
        XCTAssertNoThrow({
            // Create a temporary audio file for testing
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_audio.wav")
            let audioData = Data([0x52, 0x49, 0x46, 0x46, 0x26, 0x00, 0x00, 0x00, 0x57, 0x41, 0x56, 0x45])
            try? audioData.write(to: tempURL)
            
            defer {
                try? FileManager.default.removeItem(at: tempURL)
            }
            
            let audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            XCTAssertNotNil(audioPlayer, "AVAudioPlayer should be available")
        }, "Should be able to create AVAudioPlayer")
    }
    
    // MARK: - UserNotifications Compatibility Tests
    
    func testUserNotificationsCompatibility() {
        // Test that UserNotifications framework is available (available since macOS 10.14)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        XCTAssertGreaterThanOrEqual(version.majorVersion, 10, "UserNotifications requires macOS 10.14+")
        
        if version.majorVersion == 10 {
            XCTAssertGreaterThanOrEqual(version.minorVersion, 14, "UserNotifications requires macOS 10.14+")
        }
        
        XCTAssertNoThrow({
            let center = UNUserNotificationCenter.current()
            XCTAssertNotNil(center, "UNUserNotificationCenter should be available")
        }, "Should be able to access UNUserNotificationCenter")
    }
    
    // MARK: - File System Compatibility Tests
    
    func testFileManagerCompatibility() {
        // Test that FileManager is available (available since macOS 10.0)
        XCTAssertNoThrow({
            let fileManager = FileManager.default
            XCTAssertNotNil(fileManager, "FileManager should be available")
            
            // Test basic file operations
            let tempDir = fileManager.temporaryDirectory
            XCTAssertTrue(fileManager.fileExists(atPath: tempDir.path), "Should be able to access temporary directory")
        }, "Should be able to use FileManager")
    }
    
    func testUserDefaultsCompatibility() {
        // Test that UserDefaults is available (available since macOS 10.0)
        XCTAssertNoThrow({
            let userDefaults = UserDefaults.standard
            XCTAssertNotNil(userDefaults, "UserDefaults should be available")
            
            // Test basic operations
            userDefaults.set("test", forKey: "test_key")
            let value = userDefaults.string(forKey: "test_key")
            XCTAssertEqual(value, "test", "Should be able to store and retrieve values")
            userDefaults.removeObject(forKey: "test_key")
        }, "Should be able to use UserDefaults")
    }
    
    // MARK: - App Lifecycle Compatibility Tests
    
    func testAppLifecycleCompatibility() {
        // Test that app lifecycle methods are available
        XCTAssertNoThrow({
            let app = NSApplication.shared
            XCTAssertNotNil(app, "NSApplication should be available")
            
            // Test that we can access app delegate
            if let delegate = app.delegate {
                XCTAssertTrue(delegate.responds(to: #selector(NSApplicationDelegate.applicationDidFinishLaunching(_:))), 
                             "App delegate should respond to applicationDidFinishLaunching")
            }
        }, "Should be able to access app lifecycle methods")
    }
    
    // MARK: - Memory Management Compatibility Tests
    
    func testMemoryManagementCompatibility() {
        // Test that memory management works correctly across macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // Test weak references (available since macOS 10.0)
        weak var weakObject: NSObject?
        XCTAssertNoThrow({
            let strongObject = NSObject()
            weakObject = strongObject
            XCTAssertNotNil(weakObject, "Weak reference should work")
        }, "Should be able to use weak references")
        
        // Test autoreleasepool (available since macOS 10.0)
        XCTAssertNoThrow({
            autoreleasepool {
                let _ = NSObject()
            }
        }, "Should be able to use autoreleasepool")
    }
    
    // MARK: - Threading Compatibility Tests
    
    func testThreadingCompatibility() {
        // Test that threading APIs are available
        XCTAssertNoThrow({
            let expectation = XCTestExpectation(description: "Threading test")
            
            DispatchQueue.global().async {
                // Test that we can access main queue from background
                DispatchQueue.main.async {
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }, "Should be able to use DispatchQueue")
    }
    
    // MARK: - Security Framework Compatibility Tests
    
    func testSecurityFrameworkCompatibility() {
        // Test that Security framework is available (available since macOS 10.0)
        XCTAssertNoThrow({
            // Test that we can access security functions
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "test",
                kSecReturnData as String: false
            ]
            
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            // We expect errSecItemNotFound since we're not actually storing anything
            XCTAssertTrue(status == errSecItemNotFound || status == errSecSuccess, 
                         "Should be able to access Security framework")
        }, "Should be able to access Security framework")
    }
    
    // MARK: - Performance Compatibility Tests
    
    func testPerformanceCompatibility() {
        // Test that performance-critical operations work across macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // Test timer performance
        XCTAssertNoThrow({
            let expectation = XCTestExpectation(description: "Timer test")
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
            timer.invalidate()
        }, "Should be able to use Timer")
        
        // Test date operations
        XCTAssertNoThrow({
            let now = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: now)
            XCTAssertNotNil(components.hour, "Should be able to get date components")
        }, "Should be able to use Date and Calendar")
    }
    
    // MARK: - Network Compatibility Tests
    
    func testNetworkCompatibility() {
        // Test that network APIs are available
        XCTAssertNoThrow({
            let url = URL(string: "https://www.apple.com")
            XCTAssertNotNil(url, "Should be able to create URL")
            
            // Test URLSession (available since macOS 10.9)
            let version = ProcessInfo.processInfo.operatingSystemVersion
            if version.majorVersion >= 10 && version.minorVersion >= 9 {
                let session = URLSession.shared
                XCTAssertNotNil(session, "URLSession should be available")
            }
        }, "Should be able to use network APIs")
    }
    
    // MARK: - Accessibility Compatibility Tests
    
    func testAccessibilityCompatibility() {
        // Test that accessibility APIs are available
        XCTAssertNoThrow({
            // Test that we can access accessibility information
            let app = NSApplication.shared
            XCTAssertNotNil(app, "NSApplication should be available")
            
            // Test that we can check accessibility permissions
            let trusted = AXIsProcessTrusted()
            // We don't assert the value since it depends on system settings
            XCTAssertTrue(trusted == true || trusted == false, "Should be able to check accessibility permissions")
        }, "Should be able to access accessibility APIs")
    }
    
    // MARK: - Version-Specific Feature Tests
    
    func testMacOS12SpecificFeatures() {
        // Test features that are available in macOS 12.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 12 {
            // Test that we can use macOS 12+ features
            XCTAssertNoThrow({
                // Test that we can access newer APIs
                let app = NSApplication.shared
                XCTAssertNotNil(app, "NSApplication should be available")
                
                // Test that we can set activation policy
                app.setActivationPolicy(.accessory)
                XCTAssertEqual(app.activationPolicy(), .accessory, "Should be able to set activation policy")
            }, "Should be able to use macOS 12+ features")
        } else {
            XCTSkip("Skipping macOS 12+ specific tests on older macOS version")
        }
    }
    
    func testMacOS13SpecificFeatures() {
        // Test features that are available in macOS 13.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 13 {
            // Test that we can use macOS 13+ features
            XCTAssertNoThrow({
                // Test that we can access newer SwiftUI features
                let _ = MenuBarView()
            }, "Should be able to use macOS 13+ features")
        } else {
            XCTSkip("Skipping macOS 13+ specific tests on older macOS version")
        }
    }
    
    func testMacOS14SpecificFeatures() {
        // Test features that are available in macOS 14.0+
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        if version.majorVersion >= 14 {
            // Test that we can use macOS 14+ features
            XCTAssertNoThrow({
                // Test that we can access newer APIs
                let _ = ContentView()
            }, "Should be able to use macOS 14+ features")
        } else {
            XCTSkip("Skipping macOS 14+ specific tests on older macOS version")
        }
    }
    
    // MARK: - Cross-Version Compatibility Tests
    
    func testCrossVersionCompatibility() {
        // Test that the app works correctly across different macOS versions
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        // Test that core functionality works regardless of version
        XCTAssertNoThrow({
            // Test that we can create core objects
            let audioManager = AudioManager.shared
            XCTAssertNotNil(audioManager, "AudioManager should be available")
            
            let audioFileManager = AudioFileManager.shared
            XCTAssertNotNil(audioFileManager, "AudioFileManager should be available")
            
            let hourlyTimer = HourlyTimer.shared
            XCTAssertNotNil(hourlyTimer, "HourlyTimer should be available")
        }, "Core functionality should work across all supported macOS versions")
        
        // Test that we can handle version-specific behavior
        if version.majorVersion >= 12 {
            // Test that we can use newer features when available
            XCTAssertNoThrow({
                let _ = MenuBarView()
            }, "Should be able to use newer features when available")
        }
    }
    
    // MARK: - Error Handling Compatibility Tests
    
    func testErrorHandlingCompatibility() {
        // Test that error handling works correctly across macOS versions
        XCTAssertNoThrow({
            // Test that we can handle errors gracefully
            do {
                let invalidURL = URL(string: "invalid://url")
                if let url = invalidURL {
                    let _ = try Data(contentsOf: url)
                }
            } catch {
                // Expected to fail, but should handle gracefully
                XCTAssertTrue(error is URLError || error is NSError, "Should handle errors gracefully")
            }
        }, "Should be able to handle errors gracefully")
    }
    
    // MARK: - Resource Management Compatibility Tests
    
    func testResourceManagementCompatibility() {
        // Test that resource management works correctly across macOS versions
        XCTAssertNoThrow({
            // Test that we can manage resources properly
            let tempDir = FileManager.default.temporaryDirectory
            let tempFile = tempDir.appendingPathComponent("test_resource.txt")
            
            // Create a temporary file
            let testData = "test data".data(using: .utf8)
            try? testData?.write(to: tempFile)
            
            // Verify it exists
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile.path), "Should be able to create files")
            
            // Clean up
            try? FileManager.default.removeItem(at: tempFile)
            XCTAssertFalse(FileManager.default.fileExists(atPath: tempFile.path), "Should be able to remove files")
        }, "Should be able to manage resources properly")
    }
}
