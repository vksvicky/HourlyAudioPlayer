import Foundation
import AVFoundation
import UniformTypeIdentifiers
import AppKit
import os.log

struct AudioFile: Identifiable, Codable {
    let id: UUID
    let name: String
    let url: URL
    let hour: Int

    init(name: String, url: URL, hour: Int) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.hour = hour
    }
}

class AudioFileManager: ObservableObject {
    static let shared = AudioFileManager()

    @Published var audioFiles: [Int: AudioFile] = [:]

    private let documentsDirectory: URL
    private let audioDirectory: URL
    private let userDefaults = UserDefaults.standard
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "AudioFileManager")

    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        audioDirectory = documentsDirectory.appendingPathComponent("HourlyAudioPlayer")

        createAudioDirectoryIfNeeded()
        loadAudioFiles()
    }

    private func createAudioDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: audioDirectory.path) {
            try? FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
        }
    }

    func importAudioFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType.audio,
            UTType.mp3,
            UTType.wav,
            UTType.mpeg4Audio,
            UTType.aiff
        ]

        if panel.runModal() == .OK {
            for url in panel.urls {
                importAudioFile(from: url)
            }
        }
    }

    func selectAudioFile(for hour: Int) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType.audio,
            UTType.mp3,
            UTType.wav,
            UTType.mpeg4Audio,
            UTType.aiff
        ]

        if panel.runModal() == .OK, let url = panel.url {
            importAudioFile(from: url, for: hour)
        }
    }

    private func importAudioFile(from sourceURL: URL, for hour: Int? = nil) {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = audioDirectory.appendingPathComponent(fileName)

        // Copy file to app's audio directory
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

            // If no specific hour is provided, try to extract from filename or use current hour
            let targetHour = hour ?? extractHourFromFilename(fileName) ?? Calendar.current.component(.hour, from: Date())

            let audioFile = AudioFile(name: fileName, url: destinationURL, hour: targetHour)
            audioFiles[targetHour] = audioFile

            saveAudioFiles()

        } catch {
            logger.error("Error importing audio file: \(error.localizedDescription)")
        }
    }

    private func extractHourFromFilename(_ filename: String) -> Int? {
        // Try to extract hour from filename patterns like "12hour.mp3", "12.mp3", etc.
        let patterns = [
            "([0-9]{1,2})hour",
            "([0-9]{1,2})\\.",
            "hour([0-9]{1,2})"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: filename.count)
                if let match = regex.firstMatch(in: filename, options: [], range: range) {
                    let hourString = (filename as NSString).substring(with: match.range(at: 1))
                    if let hour = Int(hourString), hour >= 0 && hour <= 23 {
                        return hour
                    }
                }
            }
        }

        return nil
    }

    func removeAudioFile(for hour: Int) {
        if let audioFile = audioFiles[hour] {
            // Remove the file from disk
            try? FileManager.default.removeItem(at: audioFile.url)

            // Remove from dictionary
            audioFiles.removeValue(forKey: hour)

            saveAudioFiles()
        }
    }

    private func saveAudioFiles() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(audioFiles) {
            userDefaults.set(data, forKey: "AudioFiles")
        }
    }

    private func loadAudioFiles() {
        if let data = userDefaults.data(forKey: "AudioFiles") {
            let decoder = JSONDecoder()
            if let loadedFiles = try? decoder.decode([Int: AudioFile].self, from: data) {
                // Verify that files still exist on disk
                var validFiles: [Int: AudioFile] = [:]
                for (hour, audioFile) in loadedFiles {
                    if FileManager.default.fileExists(atPath: audioFile.url.path) {
                        validFiles[hour] = audioFile
                    }
                }
                audioFiles = validFiles
                saveAudioFiles() // Update saved data to remove missing files
            }
        }
    }

    func getAudioFile(for hour: Int) -> AudioFile? {
        return audioFiles[hour]
    }
}
