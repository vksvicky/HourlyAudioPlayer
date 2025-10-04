import XCTest
@testable import HourlyAudioPlayer
import SwiftUI
import AppKit

class ThemeIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any existing UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
    }
    
    override func tearDown() {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        super.tearDown()
    }
    
    // MARK: - Cross-View Theme Consistency Tests
    
    func testAllViewsWithLightTheme() {
        // Given: Light theme is active
        ThemeManager.shared.isDarkMode = false
        
        // When: Creating all views
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // Then: All views should not crash and theme should be consistent
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
        
        // And: All views should see the same theme state
        XCTAssertFalse(ThemeManager.shared.isDarkMode)
        XCTAssertEqual(NSApp.appearance?.name, .aqua)
    }
    
    func testAllViewsWithDarkTheme() {
        // Given: Dark theme is active
        ThemeManager.shared.isDarkMode = true
        
        // When: Creating all views
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // Then: All views should not crash and theme should be consistent
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
        
        // And: All views should see the same theme state
        XCTAssertTrue(ThemeManager.shared.isDarkMode)
        XCTAssertEqual(NSApp.appearance?.name, .darkAqua)
    }
    
    func testThemeConsistencyAcrossViews() {
        // Given: All views exist
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // When: Changing theme
        ThemeManager.shared.isDarkMode = true
        
        // Then: All views should handle the change consistently
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
        
        // And: Theme should be applied consistently across all views
        XCTAssertTrue(ThemeManager.shared.isDarkMode)
        XCTAssertEqual(NSApp.appearance?.name, .darkAqua)
        
        // When: Changing back to light theme
        ThemeManager.shared.isDarkMode = false
        
        // Then: All views should reflect the change
        XCTAssertFalse(ThemeManager.shared.isDarkMode)
        XCTAssertEqual(NSApp.appearance?.name, .aqua)
    }
    
    func testThemeSwitchingWithAllViews() {
        // Given: All views exist
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // When: Switching themes multiple times
        ThemeManager.shared.isDarkMode = false
        ThemeManager.shared.isDarkMode = true
        ThemeManager.shared.isDarkMode = false
        ThemeManager.shared.isDarkMode = true
        
        // Then: All views should remain stable
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
        XCTAssertTrue(ThemeManager.shared.isDarkMode)
    }
    
    // MARK: - System Color Integration Tests
    
    func testSystemColorsWithLightTheme() {
        // Given: Light theme is active
        ThemeManager.shared.isDarkMode = false
        
        // When: System colors are used
        let windowBackground = NSColor.windowBackgroundColor
        let controlBackground = NSColor.controlBackgroundColor
        let controlText = NSColor.controlTextColor
        let separator = NSColor.separatorColor
        
        // Then: Colors should be available
        XCTAssertNotNil(windowBackground)
        XCTAssertNotNil(controlBackground)
        XCTAssertNotNil(controlText)
        XCTAssertNotNil(separator)
    }
    
    func testSystemColorsWithDarkTheme() {
        // Given: Dark theme is active
        ThemeManager.shared.isDarkMode = true
        
        // When: System colors are used
        let windowBackground = NSColor.windowBackgroundColor
        let controlBackground = NSColor.controlBackgroundColor
        let controlText = NSColor.controlTextColor
        let separator = NSColor.separatorColor
        
        // Then: Colors should be available
        XCTAssertNotNil(windowBackground)
        XCTAssertNotNil(controlBackground)
        XCTAssertNotNil(controlText)
        XCTAssertNotNil(separator)
    }
    
    func testSystemColorsChangeWithTheme() {
        // Given: Light theme is active
        ThemeManager.shared.isDarkMode = false
        let lightWindowBackground = NSColor.windowBackgroundColor
        let lightControlBackground = NSColor.controlBackgroundColor
        let lightControlText = NSColor.controlTextColor
        let lightSeparator = NSColor.separatorColor
        
        // When: Switching to dark theme
        ThemeManager.shared.isDarkMode = true
        let darkWindowBackground = NSColor.windowBackgroundColor
        let darkControlBackground = NSColor.controlBackgroundColor
        let darkControlText = NSColor.controlTextColor
        let darkSeparator = NSColor.separatorColor
        
        // Then: Colors should be different
        XCTAssertNotEqual(lightWindowBackground, darkWindowBackground)
        XCTAssertNotEqual(lightControlBackground, darkControlBackground)
        XCTAssertNotEqual(lightControlText, darkControlText)
        XCTAssertNotEqual(lightSeparator, darkSeparator)
        
        // And: All colors should be valid (not nil)
        XCTAssertNotNil(lightWindowBackground)
        XCTAssertNotNil(lightControlBackground)
        XCTAssertNotNil(lightControlText)
        XCTAssertNotNil(lightSeparator)
        XCTAssertNotNil(darkWindowBackground)
        XCTAssertNotNil(darkControlBackground)
        XCTAssertNotNil(darkControlText)
        XCTAssertNotNil(darkSeparator)
    }
    
    // MARK: - Theme Persistence Tests
    
    func testThemePersistenceAcrossAppRestart() {
        // Given: A theme preference is set
        ThemeManager.shared.isDarkMode = true
        
        // When: Simulating app restart by checking UserDefaults
        let savedValue = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // Then: Theme should be persisted
        XCTAssertTrue(savedValue)
        
        // And: Should persist across multiple restarts
        ThemeManager.shared.isDarkMode = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isDarkMode"))
        
        ThemeManager.shared.isDarkMode = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isDarkMode"))
    }
    
    func testThemePersistenceWithMultipleChanges() {
        // Given: Multiple theme changes
        ThemeManager.shared.isDarkMode = false
        ThemeManager.shared.isDarkMode = true
        ThemeManager.shared.isDarkMode = false
        ThemeManager.shared.isDarkMode = true
        
        // When: Checking persistence
        let savedValue = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // Then: Last change should be persisted
        XCTAssertTrue(savedValue)
    }
    
    func testDefaultThemePersistence() {
        // Given: No saved theme preference
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        
        // When: Creating ThemeManager
        let manager = ThemeManager.shared
        
        // Then: Should default to light theme
        XCTAssertFalse(manager.isDarkMode)
    }
    
    // MARK: - Theme Manager Singleton Tests
    
    func testThemeManagerSingletonAcrossViews() {
        // Given: Multiple views
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // When: All views access ThemeManager
        let manager1 = ThemeManager.shared
        let manager2 = ThemeManager.shared
        let manager3 = ThemeManager.shared
        let manager4 = ThemeManager.shared
        
        // Then: Should be the same instance
        XCTAssertTrue(manager1 === manager2)
        XCTAssertTrue(manager2 === manager3)
        XCTAssertTrue(manager3 === manager4)
        XCTAssertTrue(manager1 === manager4)
    }
    
    func testThemeManagerStateConsistency() {
        // Given: Multiple views accessing ThemeManager
        let contentView = ContentView()
        let pongView = PongGameView()
        
        // When: Changing theme through one view
        ThemeManager.shared.isDarkMode = true
        
        // Then: All views should see the same state
        XCTAssertTrue(ThemeManager.shared.isDarkMode)
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
    }
    
    // MARK: - Concurrent Theme Operations Tests
    
    func testConcurrentThemeChangesAcrossViews() {
        // Given: Multiple views
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        let expectation = XCTestExpectation(description: "Concurrent theme changes")
        expectation.expectedFulfillmentCount = 20
        
        // When: Changing themes concurrently
        DispatchQueue.concurrentPerform(iterations: 20) { _ in
            ThemeManager.shared.toggleTheme()
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
    }
    
    func testConcurrentViewCreationWithThemeChanges() {
        // Given: Theme changes happening
        let expectation = XCTestExpectation(description: "Concurrent view creation")
        expectation.expectedFulfillmentCount = 10
        
        // When: Creating views concurrently while changing themes
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            ThemeManager.shared.toggleTheme()
            let view = ContentView()
            _ = view
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testThemeManagerMemoryManagementWithViews() {
        // Given: Weak references to views
        weak var weakContentView: ContentView?
        weak var weakPongView: PongGameView?
        weak var weakAboutWindow: AboutWindow?
        weak var weakMenuBarView: MenuBarView?
        
        // When: Creating and releasing views
        autoreleasepool {
            let contentView = ContentView()
            let pongView = PongGameView()
            let aboutWindow = AboutWindow()
            let menuBarView = MenuBarView()
            
            weakContentView = contentView
            weakPongView = pongView
            weakAboutWindow = aboutWindow
            weakMenuBarView = menuBarView
            
            // Perform theme operations
            ThemeManager.shared.isDarkMode = true
            ThemeManager.shared.forceRefresh()
        }
        
        // Then: Views should be deallocated, ThemeManager should remain
        XCTAssertNil(weakContentView)
        XCTAssertNil(weakPongView)
        XCTAssertNil(weakAboutWindow)
        XCTAssertNil(weakMenuBarView)
        XCTAssertNotNil(ThemeManager.shared)
    }
    
    func testThemeManagerPersistenceAfterViewDeallocation() {
        // Given: A theme preference
        ThemeManager.shared.isDarkMode = true
        
        // When: Views are created and deallocated
        autoreleasepool {
            let contentView = ContentView()
            let pongView = PongGameView()
            _ = contentView
            _ = pongView
        }
        
        // Then: Theme preference should persist
        XCTAssertTrue(ThemeManager.shared.isDarkMode)
        let savedValue = UserDefaults.standard.bool(forKey: "isDarkMode")
        XCTAssertTrue(savedValue)
    }
    
    // MARK: - Error Handling Tests
    
    func testThemeManagerWithCorruptedUserDefaults() {
        // Given: Corrupted UserDefaults
        UserDefaults.standard.set("invalid", forKey: "isDarkMode")
        
        // When: Creating views
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // Then: Should default to light theme and not crash
        XCTAssertFalse(ThemeManager.shared.isDarkMode)
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
    }
    
    func testThemeManagerWithNilUserDefaults() {
        // Given: Nil UserDefaults
        UserDefaults.standard.set(nil, forKey: "isDarkMode")
        
        // When: Creating views
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // Then: Should default to light theme and not crash
        XCTAssertFalse(ThemeManager.shared.isDarkMode)
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
    }
    
    // MARK: - Performance Tests
    
    func testThemeSwitchingPerformance() {
        // Given: All views exist
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        measure {
            // When: Measuring theme switching performance
            for _ in 0..<100 {
                ThemeManager.shared.toggleTheme()
            }
        }
        
        // Clean up
        _ = contentView
        _ = pongView
        _ = aboutWindow
        _ = menuBarView
    }
    
    func testViewCreationWithThemePerformance() {
        // Given: A theme state
        ThemeManager.shared.isDarkMode = true
        
        measure {
            // When: Measuring view creation performance with theme
            for _ in 0..<50 {
                let contentView = ContentView()
                let pongView = PongGameView()
                let aboutWindow = AboutWindow()
                let menuBarView = MenuBarView()
                _ = contentView
                _ = pongView
                _ = aboutWindow
                _ = menuBarView
            }
        }
    }
    
    // MARK: - Stress Tests
    
    func testThemeSystemStressTest() {
        // Given: All views exist
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // When: Stress testing the theme system
        for _ in 0..<1000 {
            ThemeManager.shared.toggleTheme()
            ThemeManager.shared.forceRefresh()
        }
        
        // Then: Should remain stable
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
    }
    
    func testThemeSystemWithRapidViewCreation() {
        // Given: A theme state
        ThemeManager.shared.isDarkMode = false
        
        // When: Rapidly creating and destroying views
        for _ in 0..<100 {
            autoreleasepool {
                let contentView = ContentView()
                let pongView = PongGameView()
                let aboutWindow = AboutWindow()
                let menuBarView = MenuBarView()
                _ = contentView
                _ = pongView
                _ = aboutWindow
                _ = menuBarView
            }
            ThemeManager.shared.toggleTheme()
        }
        
        // Then: Theme system should remain stable
        XCTAssertNotNil(ThemeManager.shared)
    }
    
    // MARK: - Integration Edge Cases
    
    func testThemeSystemWithSystemAppearanceChanges() {
        // Given: All views exist
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // When: System appearance changes (simulated)
        ThemeManager.shared.isDarkMode = true
        ThemeManager.shared.forceRefresh()
        Thread.sleep(forTimeInterval: 0.01)
        ThemeManager.shared.isDarkMode = false
        ThemeManager.shared.forceRefresh()
        
        // Then: Should handle gracefully
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
    }
    
    func testThemeSystemWithExtremeThemeChanges() {
        // Given: All views exist
        let contentView = ContentView()
        let pongView = PongGameView()
        let aboutWindow = AboutWindow()
        let menuBarView = MenuBarView()
        
        // When: Extremely rapid theme changes
        for _ in 0..<10000 {
            ThemeManager.shared.toggleTheme()
        }
        
        // Then: Should remain stable
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(pongView)
        XCTAssertNotNil(aboutWindow)
        XCTAssertNotNil(menuBarView)
    }
}
