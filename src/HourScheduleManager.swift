import Foundation
import AppKit
import UniformTypeIdentifiers
import os.log

enum ScheduledLaunchKind: String, Codable {
    case application
    case file
}

struct ScheduledLaunchItem: Identifiable, Codable, Equatable {
    let id: UUID
    var displayName: String
    var bookmarkData: Data
    var kind: ScheduledLaunchKind
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        displayName: String,
        bookmarkData: Data,
        kind: ScheduledLaunchKind,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.bookmarkData = bookmarkData
        self.kind = kind
        self.isEnabled = isEnabled
    }
}

protocol WorkspaceLaunching {
    func open(_ url: URL) -> Bool
}

struct SystemWorkspaceLauncher: WorkspaceLaunching {
    func open(_ url: URL) -> Bool {
        NSWorkspace.shared.open(url)
    }
}

class HourScheduleManager: ObservableObject {
    static let shared = HourScheduleManager()

    /// Names used only by unit tests — removed on load if they polluted standard defaults.
    static let testFixtureDisplayNames: Set<String> = [
        "launch-a.txt",
        "launch-b.txt",
        "launch-keep.txt",
        "launch-drop.txt",
        "launch-clear.txt",
    ]

    /// Multiple apps or files per hour.
    @Published var hourLaunchItems: [Int: [ScheduledLaunchItem]] = [:]

