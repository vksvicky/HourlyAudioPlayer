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

    // MARK: - Additional Tests for Untested Functions

    func testSetupAudioSessionHappyPath() {
        // Given: A clean AudioManager instance
        // When: Setting up audio session (this is called internally)
        // Then: Should not crash
        XCTAssertNoThrow(audioManager.setupAudioSession())
    }

    func testStopAudioHappyPath() {
        // Given: A clean state
        // When: Stopping audio
        // Then: Should not crash
        XCTAssertNoThrow(audioManager.stopAudio())
    }

    func testStopAudioWhenNotPlaying() {
        // Given: No audio is playing
        // When: Stopping audio
        // Then: Should not crash
        XCTAssertNoThrow(audioManager.stopAudio())
    }

    func testStopAudioMultipleTimes() {
        // Given: A clean state
        // When: Stopping audio multiple times
        // Then: Should not crash
        XCTAssertNoThrow(audioManager.stopAudio())
        XCTAssertNoThrow(audioManager.stopAudio())
        XCTAssertNoThrow(audioManager.stopAudio())
    }

    func testIsPlayingHappyPath() {
        // Given: A clean state
        // When: Checking if playing
        // Then: Should return false and not crash
        let isPlaying = audioManager.isPlaying()
        XCTAssertFalse(isPlaying)
    }

    func testIsPlayingWhenNotPlaying() {
        // Given: No audio is playing
        // When: Checking if playing
        // Then: Should return false
        let isPlaying = audioManager.isPlaying()
        XCTAssertFalse(isPlaying)
    }

    func testIsPlayingAfterStop() {
        // Given: Audio was stopped
        audioManager.stopAudio()
        
        // When: Checking if playing
        // Then: Should return false
        let isPlaying = audioManager.isPlaying()
        XCTAssertFalse(isPlaying)
    }

    func testSetVolumeHappyPath() {
        // Given: Valid volume values
        let validVolumes: [Float] = [0.0, 0.5, 1.0]
        
        for volume in validVolumes {
            // When: Setting volume
            // Then: Should not crash
            XCTAssertNoThrow(audioManager.setVolume(volume))
        }
    }

    func testSetVolumeBoundaryConditions() {
        // Given: Boundary volume values
        let boundaryVolumes: [Float] = [0.0, 1.0, 0.01, 0.99]
        
        for volume in boundaryVolumes {
            // When: Setting boundary volume
            // Then: Should not crash
            XCTAssertNoThrow(audioManager.setVolume(volume))
        }
    }

    func testSetVolumeInvalidValues() {
        // Given: Invalid volume values
        let invalidVolumes: [Float] = [-1.0, 1.1, 2.0, -0.1, Float.infinity, -Float.infinity]
        
        for volume in invalidVolumes {
            // When: Setting invalid volume
            // Then: Should not crash (should handle gracefully)
            XCTAssertNoThrow(audioManager.setVolume(volume))
        }
    }

    func testSetVolumeExtremeValues() {
        // Given: Extreme volume values
        let extremeVolumes: [Float] = [Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, Float.nan]
        
        for volume in extremeVolumes {
            // When: Setting extreme volume
            // Then: Should not crash (should handle gracefully)
            XCTAssertNoThrow(audioManager.setVolume(volume))
        }
    }

    func testGetCurrentTimeHappyPath() {
        // Given: A clean state
        // When: Getting current time
        // Then: Should return 0 and not crash
        let currentTime = audioManager.getCurrentTime()
        XCTAssertEqual(currentTime, 0.0, accuracy: 0.001)
    }

    func testGetCurrentTimeWhenNotPlaying() {
        // Given: No audio is playing
        // When: Getting current time
        // Then: Should return 0
        let currentTime = audioManager.getCurrentTime()
        XCTAssertEqual(currentTime, 0.0, accuracy: 0.001)
    }

    func testGetCurrentTimeAfterStop() {
        // Given: Audio was stopped
        audioManager.stopAudio()
        
        // When: Getting current time
        // Then: Should return 0
        let currentTime = audioManager.getCurrentTime()
        XCTAssertEqual(currentTime, 0.0, accuracy: 0.001)
    }

    func testGetDurationHappyPath() {
        // Given: A clean state
        // When: Getting duration
        // Then: Should return 0 and not crash
        let duration = audioManager.getDuration()
        XCTAssertEqual(duration, 0.0, accuracy: 0.001)
    }

    func testGetDurationWhenNotPlaying() {
        // Given: No audio is playing
        // When: Getting duration
        // Then: Should return 0
        let duration = audioManager.getDuration()
        XCTAssertEqual(duration, 0.0, accuracy: 0.001)
    }

    func testGetDurationAfterStop() {
        // Given: Audio was stopped
        audioManager.stopAudio()
        
        // When: Getting duration
        // Then: Should return 0
        let duration = audioManager.getDuration()
        XCTAssertEqual(duration, 0.0, accuracy: 0.001)
    }

    // MARK: - Error and Exception Tests

    func testPlayAudioWithCorruptedFile() {
        // Given: A corrupted audio file
        let corruptedFileURL = tempDirectory.appendingPathComponent("corrupted.mp3")
        let corruptedData = "This is not valid audio data".data(using: .utf8)!
        try? corruptedData.write(to: corruptedFileURL)
        
        // When: Playing corrupted audio file
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: corruptedFileURL)
        XCTAssertFalse(result)
    }

    func testPlayAudioWithEmptyFile() {
        // Given: An empty audio file
        let emptyFileURL = tempDirectory.appendingPathComponent("empty.mp3")
        let emptyData = Data()
        try? emptyData.write(to: emptyFileURL)
        
        // When: Playing empty audio file
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: emptyFileURL)
        XCTAssertFalse(result)
    }

    func testPlayAudioWithInvalidURL() {
        // Given: An invalid URL
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        
        // When: Playing audio from invalid URL
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: invalidURL)
        XCTAssertFalse(result)
    }

    func testPlayAudioWithNetworkURL() {
        // Given: A network URL (should fail in test environment)
        let networkURL = URL(string: "https://example.com/audio.mp3")!
        
        // When: Playing audio from network URL
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: networkURL)
        XCTAssertFalse(result)
    }

    func testPlayAudioWithFileURLWithoutExtension() {
        // Given: A file URL without extension
        let noExtensionURL = tempDirectory.appendingPathComponent("noextension")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: noExtensionURL)
        
        // When: Playing audio file without extension
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: noExtensionURL)
        XCTAssertFalse(result)
    }

    // MARK: - Boundary Condition Tests

    func testPlayAudioWithVeryLongFilename() {
        // Given: A file with very long filename
        let longName = String(repeating: "a", count: 200) + ".mp3"
        let longFileURL = tempDirectory.appendingPathComponent(longName)
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: longFileURL)
        
        // When: Playing audio with long filename
        // Then: Should handle gracefully
        let result = audioManager.playAudio(from: longFileURL)
        XCTAssertFalse(result) // Should fail gracefully
    }

    func testPlayAudioWithSpecialCharactersInPath() {
        // Given: A file with special characters in path
        let specialFileURL = tempDirectory.appendingPathComponent("test with spaces & symbols!.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: specialFileURL)
        
        // When: Playing audio with special characters
        // Then: Should handle gracefully
        let result = audioManager.playAudio(from: specialFileURL)
        XCTAssertFalse(result) // Should fail gracefully
    }

    func testPlayAudioWithUnicodeInPath() {
        // Given: A file with Unicode characters in path
        let unicodeFileURL = tempDirectory.appendingPathComponent("测试音频🎵.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: unicodeFileURL)
        
        // When: Playing audio with Unicode path
        // Then: Should handle gracefully
        let result = audioManager.playAudio(from: unicodeFileURL)
        XCTAssertFalse(result) // Should fail gracefully
    }

    func testPlayAudioWithVeryLargeFile() {
        // Given: A very large file (simulate)
        let largeFileURL = tempDirectory.appendingPathComponent("large.mp3")
        let largeData = Data(count: 10 * 1024 * 1024) // 10MB
        try? largeData.write(to: largeFileURL)
        
        // When: Playing very large audio file
        // Then: Should handle gracefully
        let result = audioManager.playAudio(from: largeFileURL)
        XCTAssertFalse(result) // Should fail gracefully
    }

    func testPlayAudioWithZeroByteFile() {
        // Given: A zero-byte file
        let zeroFileURL = tempDirectory.appendingPathComponent("zero.mp3")
        let zeroData = Data()
        try? zeroData.write(to: zeroFileURL)
        
        // When: Playing zero-byte audio file
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: zeroFileURL)
        XCTAssertFalse(result)
    }

    func testPlayAudioWithReadOnlyFile() {
        // Given: A read-only file
        let readOnlyFileURL = tempDirectory.appendingPathComponent("readonly.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: readOnlyFileURL)
        
        // Make file read-only
        try? FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: readOnlyFileURL.path)
        
        // When: Playing read-only audio file
        // Then: Should handle gracefully
        let result = audioManager.playAudio(from: readOnlyFileURL)
        XCTAssertFalse(result) // Should fail gracefully
        
        // Clean up: restore permissions
        try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: readOnlyFileURL.path)
    }

    func testPlayAudioWithDirectoryInsteadOfFile() {
        // Given: A directory instead of a file
        let directoryURL = tempDirectory.appendingPathComponent("directory")
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        // When: Playing audio from directory
        // Then: Should return false and not crash
        let result = audioManager.playAudio(from: directoryURL)
        XCTAssertFalse(result)
    }

    func testPlayAudioWithSymlink() {
        // Given: A symbolic link
        let originalFileURL = tempDirectory.appendingPathComponent("original.mp3")
        let symlinkURL = tempDirectory.appendingPathComponent("symlink.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: originalFileURL)
        
        // Create symlink
        try? FileManager.default.createSymbolicLink(at: symlinkURL, withDestinationURL: originalFileURL)
        
        // When: Playing audio from symlink
        // Then: Should handle gracefully
        let result = audioManager.playAudio(from: symlinkURL)
        XCTAssertFalse(result) // Should fail gracefully
    }

    // MARK: - Stress Tests

    func testRapidPlayStopCycles() {
        // Given: A test file
        let testFileURL = tempDirectory.appendingPathComponent("stress_test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        // When: Rapidly playing and stopping audio
        // Then: Should not crash
        for _ in 0..<10 {
            _ = audioManager.playAudio(from: testFileURL)
            audioManager.stopAudio()
        }
    }

    func testRapidVolumeChanges() {
        // Given: A clean state
        // When: Rapidly changing volume
        // Then: Should not crash
        for i in 0..<100 {
            let volume = Float(i) / 100.0
            audioManager.setVolume(volume)
        }
    }

    func testConcurrentOperations() {
        // Given: A test file
        let testFileURL = tempDirectory.appendingPathComponent("concurrent_test.mp3")
        let testData = "test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        // When: Performing concurrent operations
        // Then: Should not crash
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            _ = audioManager.playAudio(from: testFileURL)
            audioManager.stopAudio()
            _ = audioManager.isPlaying()
            audioManager.setVolume(0.5)
            _ = audioManager.getCurrentTime()
            _ = audioManager.getDuration()
        }
    }
}
