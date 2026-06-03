import Foundation
import os.log

protocol VersionInfoServiceProtocol: Sendable {
    func getMarketingVersion() async -> String
    func getBuildSuccessCount() async -> String
    func getBuildFailureCount() async -> String
    func refresh() async
}

/// Reads version and build counts from the running app's Info.plist on disk.
///
/// Values are updated by `scripts/version/manage_version.sh` during Xcode builds.
actor VersionInfoService: VersionInfoServiceProtocol {
    private let bundle: Bundle
    private let fileManager: FileManager
    private let infoPlistPathOverride: String?
    private let logger = Logger(subsystem: "club.cycleruncode.HourlyAudioPlayer", category: "VersionInfoService")

    private var cachedVersion: String?
    private var cachedSuccessCount: String?
    private var cachedFailureCount: String?
    private var cacheTimestamp: Date?
    private var cachedPlistPath: String?
    private var cachedContentHash: String?

    init(
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        infoPlistPathOverride: String? = nil
    ) {
        self.bundle = bundle
        self.fileManager = fileManager
        self.infoPlistPathOverride = infoPlistPathOverride
    }

    func getMarketingVersion() async -> String {
        if shouldInvalidateCache() { invalidateCache() }
        if let cached = cachedVersion { return cached }

        if let version = readPlistValue(key: "CFBundleShortVersionString"), !version.isEmpty {
            cachedVersion = version
            updateCacheTimestamp()
            return version
        }

        if let info = bundle.infoDictionary,
           let version = info["CFBundleShortVersionString"] as? String,
           !version.isEmpty {
            cachedVersion = version
            return version
        }

        let fallback = generateFallbackVersion()
        logger.warning("Using fallback version: \(fallback)")
        cachedVersion = fallback
        return fallback
    }

    func getBuildSuccessCount() async -> String {
        if shouldInvalidateCache() { invalidateCache() }
        if let cached = cachedSuccessCount { return cached }

        if let count = readPlistValue(key: "BuildSuccessCount"), !count.isEmpty {
            cachedSuccessCount = count
            updateCacheTimestamp()
            return count
        }

        if let info = bundle.infoDictionary,
           let count = info["BuildSuccessCount"] as? String,
           !count.isEmpty {
            cachedSuccessCount = count
            return count
        }

        let fallback = "0.00.000"
        cachedSuccessCount = fallback
        return fallback
    }

    func getBuildFailureCount() async -> String {
        if shouldInvalidateCache() { invalidateCache() }
        if let cached = cachedFailureCount { return cached }

        if let count = readPlistValue(key: "BuildFailureCount"), !count.isEmpty {
            cachedFailureCount = count
            updateCacheTimestamp()
            return count
        }

        if let info = bundle.infoDictionary,
           let count = info["BuildFailureCount"] as? String,
           !count.isEmpty {
            cachedFailureCount = count
            return count
        }

        let fallback = "0.00.000"
        cachedFailureCount = fallback
        return fallback
    }

    func refresh() async {
        invalidateCache()

        if infoPlistPathOverride == nil {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }

        _ = await getMarketingVersion()
        _ = await getBuildSuccessCount()
        _ = await getBuildFailureCount()
    }

    private func shouldInvalidateCache() -> Bool {
        let plistPath = resolveInfoPlistPath()

        if cachedPlistPath != plistPath { return true }
        guard let cacheTime = cacheTimestamp else { return true }

        if let currentHash = calculateContentHash(plistPath: plistPath),
           let cached = cachedContentHash,
           currentHash != cached {
            return true
        }

        guard let attributes = try? fileManager.attributesOfItem(atPath: plistPath),
              let modDate = attributes[.modificationDate] as? Date else {
            return true
        }

        return modDate.timeIntervalSince(cacheTime) > -1.0
    }

    private func invalidateCache() {
        cachedVersion = nil
        cachedSuccessCount = nil
        cachedFailureCount = nil
        cacheTimestamp = nil
        cachedPlistPath = nil
        cachedContentHash = nil
    }

    private func updateCacheTimestamp() {
        let path = resolveInfoPlistPath()
        if let attrs = try? fileManager.attributesOfItem(atPath: path),
           let modDate = attrs[.modificationDate] as? Date {
            cacheTimestamp = modDate
            cachedPlistPath = path
            cachedContentHash = calculateContentHash(plistPath: path)
        }
    }

    private func calculateContentHash(plistPath: String) -> String? {
        guard let plistData = NSDictionary(contentsOfFile: plistPath) else { return nil }
        let version = plistData["CFBundleShortVersionString"] as? String ?? ""
        let success = plistData["BuildSuccessCount"] as? String ?? ""
        let failure = plistData["BuildFailureCount"] as? String ?? ""
        return String("\(version)|\(success)|\(failure)".hashValue)
    }

    private func readPlistValue(key: String) -> String? {
        let path = resolveInfoPlistPath()
        guard fileManager.fileExists(atPath: path),
              let plist = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        return plist[key] as? String
    }

    private func resolveInfoPlistPath() -> String {
        if let override = infoPlistPathOverride { return override }

        if let path = resolveFromAppBundle() { return path }
        if let path = resolveFromDirectoryWalk() { return path }
        if let path = resolveFromDerivedData() { return path }
        if let path = resolveFromProjectSource() { return path }

        return "\(bundle.bundlePath)/Contents/Info.plist"
    }

    private func resolveFromAppBundle() -> String? {
        let bundleURL = bundle.bundleURL
        guard bundleURL.pathExtension == "app" else { return nil }
        let path = "\(bundleURL.path)/Contents/Info.plist"
        return fileManager.fileExists(atPath: path) ? path : nil
    }

    private func resolveFromDirectoryWalk() -> String? {
        var searchPath = bundle.bundlePath
        for _ in 0..<5 {
            if searchPath.hasSuffix(".app") {
                let path = "\(searchPath)/Contents/Info.plist"
                if fileManager.fileExists(atPath: path) { return path }
            }
            let parent = (searchPath as NSString).deletingLastPathComponent
            if parent == searchPath { break }
            searchPath = parent
        }
        return nil
    }

    private func resolveFromDerivedData() -> String? {
        guard let builtPath = findBuiltAppPath() else { return nil }
        let path = "\(builtPath)/Contents/Info.plist"
        return fileManager.fileExists(atPath: path) ? path : nil
    }

    private func resolveFromProjectSource() -> String? {
        guard let projectRoot = findProjectRoot() else { return nil }
        let sourcePath = "\(projectRoot)/src/Info.plist"
        guard fileManager.fileExists(atPath: sourcePath) else { return nil }
        logger.warning("Reading from source Info.plist — values may be stale until restart")
        return sourcePath
    }

    private func findBuiltAppPath() -> String? {
        let derivedData = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"
        guard fileManager.fileExists(atPath: derivedData) else { return nil }

        var candidates: [(path: String, modDate: Date)] = []

        guard let contents = try? fileManager.contentsOfDirectory(atPath: derivedData) else {
            return nil
        }

        for item in contents where item.contains("HourlyAudioPlayer-") {
            let base = "\(derivedData)/\(item)"
            let searchPaths = [
                "\(base)/Build/Products/Debug/HourlyAudioPlayer.app",
                "\(base)/Build/Products/Release/HourlyAudioPlayer.app"
            ]
            for appPath in searchPaths {
                let plist = "\(appPath)/Contents/Info.plist"
                guard fileManager.fileExists(atPath: plist) else { continue }
                let attrs = try? fileManager.attributesOfItem(atPath: plist)
                let modDate = attrs?[.modificationDate] as? Date ?? .distantPast
                candidates.append((path: appPath, modDate: modDate))
            }
        }

        return candidates.max(by: { $0.modDate < $1.modDate })?.path
    }

    private func findProjectRoot() -> String? {
        let markers = ["HourlyAudioPlayer.xcodeproj", ".git"]
        var searchPath = bundle.bundlePath

        if searchPath.hasSuffix(".app") {
            searchPath = (searchPath as NSString).deletingLastPathComponent
        }

        for _ in 0..<10 {
            for marker in markers where fileManager.fileExists(atPath: "\(searchPath)/\(marker)") {
                return searchPath
            }
            let parent = (searchPath as NSString).deletingLastPathComponent
            if parent == searchPath { break }
            searchPath = parent
        }

        return nil
    }

    private func generateFallbackVersion() -> String {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        return String(format: "%04d.%02d.%02d-01", year, month, day)
    }
}
