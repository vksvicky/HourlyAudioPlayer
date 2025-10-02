import Foundation
import UserNotifications
import AVFoundation
import AppKit
import os.log

class HourlyTimer: ObservableObject {
    static let shared = HourlyTimer()

    private var timer: Timer?
    private let audioFileManager = AudioFileManager.shared
    private let audioManager = AudioManager.shared
    private var lastPlayedHour: Int = -1
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "HourlyTimer")

    private init() {
        requestNotificationPermission()
    }

    func start() {
        // Stop any existing timer
        stop()

        // Calculate time until next hour
        let now = Date()
        let calendar = Calendar.current
        let startOfCurrentHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: startOfCurrentHour)!
        let timeInterval = nextHour.timeIntervalSince(now)

        // Set up timer to fire at the next hour
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.playHourlyAudio()
            self?.scheduleNextHour()
        }

        logger.info("Hourly timer started. Next audio will play at: \(nextHour)")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func scheduleNextHour() {
        // Schedule the next hour
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.playHourlyAudio()
        }
    }

    private func playHourlyAudio() {
        let currentHour = Calendar.current.component(.hour, from: Date())

        // Avoid playing the same hour multiple times
        if currentHour == lastPlayedHour {
            return
        }

        lastPlayedHour = currentHour

        if let audioFile = audioFileManager.getAudioFile(for: currentHour) {
            let success = audioManager.playAudio(from: audioFile)
            if success {
                sendNotification(for: currentHour, audioFile: audioFile)
            } else {
                logger.warning("Failed to play audio file: \(audioFile.name) - file may be missing or corrupted")
                sendMissingFileNotification(for: currentHour, audioFile: audioFile)
                playSystemSound()
            }
        } else {
            logger.info("No audio file set for hour \(currentHour) - playing system sound")
            playSystemSound()
            sendNotification(for: currentHour, audioFile: nil)
        }
    }

    func playCurrentHourAudio() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        logger.info("🎵 Testing audio for current hour: \(currentHour)")

        if let audioFile = audioFileManager.getAudioFile(for: currentHour) {
            logger.info("✅ Found audio file: \(audioFile.name) at \(audioFile.url)")
            let success = audioManager.playAudio(from: audioFile)
            if success {
                sendNotification(for: currentHour, audioFile: audioFile)
            } else {
                logger.warning("❌ Failed to play audio file: \(audioFile.name) - file may be missing or corrupted")
                sendMissingFileNotification(for: currentHour, audioFile: audioFile)
                logger.info("🔔 Playing default macOS system sound instead")
                playSystemSound()
            }
        } else {
            logger.info("❌ No audio file set for current hour \(currentHour)")
            logger.info("🔔 Playing default macOS system sound instead")
            playSystemSound()
            sendNotification(for: currentHour, audioFile: nil)
            logger.info("📋 Available audio files:")
            for (hour, audioFile) in audioFileManager.audioFiles {
                logger.info("   Hour \(hour): \(audioFile.name)")
            }
        }
    }

    private func playSystemSound() {
        // Play the default macOS system sound
        NSSound.beep()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                self.logger.error("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func sendNotification(for hour: Int, audioFile: AudioFile?) {
        let content = UNMutableNotificationContent()
        content.title = "Hourly Audio Player"

        if let audioFile = audioFile {
            content.body = "Playing audio for \(hour):00 - \(audioFile.name)"
        } else {
            content.body = "Playing system sound for \(hour):00 (no custom audio set)"
        }

        content.sound = nil // We're playing our own audio

        let request = UNNotificationRequest(
            identifier: "hourly-audio-\(hour)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendMissingFileNotification(for hour: Int, audioFile: AudioFile) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Audio File Missing"
        content.body = "Could not play '\(audioFile.name)' for \(hour):00. File may be missing, moved, or corrupted. Playing system sound instead."
        
        // Use a warning sound for missing files
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: "missing-audio-\(hour)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Missing file notification error: \(error.localizedDescription)")
            } else {
                self.logger.info("Sent missing file notification for: \(audioFile.name)")
            }
        }
    }

    func getNextAudioTime() -> Date? {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        // Check if there's an audio file for the next hour
        let nextHour = (currentHour + 1) % 24
        if audioFileManager.getAudioFile(for: nextHour) != nil {
            let startOfCurrentHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
            return calendar.date(byAdding: .hour, value: 1, to: startOfCurrentHour)
        }

        // Find the next hour with an audio file
        for hourOffset in 1...24 {
            let checkHour = (currentHour + hourOffset) % 24
            if audioFileManager.getAudioFile(for: checkHour) != nil {
                let startOfCurrentHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
                return calendar.date(byAdding: .hour, value: hourOffset, to: startOfCurrentHour)
            }
        }

        return nil
    }

    #if DEBUG_MODE
    func testNotificationWithAudio() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        logger.info("🐛 DEBUG: Testing notification with audio for hour \(currentHour)")

        if let audioFile = audioFileManager.getAudioFile(for: currentHour) {
            logger.info(
                "🐛 DEBUG: Found audio file: \(audioFile.name) - playing audio and sending notification"
            )
            let success = audioManager.playAudio(from: audioFile)
            if success {
                sendNotification(for: currentHour, audioFile: audioFile)
            } else {
                logger.warning("🐛 DEBUG: Failed to play audio file: \(audioFile.name) - file may be missing or corrupted")
                sendMissingFileNotification(for: currentHour, audioFile: audioFile)
                playSystemSound()
            }
        } else {
            logger.info(
                "🐛 DEBUG: No audio file set for hour \(currentHour) - playing system sound and sending notification"
            )
            playSystemSound()
            sendNotification(for: currentHour, audioFile: nil)
        }
    }
    #endif
}
