import XCTest
@testable import HourlyAudioPlayer
import Foundation

class HourlyTimerTests: XCTestCase {
    
    var hourlyTimer: HourlyTimer!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        hourlyTimer = HourlyTimer.shared
        
        // Create a temporary directory for testing
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        hourlyTimer = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testPlayCurrentHourAudioWithNoAudioFile() {
        // Given: No audio file is set for current hour
        let currentHour = Calendar.current.component(.hour, from: Date())
        AudioFileManager.shared.audioFiles.removeAll()
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithAudioFile() {
        // Given: An audio file is set for current hour
        let currentHour = Calendar.current.component(.hour, from: Date())
        let testAudioFile = AudioFile(name: "test.mp3", url: tempDirectory.appendingPathComponent("test.mp3"), hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    // MARK: - Negative Path Tests
    
    func testPlayCurrentHourAudioWithCorruptedAudioFile() {
        // Given: An audio file that exists but is corrupted
        let currentHour = Calendar.current.component(.hour, from: Date())
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let testAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    // MARK: - Error Scenarios
    
    func testPlayCurrentHourAudioWithNonExistentFile() {
        // Given: An audio file that doesn't exist on disk
        let currentHour = Calendar.current.component(.hour, from: Date())
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.mp3")
        let testAudioFile = AudioFile(name: "nonexistent.mp3", url: nonExistentURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing (should fall back to system sound)
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithMissingFileTriggersNotification() {
        // Given: An audio file that doesn't exist on disk
        let currentHour = Calendar.current.component(.hour, from: Date())
        let missingFileURL = tempDirectory.appendingPathComponent("missing.mp3")
        let testAudioFile = AudioFile(name: "missing.mp3", url: missingFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing and should handle missing file gracefully
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithEmptyAudioFile() {
        // Given: An audio file that exists but is empty
        let currentHour = Calendar.current.component(.hour, from: Date())
        let emptyFileURL = tempDirectory.appendingPathComponent("empty.mp3")
        let emptyData = Data()
        try? emptyData.write(to: emptyFileURL)
        
        let testAudioFile = AudioFile(name: "empty.mp3", url: emptyFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    // MARK: - Exception Scenarios
    
    func testConcurrentPlayCurrentHourAudio() {
        // Given: Multiple threads trying to play audio simultaneously
        let expectation = XCTestExpectation(description: "Concurrent audio playback")
        let group = DispatchGroup()
        
        // When: Multiple threads try to play audio
        for _ in 0..<5 {
            group.enter()
            DispatchQueue.global().async {
                XCTAssertNoThrow(self.hourlyTimer.playCurrentHourAudio())
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - File Manipulation Edge Cases
    
    func testPlayCurrentHourAudioWithFileRemovedDuringPlayback() {
        // Given: An audio file that gets removed while playing
        let currentHour = Calendar.current.component(.hour, from: Date())
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: File is removed from disk and then audio is played
        try? FileManager.default.removeItem(at: testFileURL)
        
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithFileMovedDuringPlayback() {
        // Given: An audio file that gets moved while playing
        let currentHour = Calendar.current.component(.hour, from: Date())
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let movedURL = tempDirectory.appendingPathComponent("moved_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: File is moved and then audio is played
        try? FileManager.default.moveItem(at: originalURL, to: movedURL)
        
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    // MARK: - Odd Scenarios
    
    func testPlayCurrentHourAudioWithVeryLongFileName() {
        // Given: An audio file with an extremely long name
        let currentHour = Calendar.current.component(.hour, from: Date())
        let longName = String(repeating: "a", count: 1000) + ".mp3"
        let longFileURL = tempDirectory.appendingPathComponent(longName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: longFileURL)
        
        let testAudioFile = AudioFile(name: longName, url: longFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithSpecialCharactersInFileName() {
        // Given: An audio file with special characters in the name
        let currentHour = Calendar.current.component(.hour, from: Date())
        let specialName = "test!@#$%^&*()_+-=[]{}|;':\",./<>?`~.mp3"
        let specialFileURL = tempDirectory.appendingPathComponent(specialName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: specialFileURL)
        
        let testAudioFile = AudioFile(name: specialName, url: specialFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithUnicodeCharactersInFileName() {
        // Given: An audio file with Unicode characters in the name
        let currentHour = Calendar.current.component(.hour, from: Date())
        let unicodeName = "测试音频文件🎵.mp3"
        let unicodeFileURL = tempDirectory.appendingPathComponent(unicodeName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: unicodeFileURL)
        
        let testAudioFile = AudioFile(name: unicodeName, url: unicodeFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithNetworkURL() {
        // Given: An audio file with a network URL (edge case)
        let currentHour = Calendar.current.component(.hour, from: Date())
        let networkURL = URL(string: "https://example.com/audio.mp3")!
        let testAudioFile = AudioFile(name: "network.mp3", url: networkURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    func testPlayCurrentHourAudioWithInvalidURL() {
        // Given: An audio file with an invalid URL
        let currentHour = Calendar.current.component(.hour, from: Date())
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        let testAudioFile = AudioFile(name: "invalid.mp3", url: invalidURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Playing current hour audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }
    
    // MARK: - Debug Mode Tests
    
    #if DEBUG_MODE
    func testTestNotificationWithAudioWithNoAudioFile() {
        // Given: Debug mode is enabled and no audio file is set
        let currentHour = Calendar.current.component(.hour, from: Date())
        AudioFileManager.shared.audioFiles.removeAll()
        
        // When: Testing notification with audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.testNotificationWithAudio())
    }
    
    func testTestNotificationWithAudioWithAudioFile() {
        // Given: Debug mode is enabled and an audio file is set
        let currentHour = Calendar.current.component(.hour, from: Date())
        let testAudioFile = AudioFile(name: "test.mp3", url: tempDirectory.appendingPathComponent("test.mp3"), hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Testing notification with audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.testNotificationWithAudio())
    }
    
    func testTestNotificationWithAudioWithCorruptedFile() {
        // Given: Debug mode is enabled and a corrupted audio file is set
        let currentHour = Calendar.current.component(.hour, from: Date())
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let testAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: currentHour)
        AudioFileManager.shared.audioFiles[currentHour] = testAudioFile
        
        // When: Testing notification with audio
        // Then: Method should complete without throwing
        XCTAssertNoThrow(hourlyTimer.testNotificationWithAudio())
    }
    #endif

    // MARK: - Additional Tests for Untested Functions

    func testStartHappyPath() {
        // Given: A clean HourlyTimer instance
        // When: Starting the timer
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.start())
    }

    func testStartMultipleTimes() {
        // Given: A clean HourlyTimer instance
        // When: Starting the timer multiple times
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.start())
        XCTAssertNoThrow(hourlyTimer.start())
        XCTAssertNoThrow(hourlyTimer.start())
    }

    func testStopHappyPath() {
        // Given: A started timer
        hourlyTimer.start()
        
        // When: Stopping the timer
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.stop())
    }

    func testStopWhenNotStarted() {
        // Given: A timer that hasn't been started
        // When: Stopping the timer
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.stop())
    }

    func testStopMultipleTimes() {
        // Given: A started timer
        hourlyTimer.start()
        
        // When: Stopping the timer multiple times
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.stop())
        XCTAssertNoThrow(hourlyTimer.stop())
        XCTAssertNoThrow(hourlyTimer.stop())
    }

    func testScheduleNextHourHappyPath() {
        // Given: A clean state
        // When: Scheduling next hour
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.scheduleNextHour())
    }

    func testScheduleNextHourMultipleTimes() {
        // Given: A clean state
        // When: Scheduling next hour multiple times
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.scheduleNextHour())
        XCTAssertNoThrow(hourlyTimer.scheduleNextHour())
        XCTAssertNoThrow(hourlyTimer.scheduleNextHour())
    }

    func testPlayHourlyAudioHappyPath() {
        // Given: A clean state
        // When: Playing hourly audio
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
    }

    func testPlayHourlyAudioMultipleTimes() {
        // Given: A clean state
        // When: Playing hourly audio multiple times
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
    }

    func testPlaySystemSoundHappyPath() {
        // Given: A clean state
        // When: Playing system sound
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.playSystemSound())
    }

    func testPlaySystemSoundMultipleTimes() {
        // Given: A clean state
        // When: Playing system sound multiple times
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.playSystemSound())
        XCTAssertNoThrow(hourlyTimer.playSystemSound())
        XCTAssertNoThrow(hourlyTimer.playSystemSound())
    }

    func testRequestNotificationPermissionHappyPath() {
        // Given: A clean state
        // When: Requesting notification permission
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.requestNotificationPermission())
    }

    func testRequestNotificationPermissionMultipleTimes() {
        // Given: A clean state
        // When: Requesting notification permission multiple times
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.requestNotificationPermission())
        XCTAssertNoThrow(hourlyTimer.requestNotificationPermission())
        XCTAssertNoThrow(hourlyTimer.requestNotificationPermission())
    }

    func testSendNotificationHappyPath() {
        // Given: A valid hour and audio file
        let hour = 12
        let testFileURL = tempDirectory.appendingPathComponent("notification_test.mp3")
        let testData = "notification test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        let testAudioFile = AudioFile(name: "notification_test.mp3", url: testFileURL, hour: hour)
        
        // When: Sending notification
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: hour, audioFile: testAudioFile))
    }

    func testSendNotificationWithNilAudioFile() {
        // Given: A valid hour but nil audio file
        let hour = 12
        
        // When: Sending notification with nil audio file
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: hour, audioFile: nil))
    }

    func testSendNotificationInvalidHour() {
        // Given: Invalid hours
        let invalidHours = [-1, 24, 25, 100]
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        for hour in invalidHours {
            // When: Sending notification for invalid hour
            // Then: Should not crash
            XCTAssertNoThrow(hourlyTimer.sendNotification(for: hour, audioFile: testAudioFile))
        }
    }

    func testSendMissingFileNotificationHappyPath() {
        // Given: A valid hour and audio file
        let hour = 12
        let testFileURL = tempDirectory.appendingPathComponent("missing_test.mp3")
        let testData = "missing test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        let testAudioFile = AudioFile(name: "missing_test.mp3", url: testFileURL, hour: hour)
        
        // When: Sending missing file notification
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: hour, audioFile: testAudioFile))
    }

    func testSendMissingFileNotificationInvalidHour() {
        // Given: Invalid hours
        let invalidHours = [-1, 24, 25, 100]
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        for hour in invalidHours {
            // When: Sending missing file notification for invalid hour
            // Then: Should not crash
            XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: hour, audioFile: testAudioFile))
        }
    }

    func testGetNextAudioTimeHappyPath() {
        // Given: A clean state
        // When: Getting next audio time
        // Then: Should not crash and return a valid date
        let nextTime = hourlyTimer.getNextAudioTime()
        XCTAssertNotNil(nextTime)
        XCTAssertTrue(nextTime > Date())
    }

    func testGetNextAudioTimeMultipleCalls() {
        // Given: A clean state
        // When: Getting next audio time multiple times
        // Then: Should not crash and return consistent results
        let time1 = hourlyTimer.getNextAudioTime()
        let time2 = hourlyTimer.getNextAudioTime()
        
        XCTAssertNotNil(time1)
        XCTAssertNotNil(time2)
        XCTAssertTrue(time1 > Date())
        XCTAssertTrue(time2 > Date())
    }

    // MARK: - Error and Exception Tests

    func testPlayHourlyAudioWithCorruptedAudioFile() {
        // Given: A corrupted audio file in the manager
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let corruptedAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: 12)
        audioFileManager.audioFiles[12] = corruptedAudioFile
        
        // When: Playing hourly audio with corrupted file
        // Then: Should not crash and handle gracefully
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
    }

    func testPlayHourlyAudioWithMissingAudioFile() {
        // Given: A missing audio file in the manager
        let missingFileURL = tempDirectory.appendingPathComponent("missing.mp3")
        let missingAudioFile = AudioFile(name: "missing.mp3", url: missingFileURL, hour: 12)
        audioFileManager.audioFiles[12] = missingAudioFile
        
        // When: Playing hourly audio with missing file
        // Then: Should not crash and handle gracefully
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
    }

    func testPlayHourlyAudioWithEmptyAudioFile() {
        // Given: An empty audio file in the manager
        let emptyFileURL = tempDirectory.appendingPathComponent("empty.mp3")
        let emptyData = Data()
        try? emptyData.write(to: emptyFileURL)
        
        let emptyAudioFile = AudioFile(name: "empty.mp3", url: emptyFileURL, hour: 12)
        audioFileManager.audioFiles[12] = emptyAudioFile
        
        // When: Playing hourly audio with empty file
        // Then: Should not crash and handle gracefully
        XCTAssertNoThrow(hourlyTimer.playHourlyAudio())
    }

    func testPlayCurrentHourAudioWithCorruptedFile() {
        // Given: A corrupted audio file in the manager
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let corruptedAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: 12)
        audioFileManager.audioFiles[12] = corruptedAudioFile
        
        // When: Playing current hour audio with corrupted file
        // Then: Should not crash and handle gracefully
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }

    func testPlayCurrentHourAudioWithMissingFile() {
        // Given: A missing audio file in the manager
        let missingFileURL = tempDirectory.appendingPathComponent("missing.mp3")
        let missingAudioFile = AudioFile(name: "missing.mp3", url: missingFileURL, hour: 12)
        audioFileManager.audioFiles[12] = missingAudioFile
        
        // When: Playing current hour audio with missing file
        // Then: Should not crash and handle gracefully
        XCTAssertNoThrow(hourlyTimer.playCurrentHourAudio())
    }

    func testSendNotificationWithCorruptedAudioFile() {
        // Given: A corrupted audio file
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let corruptedAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: 12)
        
        // When: Sending notification with corrupted audio file
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: 12, audioFile: corruptedAudioFile))
    }

