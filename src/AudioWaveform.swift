import AVFoundation
import SwiftUI

/// Builds normalised peak samples for a compact waveform display.
enum AudioWaveformGenerator {
    static let defaultBucketCount = 40

    /// Reads audio in small chunks so decoded waveforms do not load the entire file into RAM at once.
    static func generateSamples(from url: URL, bucketCount: Int = defaultBucketCount) -> [Float] {
        guard bucketCount > 0,
              FileManager.default.fileExists(atPath: url.path),
              let file = try? AVAudioFile(forReading: url),
              file.length > 0
        else {
            return []
        }

        let totalFrames = Int(file.length)
        let framesPerBucket = max(1, (totalFrames + bucketCount - 1) / bucketCount)
        let chunkCapacity = AVAudioFrameCount(min(8192, max(framesPerBucket, 1)))

        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: chunkCapacity) else {
            return []
        }

        var peaks = [Float](repeating: 0, count: bucketCount)
        var globalFrame = 0

        while globalFrame < totalFrames {
            let framesToRead = min(Int(chunkCapacity), totalFrames - globalFrame)
            buffer.frameLength = 0
            file.framePosition = AVAudioFramePosition(globalFrame)
            do {
                try file.read(into: buffer)
            } catch {
                break
            }

            let chunkLength = Int(buffer.frameLength)
            guard chunkLength > 0 else { break }

            accumulatePeaks(
                buffer: buffer,
                chunkLength: chunkLength,
                globalFrameStart: globalFrame,
                framesPerBucket: framesPerBucket,
                bucketCount: bucketCount,
                peaks: &peaks
            )

            globalFrame += chunkLength
            if chunkLength < framesToRead { break }
        }

        return normalize(peaks)
    }

    private static func accumulatePeaks(
        buffer: AVAudioPCMBuffer,
        chunkLength: Int,
        globalFrameStart: Int,
        framesPerBucket: Int,
        bucketCount: Int,
        peaks: inout [Float]
    ) {
        if let channel = buffer.floatChannelData?[0] {
            for offset in 0..<chunkLength {
                let absoluteFrame = globalFrameStart + offset
                let bucket = min(bucketCount - 1, absoluteFrame / framesPerBucket)
                peaks[bucket] = max(peaks[bucket], abs(channel[offset]))
            }
        } else if let channel = buffer.int16ChannelData?[0] {
            for offset in 0..<chunkLength {
                let absoluteFrame = globalFrameStart + offset
                let bucket = min(bucketCount - 1, absoluteFrame / framesPerBucket)
                let sample = abs(Float(channel[offset]) / Float(Int16.max))
                peaks[bucket] = max(peaks[bucket], sample)
            }
        }
    }

    private static func normalize(_ peaks: [Float]) -> [Float] {
        let maxPeak = peaks.max() ?? 0
        guard maxPeak > 0 else { return peaks }
        return peaks.map { $0 / maxPeak }
    }

    static func downsample(buffer: AVAudioPCMBuffer, bucketCount: Int) -> [Float] {
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else {
            return Array(repeating: 0, count: bucketCount)
        }

        var peaks = [Float](repeating: 0, count: bucketCount)
        let framesPerBucket = max(1, frameLength / bucketCount)

        if let channel = buffer.floatChannelData?[0] {
            for bucket in 0..<bucketCount {
                let start = bucket * framesPerBucket
                let end = min(frameLength, start + framesPerBucket)
                var peak: Float = 0
                for frame in start..<end {
                    peak = max(peak, abs(channel[frame]))
                }
                peaks[bucket] = peak
            }
        } else if let channel = buffer.int16ChannelData?[0] {
            for bucket in 0..<bucketCount {
                let start = bucket * framesPerBucket
                let end = min(frameLength, start + framesPerBucket)
                var peak: Float = 0
                for frame in start..<end {
                    peak = max(peak, abs(Float(channel[frame]) / Float(Int16.max)))
                }
                peaks[bucket] = peak
            }
        } else {
            return Array(repeating: 0, count: bucketCount)
        }

        return normalize(peaks)
    }
}

