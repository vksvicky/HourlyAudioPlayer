import AVFoundation
import SwiftUI

/// Builds normalised peak samples for a compact waveform display.
enum AudioWaveformGenerator {
    static let defaultBucketCount = 40

    static func generateSamples(from url: URL, bucketCount: Int = defaultBucketCount) -> [Float] {
        guard bucketCount > 0,
              FileManager.default.fileExists(atPath: url.path),
              let file = try? AVAudioFile(forReading: url),
              file.length > 0
        else {
            return []
        }

        let frameCapacity = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCapacity) else {
            return []
        }

        do {
            try file.read(into: buffer)
        } catch {
            return []
        }

        return downsample(buffer: buffer, bucketCount: bucketCount)
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

        let maxPeak = peaks.max() ?? 0
        guard maxPeak > 0 else {
            return peaks
        }
        return peaks.map { $0 / maxPeak }
    }
}

/// Caches waveform samples per file URL (invalidated when the file changes on disk).
final class AudioWaveformCache: ObservableObject {
    static let shared = AudioWaveformCache()

    private var cache: [String: [Float]] = [:]

    init() {}
    private let queue = DispatchQueue(label: "AudioWaveformCache", qos: .userInitiated)

    func samples(for url: URL, bucketCount: Int = AudioWaveformGenerator.defaultBucketCount, completion: @escaping ([Float]) -> Void) {
        let key = cacheKey(for: url)
        if let cached = cache[key] {
            completion(cached)
            return
        }

        queue.async { [weak self] in
            let generated = AudioWaveformGenerator.generateSamples(from: url, bucketCount: bucketCount)
            DispatchQueue.main.async {
                self?.cache[key] = generated
                completion(generated)
            }
        }
    }

    func invalidate(url: URL) {
        cache.removeValue(forKey: cacheKey(for: url))
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
