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
    private var lastKnownTime: Date = Date()
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "HourlyTimer")

    private init() {
        requestNotificationPermission()
        setupSleepWakeNotifications()
    }

    deinit {
        // Clean up notification observers
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    func start() {
        // Stop any existing timer
        stop()

        // Calculate time until next hour with precise timing
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
        logger.info("Time until next hour: \(timeInterval) seconds")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func scheduleNextHour() {
        // Calculate precise time until next hour to avoid drift
        let now = Date()
        let calendar = Calendar.current
        let startOfCurrentHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: startOfCurrentHour)!
        let timeInterval = nextHour.timeIntervalSince(now)

        // Schedule timer for the next hour
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.playHourlyAudio()
            self?.scheduleNextHour() // Recursively schedule the next hour
        }

        logger.info("Next audio scheduled for: \(nextHour) (in \(timeInterval) seconds)")
    }

    private func playHourlyAudio() {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)

        // Debug logging for precise timing information
        logger.info("🕐 Current time: \(now)")
        logger.info("🕐 Current hour (24h): \(currentHour)")
        logger.info("🕐 Current minute: \(currentMinute)")
        logger.info("🕐 Current second: \(currentSecond)")
        logger.info("🕐 Timezone: \(TimeZone.current.identifier)")
        logger.info("🕐 Timezone offset: \(TimeZone.current.secondsFromGMT()) seconds")

        // Check if we're playing at the right time (should be close to minute 0)
        // Only play audio if we're within the first 2 minutes of the hour
        if currentMinute > 2 {
            logger.warning("⚠️ Audio playing \(currentMinute) minutes past the hour - timing may be off")
            logger.info("🚫 Skipping audio playback - too far past the hour (likely from sleep/wake)")
            return
        }

        // Check for potential sleep/wake scenario
        let timeSinceLastKnown = now.timeIntervalSince(lastKnownTime)
        if timeSinceLastKnown > 3600 { // More than 1 hour has passed
            logger.info("💤 Detected potential sleep/wake scenario - \(Int(timeSinceLastKnown/3600)) hours have passed")
            logger.info("🚫 Skipping audio playback to avoid playing missed hours")
            lastKnownTime = now
            return
        }

        // Avoid playing the same hour multiple times
        if currentHour == lastPlayedHour {
            logger.info("⏭️ Skipping - already played hour \(currentHour)")
            return
        }

        lastPlayedHour = currentHour
        lastKnownTime = now

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

    private func setupSleepWakeNotifications() {
        // Listen for system sleep and wake notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil as Any?
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil as Any?
        )
        
        logger.info("💤 Sleep/wake notifications registered")
    }

    @objc private func systemWillSleep() {
        logger.info("💤 System is going to sleep")
        // Store the current time to detect sleep duration later
        lastKnownTime = Date()
    }

    @objc private func systemDidWake() {
        logger.info("🌅 System woke up from sleep")
        // Update the last known time and reschedule timer
        lastKnownTime = Date()

        // Reschedule the timer to ensure it's still accurate after wake
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.logger.info("🔄 Rescheduling timer after wake")
            self.start()
        }
    }

    private func sendNotification(for hour: Int, audioFile: AudioFile?) {
        let content = UNMutableNotificationContent()
        content.title = "Hourly Audio Player"

        // Format the hour for display in 12-hour format with AM/PM
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current

        // Create a date for the current hour to format it properly
        let calendar = Calendar.current
        let now = Date()

        // Create a date for the hour we're playing audio for
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = 0
        dateComponents.second = 0

        if let hourDate = calendar.date(from: dateComponents) {
            let formattedTime = formatter.string(from: hourDate)

            if let audioFile = audioFile {
                content.body = "Playing audio for \(formattedTime) - \(audioFile.name)"
            } else {
                content.body = "Playing system sound for \(formattedTime) (no custom audio set)"
            }
        } else {
            // Fallback to 24-hour format if date creation fails
            if let audioFile = audioFile {
                content.body = "Playing audio for \(hour):00 - \(audioFile.name)"
            } else {
                content.body = "Playing system sound for \(hour):00 (no custom audio set)"
            }
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

        // Format the hour for display in 12-hour format with AM/PM
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current

        let calendar = Calendar.current
        let now = Date()

        // Create a date for the hour we're playing audio for
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = 0
        dateComponents.second = 0

        let formattedTime: String
        if let hourDate = calendar.date(from: dateComponents) {
            formattedTime = formatter.string(from: hourDate)
        } else {
            formattedTime = "\(hour):00" // Fallback
        }

        content.body = "Could not play '\(audioFile.name)' for \(formattedTime). " +
                      "File may be missing, moved, or corrupted. Playing system sound instead."

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

    func getTimingInfo() -> String {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)

        let startOfCurrentHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: startOfCurrentHour)!
        let timeUntilNextHour = nextHour.timeIntervalSince(now)

        let minutes = Int(timeUntilNextHour / 60)
        let seconds = Int(timeUntilNextHour.truncatingRemainder(dividingBy: 60))
        let timeString = String(format: "%02d:%02d", currentMinute, currentSecond)

        return """
        Current Time: \(now)
        Current Hour: \(currentHour):\(timeString)
        Time Until Next Hour: \(minutes) minutes \(seconds) seconds
        Next Audio Time: \(nextHour)
        Timezone: \(TimeZone.current.identifier)
        """
    }

    #if DEBUG_MODE
    func testNotificationWithAudio() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        logger.info("🐛 DEBUG: Testing notification with audio for hour \(currentHour)")

        if let audioFile = audioFileManager.getAudioFile(for: currentHour) {
            logger.info(
                "🐛 DEBUG: Found audio file: \(audioFile.name) - " +
                "playing audio and sending notification"
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
