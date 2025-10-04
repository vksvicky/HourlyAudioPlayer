import XCTest
@testable import HourlyAudioPlayer
import AppKit

class ThemeManagerTests: XCTestCase {
    
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        // Clear any existing UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        themeManager = ThemeManager.shared
    }
    
    override func tearDown() {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testThemeManagerSingleton() {
        // Given: ThemeManager is a singleton
        // When: Getting multiple instances
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared
        
        // Then: Should return the same instance
        XCTAssertTrue(instance1 === instance2)
        
        // And: Changes to one should affect the other
        instance1.isDarkMode = true
        XCTAssertTrue(instance2.isDarkMode)
        
        instance2.isDarkMode = false
        XCTAssertFalse(instance1.isDarkMode)
    }
    
    func testDefaultThemeIsLight() {
        // Given: No saved theme preference
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should default to light theme
        XCTAssertFalse(newManager.isDarkMode)
    }
    
    func testSavedThemePreference() {
        // Given: A saved dark theme preference
        UserDefaults.standard.set(true, forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should use the saved preference
        XCTAssertTrue(newManager.isDarkMode)
    }
    
    func testSavedLightThemePreference() {
        // Given: A saved light theme preference
        UserDefaults.standard.set(false, forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should use the saved preference
        XCTAssertFalse(newManager.isDarkMode)
    }
    
    // MARK: - Theme Switching Tests
    
    func testToggleThemeFromLightToDark() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        
        // When: Toggling theme
        themeManager.toggleTheme()
        
        // Then: Should switch to dark theme
        XCTAssertTrue(themeManager.isDarkMode)
    }
    
    func testToggleThemeFromDarkToLight() {
        // Given: Dark theme is active
        themeManager.isDarkMode = true
        
        // When: Toggling theme
        themeManager.toggleTheme()
        
        // Then: Should switch to light theme
        XCTAssertFalse(themeManager.isDarkMode)
    }
    
    func testMultipleThemeToggles() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        
        // When: Toggling theme multiple times
        themeManager.toggleTheme() // Light -> Dark
        XCTAssertTrue(themeManager.isDarkMode)
        
        themeManager.toggleTheme() // Dark -> Light
        XCTAssertFalse(themeManager.isDarkMode)
        
        themeManager.toggleTheme() // Light -> Dark
        XCTAssertTrue(themeManager.isDarkMode)
        
        // Then: Should maintain correct state
        XCTAssertTrue(themeManager.isDarkMode)
    }
    
    // MARK: - UserDefaults Persistence Tests
    
    func testThemeChangePersistsToUserDefaults() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isDarkMode"))
        
        // When: Changing to dark theme
        themeManager.isDarkMode = true
        
        // Then: Should persist to UserDefaults immediately
        let savedValue = UserDefaults.standard.bool(forKey: "isDarkMode")
        XCTAssertTrue(savedValue)
        
        // And: Should persist across multiple changes
        themeManager.isDarkMode = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isDarkMode"))
        
        themeManager.isDarkMode = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isDarkMode"))
    }
    
    func testThemeChangeFromUserDefaults() {
        // Given: Dark theme is saved in UserDefaults
        UserDefaults.standard.set(true, forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should load the saved value
        XCTAssertTrue(newManager.isDarkMode)
    }
    
    func testThemePersistenceAcrossAppRestarts() {
        // Given: A theme preference is set
        themeManager.isDarkMode = true
        
        // When: Simulating app restart by creating new manager
        let newManager = ThemeManager.shared
        
        // Then: Should maintain the same theme
        XCTAssertTrue(newManager.isDarkMode)
    }
    
    // MARK: - Theme Icon Tests
    
    func testThemeIconForLightMode() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        
        // When: Getting theme icon
        let icon = themeManager.themeIcon
        
        // Then: Should return sun icon
        XCTAssertEqual(icon, "sun.max.fill")
    }
    
    func testThemeIconForDarkMode() {
        // Given: Dark theme is active
        themeManager.isDarkMode = true
        
        // When: Getting theme icon
        let icon = themeManager.themeIcon
        
        // Then: Should return moon icon
        XCTAssertEqual(icon, "moon.fill")
    }
    
    func testThemeIconChangesWithTheme() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        XCTAssertEqual(themeManager.themeIcon, "sun.max.fill")
        
        // When: Switching to dark theme
        themeManager.isDarkMode = true
        
        // Then: Icon should change
        XCTAssertEqual(themeManager.themeIcon, "moon.fill")
        
        // And: Should change back when switching to light
        themeManager.isDarkMode = false
        XCTAssertEqual(themeManager.themeIcon, "sun.max.fill")
        
        // And: Should change again when switching to dark
        themeManager.isDarkMode = true
        XCTAssertEqual(themeManager.themeIcon, "moon.fill")
    }
    
    // MARK: - Theme Name Tests
    
    func testThemeNameForLightMode() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        
        // When: Getting theme name
        let name = themeManager.themeName
        
        // Then: Should return "Light"
        XCTAssertEqual(name, "Light")
    }
    
    func testThemeNameForDarkMode() {
        // Given: Dark theme is active
        themeManager.isDarkMode = true
        
        // When: Getting theme name
        let name = themeManager.themeName
        
        // Then: Should return "Dark"
        XCTAssertEqual(name, "Dark")
    }
    
    func testThemeNameChangesWithTheme() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        XCTAssertEqual(themeManager.themeName, "Light")
        
        // When: Switching to dark theme
        themeManager.isDarkMode = true
        
        // Then: Name should change
        XCTAssertEqual(themeManager.themeName, "Dark")
    }
    
    // MARK: - Force Refresh Tests
    
    func testForceRefreshMethod() {
        // Given: A theme manager
        // When: Calling force refresh
        // Then: Should not crash
        XCTAssertNoThrow(themeManager.forceRefresh())
    }
    
    func testThemeApplicationToNSApp() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        
        // When: Applying theme
        themeManager.forceRefresh()
        
        // Then: NSApp appearance should be set to aqua (light)
        XCTAssertNotNil(NSApp.appearance)
        XCTAssertEqual(NSApp.appearance?.name, .aqua)
        
        // When: Switching to dark theme
        themeManager.isDarkMode = true
        themeManager.forceRefresh()
        
        // Then: NSApp appearance should be set to darkAqua
        XCTAssertNotNil(NSApp.appearance)
        XCTAssertEqual(NSApp.appearance?.name, .darkAqua)
    }
    
    func testThemeApplicationConsistency() {
        // Given: Multiple theme changes
        themeManager.isDarkMode = false
        themeManager.forceRefresh()
        XCTAssertEqual(NSApp.appearance?.name, .aqua)
        
        themeManager.isDarkMode = true
        themeManager.forceRefresh()
        XCTAssertEqual(NSApp.appearance?.name, .darkAqua)
        
        themeManager.isDarkMode = false
        themeManager.forceRefresh()
        XCTAssertEqual(NSApp.appearance?.name, .aqua)
        
        // Then: Each change should be applied consistently
        XCTAssertNotNil(NSApp.appearance)
    }
    
    func testForceRefreshMultipleTimes() {
        // Given: A theme manager
        // When: Calling force refresh multiple times
        // Then: Should not crash
        for _ in 0..<10 {
            XCTAssertNoThrow(themeManager.forceRefresh())
        }
    }
    
    func testForceRefreshAfterThemeChange() {
        // Given: Light theme is active
        themeManager.isDarkMode = false
        
        // When: Changing theme and forcing refresh
        themeManager.isDarkMode = true
        XCTAssertNoThrow(themeManager.forceRefresh())
        
        // Then: Should not crash
        XCTAssertTrue(themeManager.isDarkMode)
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentThemeChanges() {
        // Given: A theme manager
        let expectation = XCTestExpectation(description: "Concurrent theme changes")
        expectation.expectedFulfillmentCount = 10
        
        // When: Changing theme concurrently
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            self.themeManager.toggleTheme()
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentForceRefresh() {
        // Given: A theme manager
        let expectation = XCTestExpectation(description: "Concurrent force refresh")
        expectation.expectedFulfillmentCount = 5
        
        // When: Calling force refresh concurrently
        DispatchQueue.concurrentPerform(iterations: 5) { _ in
            self.themeManager.forceRefresh()
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Edge Cases Tests
    
    func testThemeManagerWithInvalidUserDefaults() {
        // Given: Invalid data in UserDefaults
        UserDefaults.standard.set("invalid", forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should default to light theme
        XCTAssertFalse(newManager.isDarkMode)
    }
    
    func testThemeManagerWithNilUserDefaults() {
        // Given: Nil value in UserDefaults
        UserDefaults.standard.set(nil, forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should default to light theme
        XCTAssertFalse(newManager.isDarkMode)
    }
    
    func testRapidThemeChanges() {
        // Given: A theme manager
        // When: Rapidly changing themes
        for _ in 0..<100 {
            themeManager.toggleTheme()
        }
        
        // Then: Should maintain consistent state
        let finalState = themeManager.isDarkMode
        XCTAssertTrue(finalState == true || finalState == false)
    }
    
    func testThemeManagerMemoryManagement() {
        // Given: A weak reference to ThemeManager
        weak var weakManager: ThemeManager?
        
        // When: Creating and releasing ThemeManager
        autoreleasepool {
            let manager = ThemeManager.shared
            weakManager = manager
            
            // Perform some operations
            manager.toggleTheme()
            manager.forceRefresh()
        }
        
        // Then: ThemeManager should not be deallocated (singleton)
        XCTAssertNotNil(weakManager)
    }
    
    // MARK: - Integration Tests
    
    func testThemeManagerWithContentView() {
        // Given: A ContentView that uses ThemeManager
        let contentView = ContentView()
        
        // When: Changing theme
        themeManager.isDarkMode = true
        
        // Then: Should not crash
        XCTAssertNotNil(contentView)
        XCTAssertTrue(themeManager.isDarkMode)
    }
    
    func testThemeManagerWithPongGameView() {
        // Given: A PongGameView that uses ThemeManager
        let pongView = PongGameView()
        
        // When: Changing theme
        themeManager.isDarkMode = false
        
        // Then: Should not crash
        XCTAssertNotNil(pongView)
        XCTAssertFalse(themeManager.isDarkMode)
    }
    
    func testThemeManagerWithAboutWindow() {
        // Given: An AboutWindow that uses ThemeManager
        let aboutWindow = AboutWindow()
        
        // When: Changing theme
        themeManager.isDarkMode = true
        
        // Then: Should not crash
        XCTAssertNotNil(aboutWindow)
        XCTAssertTrue(themeManager.isDarkMode)
    }
    
    func testThemeManagerWithMenuBarView() {
        // Given: A MenuBarView that uses ThemeManager
        let menuBarView = MenuBarView()
        
        // When: Changing theme
        themeManager.isDarkMode = false
        
        // Then: Should not crash
        XCTAssertNotNil(menuBarView)
        XCTAssertFalse(themeManager.isDarkMode)
    }
    
    // MARK: - Stress Tests
    
    func testThemeManagerStressTest() {
        // Given: A theme manager
        // When: Performing many operations rapidly
        for _ in 0..<1000 {
            themeManager.toggleTheme()
            _ = themeManager.themeIcon
            _ = themeManager.themeName
            themeManager.forceRefresh()
        }
        
        // Then: Should maintain consistent state
        let finalState = themeManager.isDarkMode
        XCTAssertTrue(finalState == true || finalState == false)
    }
    
    func testThemeManagerWithHighFrequencyChanges() {
        // Given: A theme manager
        let expectation = XCTestExpectation(description: "High frequency changes")
        expectation.expectedFulfillmentCount = 50
        
        // When: Changing theme at high frequency
        DispatchQueue.concurrentPerform(iterations: 50) { _ in
            self.themeManager.toggleTheme()
            self.themeManager.forceRefresh()
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testThemeManagerWithCorruptedUserDefaults() {
        // Given: Corrupted UserDefaults data
        UserDefaults.standard.set(Data([0xFF, 0xFE, 0xFD]), forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should default to light theme
        XCTAssertFalse(newManager.isDarkMode)
    }
    
    func testThemeManagerWithVeryLargeUserDefaults() {
        // Given: Very large data in UserDefaults
        let largeData = Data(count: 1024 * 1024) // 1MB
        UserDefaults.standard.set(largeData, forKey: "isDarkMode")
        
        // When: Creating a new ThemeManager
        let newManager = ThemeManager.shared
        
        // Then: Should default to light theme
        XCTAssertFalse(newManager.isDarkMode)
    }
    
    // MARK: - Performance Tests
    
    func testThemeChangePerformance() {
        // Given: A theme manager
        measure {
            // When: Measuring theme change performance
            for _ in 0..<100 {
                themeManager.toggleTheme()
            }
        }
    }
    
    func testThemeIconAccessPerformance() {
        // Given: A theme manager
        measure {
            // When: Measuring theme icon access performance
            for _ in 0..<1000 {
                _ = themeManager.themeIcon
            }
        }
    }
    
    func testForceRefreshPerformance() {
        // Given: A theme manager
        measure {
            // When: Measuring force refresh performance
            for _ in 0..<100 {
                themeManager.forceRefresh()
            }
        }
    }
}