    private let userDefaults: UserDefaults
    private let storageKey = "ScheduledLaunchesV2"
    private let legacyStorageKey = "ScheduledLaunches"
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "HourScheduleManager")
    private let workspace: WorkspaceLaunching

    init(
        userDefaults: UserDefaults = .standard,
        workspace: WorkspaceLaunching = SystemWorkspaceLauncher()
    ) {
        self.userDefaults = userDefaults
        self.workspace = workspace
        loadScheduledLaunches()
        pruneTestFixtureItemsIfNeeded()
        applyPerHourLimit()
    }

    func launchItems(for hour: Int) -> [ScheduledLaunchItem] {
        hourLaunchItems[hour] ?? []
    }

    var maxLaunchItemsPerHour: Int {
        LaunchScheduleSettings.shared.maxItemsPerHour
    }

    func remainingLaunchSlots(for hour: Int) -> Int {
        guard LaunchScheduleSettings.shared.launchesEnabled else { return 0 }
        return max(0, maxLaunchItemsPerHour - launchItems(for: hour).count)
    }

    func canAddLaunchItems(for hour: Int) -> Bool {
        remainingLaunchSlots(for: hour) > 0
    }

    /// Trims stored items when the user lowers the per-hour limit (or sets it to 0).
    func applyPerHourLimit() {
        let limit = maxLaunchItemsPerHour
        if limit == 0 {
            guard !hourLaunchItems.isEmpty else { return }
            hourLaunchItems.removeAll()
            saveScheduledLaunches()
            logger.info("Cleared all launch items (per-hour limit set to 0)")
            return
        }

        var changed = false
        for hour in Array(hourLaunchItems.keys) {
            guard var items = hourLaunchItems[hour], items.count > limit else { continue }
            hourLaunchItems[hour] = Array(items.prefix(limit))
            changed = true
        }
        if changed {
            saveScheduledLaunches()
            logger.info("Trimmed launch items to per-hour limit of \(limit)")
        }
    }

    func setItemEnabled(for hour: Int, itemID: UUID, enabled: Bool) {
        guard var items = hourLaunchItems[hour],
              let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].isEnabled = enabled
        hourLaunchItems[hour] = items
        saveScheduledLaunches()
    }

    func removeLaunchItem(for hour: Int, itemID: UUID) {
        guard var items = hourLaunchItems[hour] else { return }
        items.removeAll { $0.id == itemID }
        if items.isEmpty {
            hourLaunchItems.removeValue(forKey: hour)
        } else {
            hourLaunchItems[hour] = items
        }
        saveScheduledLaunches()
        logger.info("Removed launch item for hour \(hour)")
    }

    func clearAllLaunchItems(for hour: Int) {
        hourLaunchItems.removeValue(forKey: hour)
        saveScheduledLaunches()
        logger.info("Cleared all launch items for hour \(hour)")
    }

    func addScheduledLaunches(for hour: Int) {
        guard LaunchScheduleSettings.shared.launchesEnabled else {
            logger.info("Scheduled launches disabled (per-hour limit is 0)")
            return
        }
        guard canAddLaunchItems(for: hour) else {
            logger.info("Launch limit reached for hour \(hour)")
            return
        }

        logger.info("Adding scheduled launch item(s) for hour \(hour)")

        let urls = FilePanelPresenter.pickFiles { panel in
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedContentTypes = [.application, .item, .data, .content]
            panel.prompt = "Add"
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
        }

        guard !urls.isEmpty else {
            logger.info("No launch items selected for hour \(hour)")
            return
        }

        for url in urls {
            guard canAddLaunchItems(for: hour) else { break }
            importScheduledLaunch(from: url, for: hour)
        }
    }

    func importScheduledLaunch(from url: URL, for hour: Int) {
        do {
            let bookmark = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            let kind: ScheduledLaunchKind = url.pathExtension.lowercased() == "app" || url.path.hasSuffix(".app")
                ? .application
                : .file
            let item = ScheduledLaunchItem(
                displayName: url.lastPathComponent,
                bookmarkData: bookmark,
                kind: kind,
                isEnabled: true
            )
            var items = hourLaunchItems[hour] ?? []
            if let existingIndex = items.firstIndex(where: { $0.displayName == item.displayName }) {
                items[existingIndex] = item
            } else {
                let limit = maxLaunchItemsPerHour
                guard items.count < limit else {
                    logger.warning("Per-hour launch limit (\(limit)) reached for hour \(hour)")
                    return
                }
                items.append(item)
            }
            hourLaunchItems[hour] = items
            saveScheduledLaunches()
            logger.info("Added launch item for hour \(hour): \(item.displayName)")
        } catch {
            logger.error("Failed to create security bookmark: \(error.localizedDescription)")
        }
    }

    struct ScheduledLaunchRunResult: Equatable {
        let openedCount: Int
        let attemptedCount: Int
        let failedNames: [String]
    }

    func launchTestMessage(for result: ScheduledLaunchRunResult, hour: Int) -> String {
        let label = String(format: "%02d:00", hour)
        if result.attemptedCount == 0 {
            return "No enabled launches for \(label). Turn items On in the launch editor, or add apps with the folder icon."
        }
        if result.failedNames.isEmpty {
            return "Opened all \(result.openedCount) item(s) for \(label)."
        }
        return "Opened \(result.openedCount) of \(result.attemptedCount) for \(label). Failed: \(result.failedNames.joined(separator: ", ")). Re-add those apps if needed."
    }

    @discardableResult
    func executeScheduledLaunches(for hour: Int) -> ScheduledLaunchRunResult {
        let items = launchItems(for: hour).filter(\.isEnabled)
        guard !items.isEmpty else {
            return ScheduledLaunchRunResult(openedCount: 0, attemptedCount: 0, failedNames: [])
        }

        var openedCount = 0
        var failedNames: [String] = []
        for (index, item) in items.enumerated() {
            if index > 0 {
                pauseBetweenLaunches()
            }
            if openLaunchItem(item, hour: hour) {
                openedCount += 1
            } else {
                failedNames.append(item.displayName)
            }
        }

        if openedCount > 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .hourlyPlayerDidLaunchExternalItem, object: nil)
            }
        }

        return ScheduledLaunchRunResult(
            openedCount: openedCount,
            attemptedCount: items.count,
            failedNames: failedNames
        )
    }

    func scheduledLaunchSummary(for hour: Int) -> String {
        let items = launchItems(for: hour)
        guard !items.isEmpty else { return "None" }

        let enabledCount = items.filter(\.isEnabled).count
        if items.count == 1, let only = items.first {
            return "\(only.displayName) (\(only.isEnabled ? "On" : "Off"))"
        }
        return "\(enabledCount)/\(items.count) items"
    }

    func launchIcon(for item: ScheduledLaunchItem) -> NSImage? {
        guard let url = resolvedURL(for: item) else { return nil }
        return NSWorkspace.shared.icon(forFile: url.path)
    }

    private func pauseBetweenLaunches() {
        let interval: TimeInterval = 0.4
        guard Thread.isMainThread else {
            Thread.sleep(forTimeInterval: interval)
            return
        }
        let until = Date().addingTimeInterval(interval)
        while Date() < until {
            RunLoop.current.run(mode: .default, before: until)
        }
    }

    private func openLaunchItem(_ item: ScheduledLaunchItem, hour: Int) -> Bool {
        guard let resolved = resolvedURL(for: item) else {
            logger.error("Could not resolve bookmark for \(item.displayName) at hour \(hour)")
            return false
        }

        var isStale = false
        if (try? URL(
            resolvingBookmarkData: item.bookmarkData,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )) != nil, isStale {
            logger.warning("Security bookmark is stale for \(item.displayName)")
        }

        let accessed = resolved.startAccessingSecurityScopedResource()

        let opened: Bool
        if item.kind == .application {
            opened = openApplication(at: resolved, displayName: item.displayName, hour: hour, releaseSecurityScope: accessed)
        } else {
            opened = workspace.open(resolved)
            if accessed {
                resolved.stopAccessingSecurityScopedResource()
            }
            if opened {
                logger.info("Opened file \(item.displayName) for hour \(hour)")
            } else {
                logger.warning("Failed to open file \(item.displayName) for hour \(hour)")
            }
        }
        return opened
    }

    private func openApplication(
        at url: URL,
        displayName: String,
        hour: Int,
        releaseSecurityScope: Bool
    ) -> Bool {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = false

        var completed = false
        var success = false

        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                self.logger.warning("Failed to launch \(displayName) for hour \(hour): \(error.localizedDescription)")
                success = false
            } else {
                self.logger.info("Launched \(displayName) for hour \(hour)")
                success = true
            }
            if releaseSecurityScope {
                url.stopAccessingSecurityScopedResource()
            }
            completed = true
        }

        if Thread.isMainThread {
            let timeout = Date().addingTimeInterval(15)
            while !completed, Date() < timeout {
                RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
            }
        } else {
            while !completed {
                Thread.sleep(forTimeInterval: 0.05)
            }
        }

        return success
    }

    private func resolvedURL(for item: ScheduledLaunchItem) -> URL? {
        var isStale = false
        return try? URL(
            resolvingBookmarkData: item.bookmarkData,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }

    private func saveScheduledLaunches() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(hourLaunchItems) {
            userDefaults.set(data, forKey: storageKey)
            userDefaults.removeObject(forKey: legacyStorageKey)
        }
    }

    private func loadScheduledLaunches() {
        let decoder = JSONDecoder()

        if let data = userDefaults.data(forKey: storageKey),
           let loaded = try? decoder.decode([Int: [ScheduledLaunchItem]].self, from: data) {
            hourLaunchItems = loaded
            return
        }

        if let data = userDefaults.data(forKey: legacyStorageKey),
           let legacy = try? decoder.decode([Int: ScheduledLaunchItem].self, from: data) {
            hourLaunchItems = legacy.mapValues { [$0] }
            saveScheduledLaunches()
            logger.info("Migrated legacy single launch items to multi-item format")
        }
    }

    private func pruneTestFixtureItemsIfNeeded() {
        var changed = false
        for hour in Array(hourLaunchItems.keys) {
            guard var items = hourLaunchItems[hour] else { continue }
            let filtered = items.filter { !Self.testFixtureDisplayNames.contains($0.displayName) }
            if filtered.count != items.count {
                changed = true
                items = filtered
                if items.isEmpty {
                    hourLaunchItems.removeValue(forKey: hour)
                } else {
                    hourLaunchItems[hour] = items
                }
            }
        }
        if changed {
            saveScheduledLaunches()
            logger.info("Removed unit-test launch fixtures from saved schedule")
        }
    }
}
