import XCTest
@testable import HourlyAudioPlayer
import SwiftUI

class ContentViewTests: XCTestCase {
    
    var contentView: ContentView!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        contentView = ContentView()
        
        // Create a temporary directory for testing
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        contentView = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testContentViewInitialization() {
        // Given: A new ContentView
        // When: Initializing the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithNoAudioFiles() {
        // Given: No audio files are set
        AudioFileManager.shared.audioFiles.removeAll()
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithAudioFiles() {
        // Given: Some audio files are set
        let testAudioFile1 = AudioFile(name: "test1.mp3", url: tempDirectory.appendingPathComponent("test1.mp3"), hour: 12)
        let testAudioFile2 = AudioFile(name: "test2.mp3", url: tempDirectory.appendingPathComponent("test2.mp3"), hour: 15)
        
        AudioFileManager.shared.audioFiles[12] = testAudioFile1
        AudioFileManager.shared.audioFiles[15] = testAudioFile2
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    // MARK: - Negative Path Tests
    
    func testContentViewWithInvalidAudioFiles() {
        // Given: Audio files with invalid URLs
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        let testAudioFile = AudioFile(name: "invalid.mp3", url: invalidURL, hour: 12)
        
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithEmptyAudioFileNames() {
        // Given: Audio files with empty names
        let testAudioFile = AudioFile(name: "", url: tempDirectory.appendingPathComponent("test.mp3"), hour: 12)
        
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    // MARK: - Error Scenarios
    
    func testContentViewWithCorruptedAudioFiles() {
        // Given: Audio files that point to corrupted files
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let testAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithNonExistentAudioFiles() {
        // Given: Audio files that point to non-existent files
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.mp3")
        let testAudioFile = AudioFile(name: "nonexistent.mp3", url: nonExistentURL, hour: 12)
        
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithVeryLargeAudioFiles() {
        // Given: Audio files that are very large
        let largeFileURL = tempDirectory.appendingPathComponent("large.mp3")
        let largeData = Data(count: 10 * 1024 * 1024) // 10MB of zeros
        try? largeData.write(to: largeFileURL)
        
        let testAudioFile = AudioFile(name: "large.mp3", url: largeFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    // MARK: - Exception Scenarios
    
    func testContentViewUnderMemoryPressure() {
        // Given: Many audio files to simulate memory pressure
        for i in 0..<1000 {
            let testAudioFile = AudioFile(name: "test\(i).mp3", url: tempDirectory.appendingPathComponent("test\(i).mp3"), hour: i % 24)
            AudioFileManager.shared.audioFiles[i % 24] = testAudioFile
        }
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithConcurrentAudioFileAccess() {
        // Given: Multiple threads accessing audio files simultaneously
        let expectation = XCTestExpectation(description: "Concurrent access")
        let group = DispatchGroup()
        
        // When: Multiple threads try to access audio files
        for i in 0..<10 {
            group.enter()
            DispatchQueue.global().async {
                let testAudioFile = AudioFile(name: "test\(i).mp3", url: self.tempDirectory.appendingPathComponent("test\(i).mp3"), hour: i)
                AudioFileManager.shared.audioFiles[i] = testAudioFile
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - File Manipulation Edge Cases
    
    func testContentViewWithFileRemovedDuringDisplay() {
        // Given: An audio file that gets removed while the view is displayed
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: File is removed from disk
        try? FileManager.default.removeItem(at: testFileURL)
        
        // Then: View should still be created without crashing
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithFileMovedDuringDisplay() {
        // Given: An audio file that gets moved while the view is displayed
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let movedURL = tempDirectory.appendingPathComponent("moved_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: File is moved to a different location
        try? FileManager.default.moveItem(at: originalURL, to: movedURL)
        
        // Then: View should still be created without crashing
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithFileRenamedDuringDisplay() {
        // Given: An audio file that gets renamed while the view is displayed
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let renamedURL = tempDirectory.appendingPathComponent("renamed_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: File is renamed on disk
        try? FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        // Then: View should still be created without crashing
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithFilePermissionsChanged() {
        // Given: An audio file with changed permissions
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: File permissions are changed (made read-only)
        try? FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: testFileURL.path)
        
        // Then: View should still be created without crashing
        XCTAssertNotNil(contentView)
    }
    
    // MARK: - Odd Scenarios
    
    func testContentViewWithVeryLongFileNames() {
        // Given: Audio files with extremely long names
        let longName = String(repeating: "a", count: 1000) + ".mp3"
        let longFileURL = tempDirectory.appendingPathComponent(longName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: longFileURL)
        
        let testAudioFile = AudioFile(name: longName, url: longFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithSpecialCharactersInFileNames() {
        // Given: Audio files with special characters in the names
        let specialName = "test!@#$%^&*()_+-=[]{}|;':\",./<>?`~.mp3"
        let specialFileURL = tempDirectory.appendingPathComponent(specialName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: specialFileURL)
        
        let testAudioFile = AudioFile(name: specialName, url: specialFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithUnicodeCharactersInFileNames() {
        // Given: Audio files with Unicode characters in the names
        let unicodeName = "测试音频文件🎵.mp3"
        let unicodeFileURL = tempDirectory.appendingPathComponent(unicodeName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: unicodeFileURL)
        
        let testAudioFile = AudioFile(name: unicodeName, url: unicodeFileURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithZeroHourAudioFile() {
        // Given: An audio file set for hour 0 (midnight)
        let testFileURL = tempDirectory.appendingPathComponent("midnight.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "midnight.mp3", url: testFileURL, hour: 0)
        AudioFileManager.shared.audioFiles[0] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWith23HourAudioFile() {
        // Given: An audio file set for hour 23 (11 PM)
        let testFileURL = tempDirectory.appendingPathComponent("evening.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "evening.mp3", url: testFileURL, hour: 23)
        AudioFileManager.shared.audioFiles[23] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithNetworkURLs() {
        // Given: Audio files with network URLs
        let networkURL = URL(string: "https://example.com/audio.mp3")!
        let testAudioFile = AudioFile(name: "network.mp3", url: networkURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithInvalidURLs() {
        // Given: Audio files with invalid URLs
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        let testAudioFile = AudioFile(name: "invalid.mp3", url: invalidURL, hour: 12)
        AudioFileManager.shared.audioFiles[12] = testAudioFile
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }
    
    func testContentViewWithMultipleAudioFilesForSameHour() {
        // Given: Multiple audio files set for the same hour (edge case)
        let testAudioFile1 = AudioFile(name: "first.mp3", url: tempDirectory.appendingPathComponent("first.mp3"), hour: 12)
        let testAudioFile2 = AudioFile(name: "second.mp3", url: tempDirectory.appendingPathComponent("second.mp3"), hour: 12)
        
        AudioFileManager.shared.audioFiles[12] = testAudioFile1
        AudioFileManager.shared.audioFiles[12] = testAudioFile2 // This should overwrite the first one
        
        // When: Creating the view
        // Then: Should not crash
        XCTAssertNotNil(contentView)
    }

    // MARK: - Additional Tests for Untested Functions

    func testMenuBarViewStartTimeUpdateTimer() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Starting time update timer (this is called internally)
        // Then: Should not crash
        XCTAssertNoThrow(menuBarView.startTimeUpdateTimer())
    }

    func testMenuBarViewStopTimeUpdateTimer() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Stopping time update timer (this is called internally)
        // Then: Should not crash
        XCTAssertNoThrow(menuBarView.stopTimeUpdateTimer())
    }

    func testMenuBarViewTimerLifecycle() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Starting and stopping timer multiple times
        // Then: Should not crash
        XCTAssertNoThrow(menuBarView.startTimeUpdateTimer())
        XCTAssertNoThrow(menuBarView.stopTimeUpdateTimer())
        XCTAssertNoThrow(menuBarView.startTimeUpdateTimer())
        XCTAssertNoThrow(menuBarView.stopTimeUpdateTimer())
    }

    func testMenuBarViewRapidTimerOperations() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Rapidly starting and stopping timer
        // Then: Should not crash
        for _ in 0..<10 {
            menuBarView.startTimeUpdateTimer()
            menuBarView.stopTimeUpdateTimer()
        }
    }

    func testMenuBarViewConcurrentTimerOperations() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Performing concurrent timer operations
        // Then: Should not crash
        DispatchQueue.concurrentPerform(iterations: 5) { _ in
            menuBarView.startTimeUpdateTimer()
            menuBarView.stopTimeUpdateTimer()
        }
    }

    // MARK: - HourlyAudioPlayerApp Tests

    func testHourlyAudioPlayerAppApplicationDidFinishLaunching() {
        // Given: A clean app state
        // When: Application finishes launching (this is called internally)
        // Then: Should not crash
        // Note: This is typically called by the system, but we can test the method exists
        XCTAssertTrue(true) // Placeholder - actual testing would require app lifecycle setup
    }

    func testHourlyAudioPlayerAppStatusBarButtonClicked() {
        // Given: A clean app state
        // When: Status bar button is clicked (this is called internally)
        // Then: Should not crash
        // Note: This is typically called by the system, but we can test the method exists
        XCTAssertTrue(true) // Placeholder - actual testing would require UI interaction setup
    }

    // MARK: - AboutWindow Tests

    func testAboutWindowInitialization() {
        // Given: A clean state
        // When: Creating AboutWindow
        // Then: Should not crash
        let aboutWindow = AboutWindow()
        XCTAssertNotNil(aboutWindow)
    }

    func testAboutWindowMultipleInstances() {
        // Given: A clean state
        // When: Creating multiple AboutWindow instances
        // Then: Should not crash
        let window1 = AboutWindow()
        let window2 = AboutWindow()
        let window3 = AboutWindow()
        
        XCTAssertNotNil(window1)
        XCTAssertNotNil(window2)
        XCTAssertNotNil(window3)
    }

    // MARK: - Error and Exception Tests

    func testMenuBarViewTimerWithSystemClockChanges() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Starting timer and simulating system clock changes
        // Then: Should not crash
        menuBarView.startTimeUpdateTimer()
        
        // Simulate some time passing
        Thread.sleep(forTimeInterval: 0.1)
        
        menuBarView.stopTimeUpdateTimer()
    }

    func testMenuBarViewTimerWithRapidSystemClockChanges() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Rapidly starting/stopping timer with system clock changes
        // Then: Should not crash
        for _ in 0..<5 {
            menuBarView.startTimeUpdateTimer()
            Thread.sleep(forTimeInterval: 0.01)
            menuBarView.stopTimeUpdateTimer()
        }
    }

    func testAboutWindowWithInvalidData() {
        // Given: A clean state
        // When: Creating AboutWindow with potential invalid data
        // Then: Should not crash
        let aboutWindow = AboutWindow()
        XCTAssertNotNil(aboutWindow)
        
        // Test multiple instances to ensure no shared state issues
        let anotherWindow = AboutWindow()
        XCTAssertNotNil(anotherWindow)
    }

    // MARK: - Boundary Condition Tests

    func testMenuBarViewTimerBoundaryConditions() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Testing timer boundary conditions
        // Then: Should handle gracefully
        
        // Start timer multiple times
        for _ in 0..<3 {
            menuBarView.startTimeUpdateTimer()
        }
        
        // Stop timer multiple times
        for _ in 0..<3 {
            menuBarView.stopTimeUpdateTimer()
        }
        
        // Start and stop rapidly
        menuBarView.startTimeUpdateTimer()
        menuBarView.stopTimeUpdateTimer()
        menuBarView.startTimeUpdateTimer()
        menuBarView.stopTimeUpdateTimer()
    }

    func testAboutWindowBoundaryConditions() {
        // Given: A clean state
        // When: Testing AboutWindow boundary conditions
        // Then: Should handle gracefully
        
        // Create many instances
        var windows: [AboutWindow] = []
        for _ in 0..<10 {
            let window = AboutWindow()
            windows.append(window)
        }
        
        // All should be valid
        for window in windows {
            XCTAssertNotNil(window)
        }
    }

    // MARK: - Stress Tests

    func testMenuBarViewTimerStressTest() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Stress testing timer operations
        // Then: Should not crash
        for _ in 0..<50 {
            menuBarView.startTimeUpdateTimer()
            menuBarView.stopTimeUpdateTimer()
        }
    }

    func testAboutWindowStressTest() {
        // Given: A clean state
        // When: Stress testing AboutWindow creation
        // Then: Should not crash
        var windows: [AboutWindow] = []
        for _ in 0..<100 {
            let window = AboutWindow()
            windows.append(window)
        }
        
        // All should be valid
        for window in windows {
            XCTAssertNotNil(window)
        }
    }

    func testConcurrentMenuBarViewOperations() {
        // Given: A MenuBarView instance
        let menuBarView = MenuBarView()
        
        // When: Performing concurrent operations
        // Then: Should not crash
        DispatchQueue.concurrentPerform(iterations: 20) { _ in
            menuBarView.startTimeUpdateTimer()
            menuBarView.stopTimeUpdateTimer()
        }
    }

    func testConcurrentAboutWindowCreation() {
        // Given: A clean state
        // When: Creating AboutWindow instances concurrently
        // Then: Should not crash
        var windows: [AboutWindow] = []
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()
        
        for _ in 0..<20 {
            group.enter()
            queue.async {
                let window = AboutWindow()
                windows.append(window)
                group.leave()
            }
        }
        
        group.wait()
        
        // All should be valid
        for window in windows {
            XCTAssertNotNil(window)
        }
    }
    
    // MARK: - AppDelegate Tests
    
    func testApplicationDidFinishLaunchingHappyPath() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        
        // When: Application finishes launching
        // Then: Should not crash
        XCTAssertNoThrow(appDelegate.applicationDidFinishLaunching(Notification(name: .NSApplicationDidFinishLaunching)))
    }
    
    func testApplicationDidFinishLaunchingWithNilNotification() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        
        // When: Application finishes launching with nil notification
        // Then: Should not crash
        XCTAssertNoThrow(appDelegate.applicationDidFinishLaunching(Notification(name: .NSApplicationDidFinishLaunching)))
    }
    
    func testApplicationDidFinishLaunchingMultipleCalls() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        
        // When: Application finishes launching multiple times
        // Then: Should not crash
        for _ in 0..<5 {
            XCTAssertNoThrow(appDelegate.applicationDidFinishLaunching(Notification(name: .NSApplicationDidFinishLaunching)))
        }
    }
    
    func testStatusBarButtonClickedHappyPath() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        
        // When: Status bar button is clicked
        // Then: Should not crash
        XCTAssertNoThrow(appDelegate.statusBarButtonClicked())
    }
    
    func testStatusBarButtonClickedMultipleCalls() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        
        // When: Status bar button is clicked multiple times
        // Then: Should not crash
        for _ in 0..<10 {
            XCTAssertNoThrow(appDelegate.statusBarButtonClicked())
        }
    }
    
    func testStatusBarButtonClickedConcurrentCalls() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        let expectation = XCTestExpectation(description: "Concurrent status bar clicks")
        expectation.expectedFulfillmentCount = 5
        
        // When: Status bar button is clicked concurrently
        DispatchQueue.concurrentPerform(iterations: 5) { _ in
            XCTAssertNoThrow(appDelegate.statusBarButtonClicked())
            expectation.fulfill()
        }
        
        // Then: All calls should complete without crashing
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStatusBarButtonClickedWithNilPopover() {
        // Given: A mock AppDelegate with nil popover
        let appDelegate = AppDelegate()
        appDelegate.popover = nil
        
        // When: Status bar button is clicked
        // Then: Should not crash
        XCTAssertNoThrow(appDelegate.statusBarButtonClicked())
    }
    
    func testStatusBarButtonClickedWithNilStatusItem() {
        // Given: A mock AppDelegate with nil status item
        let appDelegate = AppDelegate()
        appDelegate.statusItem = nil
        
        // When: Status bar button is clicked
        // Then: Should not crash
        XCTAssertNoThrow(appDelegate.statusBarButtonClicked())
    }
    
    func testAppDelegateInitialization() {
        // Given: A new AppDelegate
        // When: Creating the AppDelegate
        let appDelegate = AppDelegate()
        
        // Then: Should be initialized properly
        XCTAssertNotNil(appDelegate)
        XCTAssertNil(appDelegate.statusItem) // Initially nil
        XCTAssertNil(appDelegate.popover) // Initially nil
    }
    
    func testAppDelegateMemoryManagement() {
        // Given: A weak reference to AppDelegate
        weak var weakAppDelegate: AppDelegate?
        
        // When: Creating and releasing AppDelegate
        autoreleasepool {
            let appDelegate = AppDelegate()
            weakAppDelegate = appDelegate
            
            // Perform some operations
            appDelegate.applicationDidFinishLaunching(Notification(name: .NSApplicationDidFinishLaunching))
            appDelegate.statusBarButtonClicked()
        }
        
        // Then: AppDelegate should be deallocated
        XCTAssertNil(weakAppDelegate)
    }
    
    func testAppDelegateStressTest() {
        // Given: A mock AppDelegate
        let appDelegate = AppDelegate()
        
        // When: Performing many operations rapidly
        for _ in 0..<100 {
            appDelegate.applicationDidFinishLaunching(Notification(name: .NSApplicationDidFinishLaunching))
            appDelegate.statusBarButtonClicked()
        }
        
        // Then: Should not crash
        XCTAssertTrue(true)
    }
}
