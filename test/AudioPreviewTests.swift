import XCTest
@testable import HourlyAudioPlayer

final class MockAudioPreviewPlayer: AudioPreviewPlaying {
    var previewingHour: Int?
    var previewPlaybackProgress: Double = 0
    private(set) var lastPreviewedFile: AudioFile?
    private(set) var lastMaxDuration: TimeInterval?
    private(set) var lastAppliedPlaybackVolume: Float?
    var shouldSucceed = true

    @discardableResult
    func previewAudio(from audioFile: AudioFile, forHour hour: Int, maxDuration: TimeInterval) -> Bool {
        guard shouldSucceed else { return false }
        lastPreviewedFile = audioFile
        lastMaxDuration = maxDuration
        previewingHour = hour
        return true
    }

    func stopPreviewPlayback() {
        previewingHour = nil
        lastPreviewedFile = nil
    }

    func applyPlaybackVolume(_ volume: Float) {
        lastAppliedPlaybackVolume = volume
    }
}

final class AudioPreviewTests: XCTestCase {

    private var tempDirectory: URL!
    private var mockPlayer: MockAudioPreviewPlayer!
    private var manager: AudioFileManager!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AudioPreviewTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        mockPlayer = MockAudioPreviewPlayer()
        let suiteName = "AudioPreviewTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        manager = AudioFileManager(previewPlayer: mockPlayer, userDefaults: userDefaults)
        manager.audioFiles = [:]
    }

    override func tearDown() {
        manager.stopPreview()
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func test_givenConfiguredFile_whenPreview_thenStartsWithHourVolume() {
        let url = tempDirectory.appendingPathComponent("chime.wav")
        FileManager.default.createFile(atPath: url.path, contents: minimalWAVData())
        manager.audioFiles[7] = AudioFile(name: "chime.wav", url: url, hour: 7, volume: 0.4)

        XCTAssertEqual(manager.previewAudio(for: 7), .started)
        XCTAssertEqual(mockPlayer.previewingHour, 7)
        XCTAssertEqual(mockPlayer.lastPreviewedFile?.volume ?? -1, 0.4, accuracy: 0.001)
    }

    func test_givenNoAudio_whenPreview_thenNoAudioConfigured() {
        manager.audioFiles.removeValue(forKey: 3)
        XCTAssertEqual(manager.previewAudio(for: 3), .noAudioConfigured)
        XCTAssertNil(mockPlayer.previewingHour)
    }

    func test_givenMissingFileOnDisk_whenPreview_thenFileMissing() {
        let url = tempDirectory.appendingPathComponent("gone.mp3")
        manager.audioFiles[5] = AudioFile(name: "gone.mp3", url: url, hour: 5)

        XCTAssertEqual(manager.previewAudio(for: 5), .fileMissing)
    }

    func test_givenPlayerFails_whenPreview_thenPlaybackFailed() {
        let url = tempDirectory.appendingPathComponent("bad.mp3")
        FileManager.default.createFile(atPath: url.path, contents: Data([0x00]))
        manager.audioFiles[9] = AudioFile(name: "bad.mp3", url: url, hour: 9)
        mockPlayer.shouldSucceed = false

        XCTAssertEqual(manager.previewAudio(for: 9), .playbackFailed)
    }

    func test_givenPreviewActive_whenStopPreview_thenClearsHour() {
        let url = tempDirectory.appendingPathComponent("a.wav")
        FileManager.default.createFile(atPath: url.path, contents: minimalWAVData())
        manager.audioFiles[2] = AudioFile(name: "a.wav", url: url, hour: 2)
        _ = manager.previewAudio(for: 2)

        manager.stopPreview()

        XCTAssertNil(mockPlayer.previewingHour)
        XCTAssertFalse(manager.isPreviewing(hour: 2))
    }

    func test_givenPreviewActive_whenRemoveAudio_thenStopsPreview() {
        let url = tempDirectory.appendingPathComponent("b.wav")
        FileManager.default.createFile(atPath: url.path, contents: minimalWAVData())
        manager.audioFiles[4] = AudioFile(name: "b.wav", url: url, hour: 4)
        _ = manager.previewAudio(for: 4)

        manager.removeAudioFile(for: 4)

        XCTAssertNil(mockPlayer.previewingHour)
        XCTAssertNil(manager.getAudioFile(for: 4))
    }

    func test_givenValidWAV_whenPreviewAudio_thenSetsPreviewingHour() {
        let url = tempDirectory.appendingPathComponent("tone.wav")
        FileManager.default.createFile(atPath: url.path, contents: minimalWAVData())
        let file = AudioFile(name: "tone.wav", url: url, hour: 12, volume: 0.8)
        let player = AudioManager()

        XCTAssertTrue(player.previewAudio(from: file, forHour: 12, maxDuration: 1))
        XCTAssertEqual(player.previewingHour, 12)

        player.stopPreviewPlayback()
        XCTAssertNil(player.previewingHour)
        XCTAssertEqual(player.previewPlaybackProgress, 0)
        XCTAssertFalse(player.isPlaying())
    }

    private func minimalWAVData() -> Data {
        var data = Data()
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // RIFF
        data.append(contentsOf: [36, 0, 0, 0]) // chunk size
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // WAVE
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // fmt
        data.append(contentsOf: [16, 0, 0, 0])
        data.append(contentsOf: [1, 0, 1, 0]) // PCM mono
        data.append(contentsOf: [68, 172, 0, 0]) // sample rate 44100
        data.append(contentsOf: [136, 88, 1, 0])
        data.append(contentsOf: [2, 0, 16, 0])
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // data
        data.append(contentsOf: [2, 0, 0, 0])
        data.append(contentsOf: [0, 0])
        return data
    }
}
