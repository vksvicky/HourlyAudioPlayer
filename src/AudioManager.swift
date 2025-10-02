import Foundation
import AVFoundation
import os.log

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var audioPlayer: AVAudioPlayer?
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "AudioManager")

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        // On macOS, we don't need AVAudioSession setup
        // AVAudioPlayer handles audio routing automatically
    }

    func playAudio(from url: URL) -> Bool {
        do {
            // Check if file exists first
            guard FileManager.default.fileExists(atPath: url.path) else {
                logger.warning("Audio file does not exist: \(url.lastPathComponent)")
                return false
            }
            
            // Stop any currently playing audio
            stopAudio()

            // Create new audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            logger.info("Playing audio: \(url.lastPathComponent)")
            return true

        } catch {
            logger.error("Error playing audio: \(error.localizedDescription)")
            return false
        }
    }

    func playAudio(from audioFile: AudioFile) -> Bool {
        return playAudio(from: audioFile.url)
    }

    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
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
