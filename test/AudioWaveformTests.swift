import AVFoundation
import XCTest
@testable import HourlyAudioPlayer

final class AudioWaveformTests: XCTestCase {

    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AudioWaveformTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func test_givenValidWAV_whenGenerateSamples_thenReturnsNormalisedBuckets() throws {
        let url = tempDirectory.appendingPathComponent("tone.wav")
        try writeTestTone(to: url)

        let samples = AudioWaveformGenerator.generateSamples(from: url, bucketCount: 20)

        XCTAssertEqual(samples.count, 20)
        XCTAssertGreaterThan(samples.max() ?? 0, 0)
        XCTAssertLessThanOrEqual(samples.max() ?? 2, 1.001)
    }

    func test_givenMissingFile_whenGenerateSamples_thenEmpty() {
        let url = tempDirectory.appendingPathComponent("missing.wav")
        XCTAssertTrue(AudioWaveformGenerator.generateSamples(from: url).isEmpty)
    }

    func test_givenZeroFrames_whenDownsample_thenZeroBuckets() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 0)!
        buffer.frameLength = 0

        let samples = AudioWaveformGenerator.downsample(buffer: buffer, bucketCount: 12)

        XCTAssertEqual(samples.count, 12)
        XCTAssertEqual(samples, Array(repeating: 0, count: 12))
    }

    func test_givenPeaks_whenDownsample_thenNormalisesToOne() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 8)!
        buffer.frameLength = 8
        let channel = buffer.floatChannelData![0]
        for index in 0..<8 {
            channel[index] = index == 4 ? 0.5 : 0.1
        }

        let samples = AudioWaveformGenerator.downsample(buffer: buffer, bucketCount: 4)

        XCTAssertEqual(samples.count, 4)
        XCTAssertEqual(samples.max() ?? 0, 1.0, accuracy: 0.001)
    }

    func test_givenGeneratedFile_whenCacheLoadsTwice_thenReturnsSameSamples() throws {
        let url = tempDirectory.appendingPathComponent("cached.wav")
        try writeTestTone(to: url)
        let cache = AudioWaveformCache()
        let expectation = XCTestExpectation(description: "cache")
        expectation.expectedFulfillmentCount = 2

        var first: [Float] = []
        var second: [Float] = []

        cache.samples(for: url) { samples in
            first = samples
            expectation.fulfill()
        }
        cache.samples(for: url) { samples in
            second = samples
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(first.isEmpty)
        XCTAssertEqual(first, second)
    }

    private func writeTestTone(to url: URL, frameCount: AVAudioFrameCount = 4096) throws {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Could not allocate PCM buffer")
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
