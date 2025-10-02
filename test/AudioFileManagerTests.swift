import XCTest
@testable import HourlyAudioPlayer
import Foundation

class AudioFileManagerTests: XCTestCase {
    
    var audioFileManager: AudioFileManager!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        audioFileManager = AudioFileManager.shared
        
        // Create a temporary directory for testing
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        audioFileManager = nil
        super.tearDown()
    }
    
    func testGetAudioDisplayNameWithNoAudio() {
        // Given: No audio files are set
        audioFileManager.audioFiles.removeAll()
        
        // When: Getting display name for any hour
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return "macOS Default"
        XCTAssertEqual(displayName, "macOS Default")
    }
    
    func testGetAudioDisplayNameWithSpecificAudio() {
        // Given: A specific audio file is set for hour 12
        let testAudioFile = AudioFile(name: "test-audio.mp3", url: URL(fileURLWithPath: "/test/path"), hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name for hour 12
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return the audio file name
        XCTAssertEqual(displayName, "test-audio.mp3")
    }
    
    func testGetAudioDisplayNameWithDifferentHour() {
        // Given: Audio file is set for hour 12, but we're asking for hour 15
        let testAudioFile = AudioFile(name: "test-audio.mp3", url: URL(fileURLWithPath: "/test/path"), hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name for hour 15
        let displayName = audioFileManager.getAudioDisplayName(for: 15)
        
        // Then: Should return "macOS Default" since no specific audio for hour 15
        XCTAssertEqual(displayName, "macOS Default")
    }
    
    func testRemoveAudioFile() {
        // Given: An audio file is set for hour 10
        let testAudioFile = AudioFile(name: "test-audio.mp3", url: URL(fileURLWithPath: "/test/path"), hour: 10)
        audioFileManager.audioFiles[10] = testAudioFile
        
        // When: Removing the audio file
        audioFileManager.removeAudioFile(for: 10)
        
        // Then: The audio file should be removed
        XCTAssertNil(audioFileManager.audioFiles[10])
    }
    
    // MARK: - Negative Path Tests
    
    func testGetAudioDisplayNameWithInvalidHour() {
        // Given: Invalid hour values
        let invalidHours = [-1, 24, 25, 100]
        
        for hour in invalidHours {
            // When: Getting display name for invalid hour
            let displayName = audioFileManager.getAudioDisplayName(for: hour)
            
            // Then: Should still return "macOS Default" without crashing
            XCTAssertEqual(displayName, "macOS Default")
        }
    }
    
    func testRemoveAudioFileForNonExistentHour() {
        // Given: No audio file exists for hour 12
        audioFileManager.audioFiles.removeAll()
        
        // When: Trying to remove audio file for hour 12
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.removeAudioFile(for: 12))
    }
    
    func testGetAudioFileForNonExistentHour() {
        // Given: No audio files are set
        audioFileManager.audioFiles.removeAll()
        
        // When: Getting audio file for hour 12
        let audioFile = audioFileManager.getAudioFile(for: 12)
        
        // Then: Should return nil
        XCTAssertNil(audioFile)
    }
    
    // MARK: - Error Scenarios
    
    func testAudioFileWithInvalidURL() {
        // Given: An audio file with an invalid URL
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        let testAudioFile = AudioFile(name: "test.mp3", url: invalidURL, hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should still return the name without crashing
        XCTAssertEqual(displayName, "test.mp3")
    }
    
    func testAudioFileWithEmptyName() {
        // Given: An audio file with an empty name
        let testAudioFile = AudioFile(name: "", url: tempDirectory.appendingPathComponent("test.mp3"), hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return empty string without crashing
        XCTAssertEqual(displayName, "")
    }
    
    // MARK: - Exception Scenarios
    
    func testConcurrentAccessToAudioFiles() {
        // Given: Multiple threads accessing audioFiles simultaneously
        let expectation = XCTestExpectation(description: "Concurrent access")
        let group = DispatchGroup()
        
        // When: Multiple threads try to access audioFiles
        for i in 0..<10 {
            group.enter()
            DispatchQueue.global().async {
                let testAudioFile = AudioFile(name: "test\(i).mp3", url: self.tempDirectory.appendingPathComponent("test\(i).mp3"), hour: i)
                self.audioFileManager.audioFiles[i] = testAudioFile
                let displayName = self.audioFileManager.getAudioDisplayName(for: i)
                XCTAssertEqual(displayName, "test\(i).mp3")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        // Then: Should complete without crashing
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMemoryPressureDuringAudioFileOperations() {
        // Given: A large number of audio files
        for i in 0..<1000 {
            let testAudioFile = AudioFile(name: "test\(i).mp3", url: tempDirectory.appendingPathComponent("test\(i).mp3"), hour: i % 24)
            audioFileManager.audioFiles[i % 24] = testAudioFile
        }
        
        // When: Performing operations under memory pressure
        for i in 0..<100 {
            let displayName = audioFileManager.getAudioDisplayName(for: i % 24)
            XCTAssertNotNil(displayName)
        }
        
        // Then: Should complete without crashing
        XCTAssertTrue(true)
    }
    
    // MARK: - File Manipulation Edge Cases
    
    func testAudioFileRemovedDuringPlayback() {
        // Given: An audio file is set and a file exists on disk
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: File is removed from disk while still in memory
        try? FileManager.default.removeItem(at: testFileURL)
        
        // Then: Getting display name should still work (file exists in memory)
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        XCTAssertEqual(displayName, "test.mp3")
    }
    
    func testAudioFileMovedDuringPlayback() {
        // Given: An audio file is set and a file exists on disk
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let movedURL = tempDirectory.appendingPathComponent("moved_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: File is moved to a different location
        try? FileManager.default.moveItem(at: originalURL, to: movedURL)
        
        // Then: Getting display name should still work (file exists in memory)
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        XCTAssertEqual(displayName, "test.mp3")
    }
    
    func testAudioFileRenamedDuringPlayback() {
        // Given: An audio file is set and a file exists on disk
        let originalURL = tempDirectory.appendingPathComponent("test.mp3")
        let renamedURL = tempDirectory.appendingPathComponent("renamed_test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: originalURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: originalURL, hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: File is renamed on disk
        try? FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        // Then: Getting display name should still work (file exists in memory)
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        XCTAssertEqual(displayName, "test.mp3")
    }
    
    func testAudioFilePermissionsChangedDuringPlayback() {
        // Given: An audio file is set and a file exists on disk
        let testFileURL = tempDirectory.appendingPathComponent("test.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "test.mp3", url: testFileURL, hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: File permissions are changed (made read-only)
        try? FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: testFileURL.path)
        
        // Then: Getting display name should still work (file exists in memory)
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        XCTAssertEqual(displayName, "test.mp3")
    }
    
    // MARK: - Odd Scenarios
    
    func testAudioFileWithVeryLongName() {
        // Given: An audio file with an extremely long name
        let longName = String(repeating: "a", count: 1000)
        let testAudioFile = AudioFile(name: longName, url: tempDirectory.appendingPathComponent("test.mp3"), hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return the long name without crashing
        XCTAssertEqual(displayName, longName)
    }
    
    func testAudioFileWithSpecialCharacters() {
        // Given: An audio file with special characters in the name
        let specialName = "test!@#$%^&*()_+-=[]{}|;':\",./<>?`~.mp3"
        let testAudioFile = AudioFile(name: specialName, url: tempDirectory.appendingPathComponent("test.mp3"), hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return the special name without crashing
        XCTAssertEqual(displayName, specialName)
    }
    
    func testAudioFileWithUnicodeCharacters() {
        // Given: An audio file with Unicode characters in the name
        let unicodeName = "测试音频文件🎵.mp3"
        let testAudioFile = AudioFile(name: unicodeName, url: tempDirectory.appendingPathComponent("test.mp3"), hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return the Unicode name without crashing
        XCTAssertEqual(displayName, unicodeName)
    }
    
    func testAudioFileWithZeroHour() {
        // Given: An audio file set for hour 0 (midnight)
        let testAudioFile = AudioFile(name: "midnight.mp3", url: tempDirectory.appendingPathComponent("midnight.mp3"), hour: 0)
        audioFileManager.audioFiles[0] = testAudioFile
        
        // When: Getting display name for hour 0
        let displayName = audioFileManager.getAudioDisplayName(for: 0)
        
        // Then: Should return the midnight audio name
        XCTAssertEqual(displayName, "midnight.mp3")
    }
    
    func testAudioFileWith23Hour() {
        // Given: An audio file set for hour 23 (11 PM)
        let testAudioFile = AudioFile(name: "evening.mp3", url: tempDirectory.appendingPathComponent("evening.mp3"), hour: 23)
        audioFileManager.audioFiles[23] = testAudioFile
        
        // When: Getting display name for hour 23
        let displayName = audioFileManager.getAudioDisplayName(for: 23)
        
        // Then: Should return the evening audio name
        XCTAssertEqual(displayName, "evening.mp3")
    }
    
    func testMultipleAudioFilesForSameHour() {
        // Given: Multiple audio files set for the same hour (edge case)
        let testAudioFile1 = AudioFile(name: "first.mp3", url: tempDirectory.appendingPathComponent("first.mp3"), hour: 12)
        let testAudioFile2 = AudioFile(name: "second.mp3", url: tempDirectory.appendingPathComponent("second.mp3"), hour: 12)
        
        audioFileManager.audioFiles[12] = testAudioFile1
        audioFileManager.audioFiles[12] = testAudioFile2 // This should overwrite the first one
        
        // When: Getting display name for hour 12
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return the last set audio file name
        XCTAssertEqual(displayName, "second.mp3")
    }
    
    func testAudioFileWithNetworkURL() {
        // Given: An audio file with a network URL (edge case)
        let networkURL = URL(string: "https://example.com/audio.mp3")!
        let testAudioFile = AudioFile(name: "network.mp3", url: networkURL, hour: 12)
        audioFileManager.audioFiles[12] = testAudioFile
        
        // When: Getting display name
        let displayName = audioFileManager.getAudioDisplayName(for: 12)
        
        // Then: Should return the network audio name without crashing
        XCTAssertEqual(displayName, "network.mp3")
    }
}