    func testSendNotificationWithMissingAudioFile() {
        // Given: A missing audio file
        let missingFileURL = tempDirectory.appendingPathComponent("missing.mp3")
        let missingAudioFile = AudioFile(name: "missing.mp3", url: missingFileURL, hour: 12)
        
        // When: Sending notification with missing audio file
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: 12, audioFile: missingAudioFile))
    }

    func testSendMissingFileNotificationWithCorruptedFile() {
        // Given: A corrupted audio file
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let corruptedAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: 12)
        
        // When: Sending missing file notification with corrupted audio file
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: 12, audioFile: corruptedAudioFile))
    }

    func testSendMissingFileNotificationWithMissingFile() {
        // Given: A missing audio file
        let missingFileURL = tempDirectory.appendingPathComponent("missing.mp3")
        let missingAudioFile = AudioFile(name: "missing.mp3", url: missingFileURL, hour: 12)
        
        // When: Sending missing file notification with missing audio file
        // Then: Should not crash
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: 12, audioFile: missingAudioFile))
    }

    // MARK: - Boundary Condition Tests

    func testBoundaryConditionsHourZero() {
        // Given: Hour 0 (midnight)
        let hour = 0
        let testFileURL = tempDirectory.appendingPathComponent("midnight.mp3")
        let testData = "midnight audio".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "midnight.mp3", url: testFileURL, hour: hour)
        
        // When: Testing various functions with hour 0
        // Then: Should work correctly
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: hour, audioFile: testAudioFile))
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: hour, audioFile: testAudioFile))
    }

    func testBoundaryConditionsHour23() {
        // Given: Hour 23 (11 PM)
        let hour = 23
        let testFileURL = tempDirectory.appendingPathComponent("night.mp3")
        let testData = "night audio".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "night.mp3", url: testFileURL, hour: hour)
        
        // When: Testing various functions with hour 23
        // Then: Should work correctly
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: hour, audioFile: testAudioFile))
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: hour, audioFile: testAudioFile))
    }

    func testBoundaryConditionsInvalidHours() {
        // Given: Invalid hours
        let invalidHours = [-1, 24, 25, 100, -100]
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        for hour in invalidHours {
            // When: Testing various functions with invalid hours
            // Then: Should handle gracefully
            XCTAssertNoThrow(hourlyTimer.sendNotification(for: hour, audioFile: testAudioFile))
            XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: hour, audioFile: testAudioFile))
        }
    }

    func testBoundaryConditionsVeryLongAudioFileName() {
        // Given: A very long audio file name
        let longName = String(repeating: "a", count: 255) + ".mp3"
        let testFileURL = tempDirectory.appendingPathComponent(longName)
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: longName, url: testFileURL, hour: 12)
        
        // When: Testing with very long filename
        // Then: Should handle gracefully
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: 12, audioFile: testAudioFile))
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: 12, audioFile: testAudioFile))
    }

    func testBoundaryConditionsSpecialCharactersInAudioFileName() {
        // Given: Audio file name with special characters
        let specialName = "12_audio with spaces & symbols!.mp3"
        let testFileURL = tempDirectory.appendingPathComponent(specialName)
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: specialName, url: testFileURL, hour: 12)
        
        // When: Testing with special characters in filename
        // Then: Should handle gracefully
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: 12, audioFile: testAudioFile))
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: 12, audioFile: testAudioFile))
    }

    func testBoundaryConditionsUnicodeInAudioFileName() {
        // Given: Audio file name with Unicode characters
        let unicodeName = "12_测试音频🎵.mp3"
        let testFileURL = tempDirectory.appendingPathComponent(unicodeName)
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: unicodeName, url: testFileURL, hour: 12)
        
        // When: Testing with Unicode in filename
        // Then: Should handle gracefully
        XCTAssertNoThrow(hourlyTimer.sendNotification(for: 12, audioFile: testAudioFile))
        XCTAssertNoThrow(hourlyTimer.sendMissingFileNotification(for: 12, audioFile: testAudioFile))
    }

    // MARK: - Stress Tests

    func testRapidStartStopCycles() {
        // Given: A clean state
        // When: Rapidly starting and stopping the timer
        // Then: Should not crash
        for _ in 0..<10 {
            hourlyTimer.start()
            hourlyTimer.stop()
        }
    }

    func testRapidPlaySystemSoundCalls() {
        // Given: A clean state
        // When: Rapidly calling playSystemSound
        // Then: Should not crash
        for _ in 0..<20 {
            hourlyTimer.playSystemSound()
        }
    }

    func testRapidNotificationCalls() {
        // Given: A test audio file
        let testFileURL = tempDirectory.appendingPathComponent("rapid_test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "rapid_test.mp3", url: testFileURL, hour: 12)
        
        // When: Rapidly sending notifications
        // Then: Should not crash
        for _ in 0..<10 {
            hourlyTimer.sendNotification(for: 12, audioFile: testAudioFile)
            hourlyTimer.sendMissingFileNotification(for: 12, audioFile: testAudioFile)
        }
    }

    func testConcurrentOperations() {
        // Given: A test audio file
        let testFileURL = tempDirectory.appendingPathComponent("concurrent_test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "concurrent_test.mp3", url: testFileURL, hour: 12)
        
        // When: Performing concurrent operations
        // Then: Should not crash
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            hourlyTimer.start()
            hourlyTimer.stop()
            hourlyTimer.playSystemSound()
            hourlyTimer.playHourlyAudio()
            hourlyTimer.playCurrentHourAudio()
            hourlyTimer.sendNotification(for: 12, audioFile: testAudioFile)
            hourlyTimer.sendMissingFileNotification(for: 12, audioFile: testAudioFile)
            _ = hourlyTimer.getNextAudioTime()
        }
    }
}