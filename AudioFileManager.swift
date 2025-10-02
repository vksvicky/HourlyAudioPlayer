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

    private var lastSelectedDirectory: URL? {
        get {
            if let data = userDefaults.data(forKey: "LastSelectedDirectory"),
               let url = URL(dataRepresentation: data, relativeTo: nil) {
                return url
            }
            return FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first
        }
        set {
            if let url = newValue {
                userDefaults.set(url.dataRepresentation, forKey: "LastSelectedDirectory")
            }
        }
    }

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


    func selectAudioFile(for hour: Int) {
        logger.info("🎵 Select Audio File for hour \(hour) clicked")

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

        // Set the default directory
        if let defaultDirectory = lastSelectedDirectory {
            panel.directoryURL = defaultDirectory
            logger.info("📁 Setting default directory to: \(defaultDirectory.path)")
        }

        panel.canCreateDirectories = false

        logger.info("🔍 Opening file selection panel for hour \(hour)...")
        
        // Find the main window and present as sheet
        if let mainWindow = findMainWindow() {
            panel.beginSheetModal(for: mainWindow) { [self] response in
                self.logger.info("📋 Panel response: \(response.rawValue)")
                
                if response == .OK, let url = panel.url {
                    self.logger.info("✅ File selected: \(url.lastPathComponent)")

                    // Save the selected directory for next time
                    self.lastSelectedDirectory = url.deletingLastPathComponent()
                    self.logger.info("💾 Saved directory for next time: \(self.lastSelectedDirectory?.path ?? "nil")")

                    self.importAudioFile(from: url, for: hour)
                } else {
                    self.logger.info("❌ File selection cancelled")
                }
            }
        } else {
            // Fallback to modal if no main window
            panel.level = .modalPanel
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            
            let response = panel.runModal()
            logger.info("📋 Panel response: \(response.rawValue)")

            if response == .OK, let url = panel.url {
                logger.info("✅ File selected: \(url.lastPathComponent)")

                // Save the selected directory for next time
                lastSelectedDirectory = url.deletingLastPathComponent()
                logger.info("💾 Saved directory for next time: \(self.lastSelectedDirectory?.path ?? "nil")")

                importAudioFile(from: url, for: hour)
            } else {
                logger.info("❌ File selection cancelled")
            }
        }
    }

    private func importAudioFile(from sourceURL: URL, for hour: Int? = nil) {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = audioDirectory.appendingPathComponent(fileName)

        // Validate file before importing
        if let validationError = validateAudioFile(at: sourceURL) {
            showValidationAlert(error: validationError, fileName: fileName)
            return
        }

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

            logger.info("✅ Successfully imported audio file: \(fileName)")

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
    
    // MARK: - Window Management
    
    private func findMainWindow() -> NSWindow? {
        // First try to find the main app window
        if let mainWindow = NSApp.mainWindow {
            logger.info("🔍 Found main window: \(mainWindow.title)")
            return mainWindow
        }
        
        // If no main window, look for any visible window with our app's title
        for window in NSApp.windows {
            if window.isVisible && (window.title.contains("Hourly Audio Player") || window.title.contains("Settings")) {
                logger.info("🔍 Found app window: \(window.title)")
                return window
            }
        }
        
        // Last resort: find any visible window
        for window in NSApp.windows {
            if window.isVisible {
                logger.info("🔍 Using fallback window: \(window.title)")
                return window
            }
        }
        
        logger.warning("⚠️ No suitable window found for sheet presentation")
        return nil
    }
    
    // MARK: - Audio Display Logic
    
    func getAudioDisplayName(for hour: Int) -> String {
        // Check if there's a specific audio file for this hour
        if let specificAudio = audioFiles[hour] {
            return specificAudio.name
        }
        
        // If no specific audio for this hour, always show "macOS Default"
        // This ensures that when an audio is removed, it shows "macOS Default" instead of
        // showing another audio file's name
        return "macOS Default"
    }
 
    // MARK: - File Validation

    private func validateAudioFile(at url: URL) -> ValidationError? {
        // Check file size (2.5MB = 2.5 * 1024 * 1024 bytes)
        let maxFileSize: Int64 = 2_621_440 // 2.5MB in bytes

        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? Int64 {
                if fileSize > maxFileSize {
                    let fileSizeMB = Double(fileSize) / (1024 * 1024)
                    return .fileTooLarge(size: fileSizeMB)
                }
            }
        } catch {
            logger.error("Error checking file size: \(error.localizedDescription)")
            return .fileAccessError
        }
        
        // Check file format
        let pathExtension = url.pathExtension.lowercased()
        let supportedFormats = ["mp3", "wav", "m4a", "aiff", "aac", "flac", "ogg"]
        
        if !supportedFormats.contains(pathExtension) {
            return .unsupportedFormat(format: pathExtension)
        }

        return nil
    }

    private func showValidationAlert(error: ValidationError, fileName: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Audio File Validation Failed"
            
            switch error {
            case .fileTooLarge(let size):
                alert.informativeText = "The file '\(fileName)' is too large (\(String(format: "%.1f", size)) MB).\n\nMaximum allowed size is 2.5 MB.\n\nPlease use a smaller audio file or compress the current one."
            case .unsupportedFormat(let format):
                alert.informativeText = "The file '\(fileName)' has an unsupported format (.\(format)).\n\nSupported formats: MP3, WAV, M4A, AIFF, AAC, FLAC, OGG\n\nPlease convert the file to a supported format."
            case .fileAccessError:
                alert.informativeText = "Unable to access the file '\(fileName)'.\n\nPlease make sure the file exists and you have permission to read it."
            }
            
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        
        logger.warning("⚠️ Audio file validation failed for '\(fileName)': \(error)")
    }
}

// MARK: - Validation Error Types

enum ValidationError: Error, CustomStringConvertible {
    case fileTooLarge(size: Double)
    case unsupportedFormat(format: String)
    case fileAccessError
    
    var description: String {
        switch self {
        case .fileTooLarge(let size):
            return "File too large: \(String(format: "%.1f", size)) MB (max: 2.5 MB)"
        case .unsupportedFormat(let format):
            return "Unsupported format: .\(format)"
        case .fileAccessError:
            return "File access error"
        }
    }
}
