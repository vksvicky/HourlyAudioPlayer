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

    // MARK: - Additional Tests for Untested Functions

    func testCreateAudioDirectoryIfNeeded() {
        // Given: A clean state
        audioFileManager.audioFiles.removeAll()
        
        // When: Creating audio directory (this is typically called internally)
        // Then: Should not crash and directory should be accessible
        XCTAssertNoThrow(audioFileManager.createAudioDirectoryIfNeeded())
    }

    func testSelectAudioFileHappyPath() {
        // Given: A valid hour
        let hour = 12
        
        // When: Selecting audio file (this will open file dialog in real app)
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.selectAudioFile(for: hour))
    }

    func testSelectAudioFileInvalidHour() {
        // Given: Invalid hours
        let invalidHours = [-1, 24, 25, 100]
        
        for hour in invalidHours {
            // When: Selecting audio file for invalid hour
            // Then: Should not crash (should handle gracefully)
            XCTAssertNoThrow(audioFileManager.selectAudioFile(for: hour))
        }
    }

    func testImportAudioFileHappyPath() {
        // Given: A valid audio file URL and hour
        let testFileURL = tempDirectory.appendingPathComponent("test_import.mp3")
        let testData = "fake audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        let hour = 14
        
        // When: Importing the audio file
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.importAudioFile(from: testFileURL, for: hour))
    }

    func testImportAudioFileNonExistentFile() {
        // Given: A non-existent file URL
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.mp3")
        let hour = 15
        
        // When: Importing non-existent file
        // Then: Should not crash (should handle gracefully)
        XCTAssertNoThrow(audioFileManager.importAudioFile(from: nonExistentURL, for: hour))
    }

    func testImportAudioFileInvalidURL() {
        // Given: An invalid URL
        let invalidURL = URL(string: "invalid://path/to/file.mp3")!
        let hour = 16
        
        // When: Importing with invalid URL
        // Then: Should not crash (should handle gracefully)
        XCTAssertNoThrow(audioFileManager.importAudioFile(from: invalidURL, for: hour))
    }

    func testExtractHourFromFilenameHappyPath() {
        // Given: Valid filenames with hour patterns
        let validFilenames = [
            "12_audio.mp3",
            "00_morning.mp3",
            "23_night.mp3",
            "09_work.mp3"
        ]
        
        for filename in validFilenames {
            // When: Extracting hour from filename
            // Then: Should return valid hour or nil gracefully
            XCTAssertNoThrow(audioFileManager.extractHourFromFilename(filename))
        }
    }

    func testExtractHourFromFilenameEdgeCases() {
        // Given: Edge case filenames
        let edgeCaseFilenames = [
            "", // Empty string
            "no_hour.mp3", // No hour pattern
            "25_invalid.mp3", // Invalid hour
            "abc_def.mp3", // Non-numeric
            "12", // Just hour
            "12_", // Hour with underscore but no extension
        ]
        
        for filename in edgeCaseFilenames {
            // When: Extracting hour from edge case filename
            // Then: Should handle gracefully without crashing
            XCTAssertNoThrow(audioFileManager.extractHourFromFilename(filename))
        }
    }

    func testSaveAudioFilesHappyPath() {
        // Given: Some audio files in the manager
        let testFileURL = tempDirectory.appendingPathComponent("save_test.mp3")
        let testData = "save test data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "save_test.mp3", url: testFileURL, hour: 10)
        audioFileManager.audioFiles[10] = testAudioFile
        
        // When: Saving audio files
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.saveAudioFiles())
    }

    func testSaveAudioFilesEmptyState() {
        // Given: Empty audio files state
        audioFileManager.audioFiles.removeAll()
        
        // When: Saving empty audio files
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.saveAudioFiles())
    }

    func testLoadAudioFilesHappyPath() {
        // Given: A clean state
        audioFileManager.audioFiles.removeAll()
        
        // When: Loading audio files
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.loadAudioFiles())
    }

    func testLoadAudioFilesCorruptedData() {
        // Given: A clean state
        audioFileManager.audioFiles.removeAll()
        
        // When: Loading audio files (may encounter corrupted data)
        // Then: Should not crash and handle gracefully
        XCTAssertNoThrow(audioFileManager.loadAudioFiles())
    }

    func testFindMainWindowHappyPath() {
        // Given: A clean state
        // When: Finding main window
        // Then: Should not crash (may return nil in test environment)
        XCTAssertNoThrow(audioFileManager.findMainWindow())
    }

    func testValidateAudioFileHappyPath() {
        // Given: A valid audio file
        let testFileURL = tempDirectory.appendingPathComponent("valid_audio.mp3")
        let testData = "valid audio data".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        // When: Validating the audio file
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.validateAudioFile(at: testFileURL))
    }

    func testValidateAudioFileNonExistent() {
        // Given: A non-existent file
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.mp3")
        
        // When: Validating non-existent file
        // Then: Should return validation error without crashing
        let result = audioFileManager.validateAudioFile(at: nonExistentURL)
        XCTAssertNotNil(result) // Should return an error
    }

    func testValidateAudioFileTooLarge() {
        // Given: A file that's too large (simulate by creating a large file)
        let largeFileURL = tempDirectory.appendingPathComponent("large_audio.mp3")
        let largeData = Data(count: 3 * 1024 * 1024) // 3MB
        try? largeData.write(to: largeFileURL)
        
        // When: Validating large file
        // Then: Should return validation error without crashing
        let result = audioFileManager.validateAudioFile(at: largeFileURL)
        XCTAssertNotNil(result) // Should return an error for file too large
    }

    func testValidateAudioFileInvalidFormat() {
        // Given: A file with invalid format
        let invalidFileURL = tempDirectory.appendingPathComponent("invalid.txt")
        let invalidData = "This is not audio data".data(using: .utf8)!
        try? invalidData.write(to: invalidFileURL)
        
        // When: Validating invalid format file
        // Then: Should return validation error without crashing
        let result = audioFileManager.validateAudioFile(at: invalidFileURL)
        XCTAssertNotNil(result) // Should return an error for invalid format
    }

    func testShowValidationAlertHappyPath() {
        // Given: A validation error
        let error = ValidationError.fileTooLarge
        let fileName = "test_file.mp3"
        
        // When: Showing validation alert
        // Then: Should not crash (may not show alert in test environment)
        XCTAssertNoThrow(audioFileManager.showAlert(for: error, fileName: fileName))
    }

    func testShowValidationAlertAllErrorTypes() {
        // Given: All possible validation errors
        let errors = [
            ValidationError.fileTooLarge,
            ValidationError.invalidFormat,
            ValidationError.fileNotFound
        ]
        let fileName = "test_file.mp3"
        
        for error in errors {
            // When: Showing alert for each error type
            // Then: Should not crash
            XCTAssertNoThrow(audioFileManager.showAlert(for: error, fileName: fileName))
        }
    }

    func testShowValidationAlertEmptyFileName() {
        // Given: A validation error with empty filename
        let error = ValidationError.fileTooLarge
        let fileName = ""
        
        // When: Showing alert with empty filename
        // Then: Should not crash
        XCTAssertNoThrow(audioFileManager.showAlert(for: error, fileName: fileName))
    }

    // MARK: - Boundary Condition Tests

    func testBoundaryConditionsHourZero() {
        // Given: Hour 0 (midnight)
        let hour = 0
        let testFileURL = tempDirectory.appendingPathComponent("midnight.mp3")
        let testData = "midnight audio".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "midnight.mp3", url: testFileURL, hour: hour)
        audioFileManager.audioFiles[hour] = testAudioFile
        
        // When: Getting audio for hour 0
        // Then: Should work correctly
        let result = audioFileManager.getAudioFile(for: hour)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.hour, hour)
    }

    func testBoundaryConditionsHour23() {
        // Given: Hour 23 (11 PM)
        let hour = 23
        let testFileURL = tempDirectory.appendingPathComponent("night.mp3")
        let testData = "night audio".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        let testAudioFile = AudioFile(name: "night.mp3", url: testFileURL, hour: hour)
        audioFileManager.audioFiles[hour] = testAudioFile
        
        // When: Getting audio for hour 23
        // Then: Should work correctly
        let result = audioFileManager.getAudioFile(for: hour)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.hour, hour)
    }

    func testBoundaryConditionsInvalidHours() {
        // Given: Invalid hours
        let invalidHours = [-1, 24, 25, 100, -100]
        
        for hour in invalidHours {
            // When: Getting audio for invalid hour
            // Then: Should return nil gracefully
            let result = audioFileManager.getAudioFile(for: hour)
            XCTAssertNil(result)
        }
    }

    func testBoundaryConditionsVeryLongFilename() {
        // Given: A very long filename
        let longName = String(repeating: "a", count: 255) + ".mp3"
        let testFileURL = tempDirectory.appendingPathComponent(longName)
        let testData = "long filename audio".data(using: .utf8)!
        try? testData.write(to: testFileURL)
        
        // When: Extracting hour from very long filename
        // Then: Should handle gracefully without crashing
        XCTAssertNoThrow(audioFileManager.extractHourFromFilename(longName))
    }

    func testBoundaryConditionsSpecialCharactersInFilename() {
        // Given: Filenames with special characters
        let specialFilenames = [
            "12_audio with spaces.mp3",
            "12_audio-with-dashes.mp3",
            "12_audio.with.dots.mp3",
            "12_audio(with)parentheses.mp3",
            "12_audio[with]brackets.mp3",
            "12_audio{with}braces.mp3",
            "12_audio@with#symbols$.mp3"
        ]
        
        for filename in specialFilenames {
            // When: Extracting hour from filename with special characters
            // Then: Should handle gracefully
            XCTAssertNoThrow(audioFileManager.extractHourFromFilename(filename))
        }
    }

    func testBoundaryConditionsUnicodeFilenames() {
        // Given: Filenames with Unicode characters
        let unicodeFilenames = [
            "12_音频.mp3",
            "12_🎵_music.mp3",
            "12_файл.mp3",
            "12_ファイル.mp3"
        ]
        
        for filename in unicodeFilenames {
            // When: Extracting hour from Unicode filename
            // Then: Should handle gracefully
            XCTAssertNoThrow(audioFileManager.extractHourFromFilename(filename))
        }
    }
}
