import Foundation
import AVFoundation
import os.log

protocol AudioPreviewPlaying: AnyObject {
    var previewingHour: Int? { get }
    var previewPlaybackProgress: Double { get }
    @discardableResult
    func previewAudio(from audioFile: AudioFile, forHour hour: Int, maxDuration: TimeInterval) -> Bool
    func stopPreviewPlayback()
    func applyPlaybackVolume(_ volume: Float)
}

class AudioManager: ObservableObject, AudioPreviewPlaying {
    static let shared = AudioManager()
    static let defaultPreviewDuration: TimeInterval = 15

    @Published private(set) var previewingHour: Int?
    @Published private(set) var previewPlaybackProgress: Double = 0

    private var audioPlayer: AVAudioPlayer?
    private var previewStopTimer: Timer?
    private var previewProgressTimer: Timer?
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "AudioManager")

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        // On macOS, we don't need AVAudioSession setup
        // AVAudioPlayer handles audio routing automatically
    }

    @discardableResult
    func previewAudio(from audioFile: AudioFile, forHour hour: Int, maxDuration: TimeInterval = defaultPreviewDuration) -> Bool {
        guard playAudio(from: audioFile) else { return false }
        previewingHour = hour
        startPreviewProgressUpdates()
        schedulePreviewStop(after: maxDuration)
        logger.info("Previewing audio for hour \(hour): \(audioFile.name)")
        return true
    }

    func stopPreviewPlayback() {
        guard previewingHour != nil else { return }
        stopAudio()
    }

    func applyPlaybackVolume(_ volume: Float) {
        setVolume(volume)
    }

    func playAudio(from url: URL, volume: Float = 1.0) -> Bool {
        do {
            // Check if file exists first
            guard FileManager.default.fileExists(atPath: url.path) else {
                logger.warning("Audio file does not exist: \(url.lastPathComponent)")
                return false
            }

            // Stop any currently playing audio
            stopAudio()
            previewingHour = nil

            // Create new audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = AudioFile.clampVolume(volume)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            logger.info("Playing audio: \(url.lastPathComponent) at volume \(volume)")
            return true

        } catch {
            logger.error("Error playing audio: \(error.localizedDescription)")
            return false
        }
    }

    func playAudio(from audioFile: AudioFile) -> Bool {
        return playAudio(from: audioFile.url, volume: audioFile.volume)
    }

    func stopAudio() {
        previewStopTimer?.invalidate()
        previewStopTimer = nil
        stopPreviewProgressUpdates()
        audioPlayer?.stop()
        audioPlayer = nil
        previewingHour = nil
    }

    private func startPreviewProgressUpdates() {
        stopPreviewProgressUpdates()
        previewPlaybackProgress = 0
        previewProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer, player.duration > 0 else { return }
            DispatchQueue.main.async {
                self.previewPlaybackProgress = min(1, player.currentTime / player.duration)
            }
        }
    }

    private func stopPreviewProgressUpdates() {
        previewProgressTimer?.invalidate()
        previewProgressTimer = nil
        previewPlaybackProgress = 0
    }

    private func schedulePreviewStop(after duration: TimeInterval) {
        previewStopTimer?.invalidate()
        previewStopTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.stopPreviewPlayback()
            }
        }
    }

    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }

    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }

    func getCurrentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }

    func getDuration() -> TimeInterval {
        return audioPlayer?.duration ?? 0
    }
}
