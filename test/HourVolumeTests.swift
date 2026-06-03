import XCTest
@testable import HourlyAudioPlayer

final class HourVolumeTests: XCTestCase {

    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var mockPlayer: MockAudioPreviewPlayer!
    private var manager: AudioFileManager!

    override func setUp() {
        super.setUp()
        suiteName = "HourVolumeTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        mockPlayer = MockAudioPreviewPlayer()
        manager = AudioFileManager(previewPlayer: mockPlayer, userDefaults: userDefaults)
        manager.audioFiles = [:]
    }

    override func tearDown() {
        manager.audioFiles = [:]
        userDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func test_givenAudioForHour_whenSetVolume_thenPersistsInMemory() {
        let hour = 11
        manager.audioFiles[hour] = AudioFile(
            name: "bell.mp3",
            url: URL(fileURLWithPath: "/tmp/bell.mp3"),
            hour: hour,
            volume: 1.0
        )

        manager.setVolume(for: hour, volume: 0.35)

        XCTAssertEqual(manager.volume(for: hour), 0.35, accuracy: Float(0.001))
        XCTAssertEqual(manager.audioFiles[hour]?.volume ?? -1, 0.35, accuracy: Float(0.001))
    }

    func test_givenSetVolume_whenReloadFromUserDefaults_thenRestoresPerHourVolume() {
        let hour = 6
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("hour6-\(UUID().uuidString).wav")
        FileManager.default.createFile(atPath: url.path, contents: Data([0x00]))
        manager.audioFiles[hour] = AudioFile(name: "six.wav", url: url, hour: hour, volume: 1.0)
        manager.setVolume(for: hour, volume: 0.42)

        let reloaded = AudioFileManager(previewPlayer: mockPlayer, userDefaults: userDefaults)

        XCTAssertEqual(reloaded.volume(for: hour), 0.42, accuracy: Float(0.001))
        try? FileManager.default.removeItem(at: url)
    }

    func test_givenVolumeAboveOne_whenSetVolume_thenClampsToOne() {
        let hour = 4
        manager.audioFiles[hour] = AudioFile(
            name: "loud.wav",
            url: URL(fileURLWithPath: "/tmp/loud.wav"),
            hour: hour
        )

        manager.setVolume(for: hour, volume: 2.0)

        XCTAssertEqual(manager.volume(for: hour), 1.0, accuracy: Float(0.001))
    }

    func test_givenVolumeBelowZero_whenSetVolume_thenClampsToZero() {
        let hour = 9
        manager.audioFiles[hour] = AudioFile(
            name: "quiet.wav",
            url: URL(fileURLWithPath: "/tmp/quiet.wav"),
            hour: hour
        )

        manager.setVolume(for: hour, volume: -0.5)

        XCTAssertEqual(manager.volume(for: hour), 0, accuracy: Float(0.001))
    }

    func test_givenNoAudio_whenVolume_thenReturnsDefault() {
        manager.audioFiles.removeValue(forKey: 22)
        XCTAssertEqual(manager.volume(for: 22), 1.0, accuracy: Float(0.001))
    }

    func test_givenNoAudio_whenSetVolume_thenNoOp() {
        manager.audioFiles.removeValue(forKey: 15)
        manager.setVolume(for: 15, volume: 0.25)
        XCTAssertEqual(manager.volume(for: 15), 1.0, accuracy: Float(0.001))
    }

    func test_givenPreviewActive_whenSetVolume_thenUpdatesPreviewPlayer() {
        let hour = 3
        let file = AudioFile(name: "live.wav", url: URL(fileURLWithPath: "/tmp/live.wav"), hour: hour, volume: 1.0)
        manager.audioFiles[hour] = file
        mockPlayer.previewingHour = hour

        manager.setVolume(for: hour, volume: 0.6)

        XCTAssertEqual(mockPlayer.lastAppliedPlaybackVolume!, 0.6, accuracy: Float(0.001))
    }

    func test_givenLegacyJSONWithoutVolume_whenDecoded_thenDefaultsToFullVolume() throws {
        let json = """
        {"id":"\(UUID().uuidString)","name":"legacy.mp3","url":"file:///tmp/legacy.mp3","hour":8}
        """.data(using: .utf8)!
        let file = try JSONDecoder().decode(AudioFile.self, from: json)
        XCTAssertEqual(file.volume, 1.0, accuracy: Float(0.001))
    }

    func test_givenImportedAudioFile_whenPlayUsesStoredVolume() {
        let hour = 14
        let file = AudioFile(name: "chime.mp3", url: URL(fileURLWithPath: "/tmp/chime.mp3"), hour: hour, volume: 0.55)
        manager.audioFiles[hour] = file

        XCTAssertEqual(manager.getAudioFile(for: hour)!.volume, 0.55, accuracy: Float(0.001))
    }
}
