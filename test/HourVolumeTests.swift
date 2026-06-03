import XCTest
@testable import HourlyAudioPlayer

final class HourVolumeTests: XCTestCase {

    func test_givenAudioForHour_whenSetVolume_thenPersistsInMemory() {
        // Given
        let manager = AudioFileManager.shared
        let hour = 11
        let file = AudioFile(name: "bell.mp3", url: URL(fileURLWithPath: "/tmp/bell.mp3"), hour: hour, volume: 1.0)
        manager.audioFiles[hour] = file

        // When
        manager.setVolume(for: hour, volume: 0.35)

        // Then
        XCTAssertEqual(manager.volume(for: hour), 0.35, accuracy: Float(0.001))
        XCTAssertEqual(manager.audioFiles[hour]?.volume ?? -1, 0.35, accuracy: Float(0.001))
    }

    func test_givenVolumeAboveOne_whenSetVolume_thenClampsToOne() {
        // Given
        let manager = AudioFileManager.shared
        let hour = 4
        manager.audioFiles[hour] = AudioFile(
            name: "loud.wav",
            url: URL(fileURLWithPath: "/tmp/loud.wav"),
            hour: hour
        )

        // When
        manager.setVolume(for: hour, volume: 2.0)

        // Then
        XCTAssertEqual(manager.volume(for: hour), 1.0, accuracy: Float(0.001))
    }

    func test_givenNoAudio_whenVolume_thenReturnsDefault() {
        // Given
        let manager = AudioFileManager.shared
        manager.audioFiles.removeValue(forKey: 22)

        // When / Then
        XCTAssertEqual(manager.volume(for: 22), 1.0, accuracy: Float(0.001))
    }

    func test_givenLegacyJSONWithoutVolume_whenDecoded_thenDefaultsToFullVolume() throws {
        // Given
        let json = """
        {"id":"\(UUID().uuidString)","name":"legacy.mp3","url":"file:///tmp/legacy.mp3","hour":8}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()

        // When
        let file = try decoder.decode(AudioFile.self, from: json)

        // Then
        XCTAssertEqual(file.volume, 1.0, accuracy: Float(0.001))
    }
}
