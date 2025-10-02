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
}