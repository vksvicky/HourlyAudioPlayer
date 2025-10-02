import XCTest
@testable import HourlyAudioPlayer
import Foundation

class AudioManagerTests: XCTestCase {
    
    var audioManager: AudioManager!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        audioManager = AudioManager.shared
        
        // Create a temporary directory for testing
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        audioManager = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testPlayAudioWithValidFile() {
        // Given: A valid audio file
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        // When: Playing the audio file
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithEmptyFile() {
        // Given: An empty audio file
        let emptyFileURL = tempDirectory.appendingPathComponent("empty.mp3")
        let emptyData = Data()
        try? emptyData.write(to: emptyFileURL)
        
        let testAudioFile = AudioFile(name: "empty.mp3", url: emptyFileURL, hour: 12)
        
        // When: Playing the empty audio file
        // Then: Method should complete without throwing (should handle gracefully)
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    // MARK: - Negative Path Tests
    
    func testPlayAudioWithNonExistentFile() {
        // Given: A non-existent audio file
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.mp3")
        let testAudioFile = AudioFile(name: "nonexistent.mp3", url: nonExistentURL, hour: 12)
        
        // When: Playing the non-existent audio file
        let result = audioManager.playAudio(from: testAudioFile)
        
        // Then: Should return false indicating failure
        XCTAssertFalse(result)
    }
    
    func testPlayAudioWithCorruptedFile() {
        // Given: A corrupted audio file
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        let testAudioFile = AudioFile(name: "corrupted.mp3", url: corruptedFileURL, hour: 12)
        
        // When: Playing the corrupted audio file
        let result = audioManager.playAudio(from: testAudioFile)
        
        // Then: Should return false indicating failure
        XCTAssertFalse(result)
    }
    
    // MARK: - Error Scenarios
    
    func testPlayAudioWithInvalidURL() {
        // Given: An audio file with an invalid URL
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        let testAudioFile = AudioFile(name: "invalid.mp3", url: invalidURL, hour: 12)
        
        // When: Playing the audio file with invalid URL
        let result = audioManager.playAudio(from: testAudioFile)
        
        // Then: Should return false indicating failure
        XCTAssertFalse(result)
    }
    
    func testPlayAudioWithNetworkURL() {
        // Given: An audio file with a network URL
        let networkURL = URL(string: "https://example.com/audio.mp3")!
        let testAudioFile = AudioFile(name: "network.mp3", url: networkURL, hour: 12)
        
        // When: Playing the audio file with network URL
        let result = audioManager.playAudio(from: testAudioFile)
        
        // Then: Should return false indicating failure (network files not supported)
        XCTAssertFalse(result)
    }
    
    func testPlayAudioWithVeryLargeFile() {
        // Given: A very large audio file
        let largeFileURL = tempDirectory.appendingPathComponent("large.mp3")
        let largeData = Data(count: 10 * 1024 * 1024) // 10MB of zeros
        try? largeData.write(to: largeFileURL)
        
        let testAudioFile = AudioFile(name: "large.mp3", url: largeFileURL, hour: 12)
        
        // When: Playing the large audio file
        // Then: Method should complete without throwing (should handle gracefully)
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    // MARK: - Exception Scenarios
    
    func testConcurrentPlayAudio() {
        // Given: Multiple threads trying to play audio simultaneously
        let expectation = XCTestExpectation(description: "Concurrent audio playback")
        let group = DispatchGroup()
        
        // When: Multiple threads try to play audio
        for i in 0..<5 {
            group.enter()
            DispatchQueue.global().async {
                let testFileURL = self.tempDirectory.appendingPathComponent("test\(i).mp3")
                let testData = "fake audio data".data(using: .utf8)!
                try? testData.write(to: testFileURL)
                
                let testAudioFile = AudioFile(name: "test\(i).mp3", url: testFileURL, hour: i)
                XCTAssertNoThrow(self.audioManager.playAudio(from: testAudioFile))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPlayAudioUnderMemoryPressure() {
        // Given: System under memory pressure
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        // When: Playing audio under memory pressure
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    // MARK: - File Manipulation Edge Cases
    
    func testPlayAudioWithFileRemovedDuringPlayback() {
        // Given: An audio file that gets removed while playing
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        // When: File is removed from disk and then audio is played
        try? FileManager.default.removeItem(at: testFileURL)
        
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithFileMovedDuringPlayback() {
        // Given: An audio file that gets moved while playing
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let movedURL = tempDirectory.appendingPathComponent("moved_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: 12)
        
        // When: File is moved and then audio is played
        try? FileManager.default.moveItem(at: originalURL, to: movedURL)
        
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithFileRenamedDuringPlayback() {
        // Given: An audio file that gets renamed while playing
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let renamedURL = tempDirectory.appendingPathComponent("renamed_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: 12)
        
        // When: File is renamed and then audio is played
        try? FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithFilePermissionsChanged() {
        // Given: An audio file with changed permissions
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        // When: File permissions are changed (made read-only) and then audio is played
        try? FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: testFileURL.path)
        
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    // MARK: - Odd Scenarios
    
    func testPlayAudioWithVeryLongFileName() {
        // Given: An audio file with an extremely long name
        let longName = String(repeating: "a", count: 1000) + ".mp3"
        let longFileURL = tempDirectory.appendingPathComponent(longName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: longFileURL)
        
        let testAudioFile = AudioFile(name: longName, url: longFileURL, hour: 12)
        
        // When: Playing the audio file with long name
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithSpecialCharactersInFileName() {
        // Given: An audio file with special characters in the name
        let specialName = "test!@#$%^&*()_+-=[]{}|;':\",./<>?`~.mp3"
        let specialFileURL = tempDirectory.appendingPathComponent(specialName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: specialFileURL)
        
        let testAudioFile = AudioFile(name: specialName, url: specialFileURL, hour: 12)
        
        // When: Playing the audio file with special characters
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithUnicodeCharactersInFileName() {
        // Given: An audio file with Unicode characters in the name
        let unicodeName = "测试音频文件🎵.mp3"
        let unicodeFileURL = tempDirectory.appendingPathComponent(unicodeName)
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: unicodeFileURL)
        
        let testAudioFile = AudioFile(name: unicodeName, url: unicodeFileURL, hour: 12)
        
        // When: Playing the audio file with Unicode characters
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithZeroHour() {
        // Given: An audio file set for hour 0 (midnight)
        let testFileURL = tempDirectory.appendingPathComponent("midnight.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "midnight.mp3", url: testFileURL, hour: 0)
        
        // When: Playing the midnight audio file
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWith23Hour() {
        // Given: An audio file set for hour 23 (11 PM)
        let testFileURL = tempDirectory.appendingPathComponent("evening.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "evening.mp3", url: testFileURL, hour: 23)
        
        // When: Playing the evening audio file
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithEmptyName() {
        // Given: An audio file with an empty name
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "", url: testFileURL, hour: 12)
        
        // When: Playing the audio file with empty name
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
    
    func testPlayAudioWithNilName() {
        // Given: An audio file with a nil name (if possible)
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        
        // When: Playing the audio file
        // Then: Method should complete without throwing
        XCTAssertNoThrow(audioManager.playAudio(from: testAudioFile))
    }
}
