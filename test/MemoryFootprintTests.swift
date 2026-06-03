import AVFoundation
import XCTest
@testable import HourlyAudioPlayer

final class MemoryFootprintTests: XCTestCase {

    func test_whenReadResidentSize_thenReturnsPositiveValue() {
        let bytes = MemoryFootprint.residentSizeBytes()
        XCTAssertNotNil(bytes)
        XCTAssertGreaterThan(bytes ?? 0, 0)
    }

    func test_givenChunkedRead_whenGenerateSamples_thenReturnsNormalisedBuckets() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("memory-wave-\(UUID().uuidString).wav")
        try writeTestTone(to: url)

        let samples = AudioWaveformGenerator.generateSamples(from: url, bucketCount: 20)
        XCTAssertEqual(samples.count, 20)
        XCTAssertGreaterThan(samples.max() ?? 0, 0)
        XCTAssertLessThanOrEqual(samples.max() ?? 2, 1.001)

        try? FileManager.default.removeItem(at: url)
    }

    func test_givenCachedSamples_whenRemoveAll_thenEmpty() {
        let cache = AudioWaveformCache()
        cache.insertSamplesForTesting([0.5, 0.8], key: "a")
        XCTAssertEqual(cache.entryCount, 1)

        cache.removeAll()

        XCTAssertEqual(cache.entryCount, 0)
        XCTAssertNil(cache.samplesForTesting(key: "a"))
    }

    func test_givenManyCacheInserts_whenOverLimit_thenEvictsOldest() {
        let cache = AudioWaveformCache()
        let limit = AudioWaveformCache.maximumEntries

        for index in 0..<(limit + 5) {
            cache.insertSamplesForTesting([Float(index)], key: "key-\(index)")
        }

        XCTAssertEqual(cache.entryCount, limit)
        XCTAssertNil(cache.samplesForTesting(key: "key-0"))
        XCTAssertNotNil(cache.samplesForTesting(key: "key-\(limit + 4)"))
    }

    private func writeTestTone(to url: URL) throws {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        let frameCount: AVAudioFrameCount = 4096
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Could not allocate buffer")
            return
        }
        buffer.frameLength = frameCount
        let channel = buffer.floatChannelData![0]
        for index in 0..<Int(frameCount) {
            channel[index] = sin(2 * Float.pi * Float(index) / 80) * 0.5
        }
        try file.write(from: buffer)
    }
}