/// Caches waveform samples per file URL (invalidated when the file changes on disk).
final class AudioWaveformCache: ObservableObject {
    static let shared = AudioWaveformCache()
    static let maximumEntries = 32

    private var cache: [String: [Float]] = [:]
    private var cacheOrder: [String] = []
    private var epoch = UUID()

    var entryCount: Int { cache.count }

    init() {}
    private let queue = DispatchQueue(label: "AudioWaveformCache", qos: .userInitiated)

    /// Loads peaks on a background queue; cancelled logically when `removeAll()` bumps the epoch.
    func samples(for url: URL, bucketCount: Int = AudioWaveformGenerator.defaultBucketCount) async -> [Float] {
        let key = cacheKey(for: url)
        if let cached = cache[key] {
            return cached
        }

        let captureEpoch = epoch
        return await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self else {
                    DispatchQueue.main.async { continuation.resume(returning: []) }
                    return
                }
                guard self.epoch == captureEpoch else {
                    DispatchQueue.main.async { continuation.resume(returning: []) }
                    return
                }

                let generated = AudioWaveformGenerator.generateSamples(from: url, bucketCount: bucketCount)
                DispatchQueue.main.async {
                    guard self.epoch == captureEpoch else {
                        continuation.resume(returning: [])
                        return
                    }
                    self.store(generated, forKey: key)
                    continuation.resume(returning: generated)
                }
            }
        }
    }

    func samples(for url: URL, bucketCount: Int = AudioWaveformGenerator.defaultBucketCount, completion: @escaping ([Float]) -> Void) {
        Task {
            let result = await samples(for: url, bucketCount: bucketCount)
            await MainActor.run {
                completion(result)
            }
        }
    }

    func invalidate(url: URL) {
        let key = cacheKey(for: url)
        cache.removeValue(forKey: key)
        cacheOrder.removeAll { $0 == key }
    }

    /// Drops cached waveform peaks and cancels in-flight generation (e.g. when settings closes).
    func removeAll() {
        epoch = UUID()
        cache.removeAll()
        cacheOrder.removeAll()
    }

    func insertSamplesForTesting(_ samples: [Float], key: String) {
        store(samples, forKey: key)
    }

    func samplesForTesting(key: String) -> [Float]? {
        cache[key]
    }

    private func store(_ samples: [Float], forKey key: String) {
        cache[key] = samples
        cacheOrder.removeAll { $0 == key }
        cacheOrder.append(key)
        while cacheOrder.count > Self.maximumEntries {
            let oldest = cacheOrder.removeFirst()
            cache.removeValue(forKey: oldest)
        }
    }

    private func cacheKey(for url: URL) -> String {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let modified = (attributes?[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
        return "\(url.path)|\(modified)"
    }
}

/// Mini waveform with optional playback progress (0...1).
struct AudioWaveformView: View {
    let samples: [Float]
    var progress: Double = 0
    var height: CGFloat = 22

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawWaveform(in: &context, size: size)
            }
        }
        .frame(height: height)
        .accessibilityLabel("Audio waveform")
        .accessibilityValue(progress > 0 ? "Playing" : "Ready")
    }

    private func drawWaveform(in context: inout GraphicsContext, size: CGSize) {
        guard !samples.isEmpty else { return }

        let clampedProgress = min(1, max(0, progress))
        let barCount = samples.count
        let spacing: CGFloat = 1
        let barWidth = max(1, (size.width - spacing * CGFloat(barCount - 1)) / CGFloat(barCount))
        let progressIndex = Int((clampedProgress * Double(barCount)).rounded(.down))

        for (index, sample) in samples.enumerated() {
            let barHeight = max(2, CGFloat(sample) * size.height)
            let x = CGFloat(index) * (barWidth + spacing)
            let y = (size.height - barHeight) / 2
            let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = Path(roundedRect: rect, cornerSize: CGSize(width: 1, height: 1))
            let isPlayed = index < progressIndex
            let colour: Color = isPlayed ? .accentColor : Color.secondary.opacity(0.4)
            context.fill(path, with: .color(colour))
        }
    }
}
