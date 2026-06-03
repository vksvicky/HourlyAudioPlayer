import Combine
import Foundation

/// User preference for how many apps/files may open per hour (0–5, default 1).
final class LaunchScheduleSettings: ObservableObject {
    static let shared = LaunchScheduleSettings()

    /// Info.plist key; omit or set false to hide manual launch-test UI (default).
    static let showLaunchTestUIInfoKey = "ShowLaunchTestUI"
    /// Common typo (lowercase “l” instead of “I”) — accepted so Xcode edits still work.
    private static let showLaunchTestUIInfoKeyTypo = "ShowLaunchTestUl"

    static let minimumLimit = 0
    static let maximumLimit = 5
    static let defaultLimit = 1

    private let storageKey = "maxLaunchItemsPerHour"
    private let userDefaults: UserDefaults

    @Published private(set) var maxItemsPerHour: Int

    /// Read once from Info.plist. Missing key or false → hidden. Not stored in UserDefaults.
    let showLaunchTestControls: Bool

    init(userDefaults: UserDefaults = .standard, bundle: Bundle = .main) {
        self.userDefaults = userDefaults
        let stored = userDefaults.integer(forKey: storageKey)
        if userDefaults.object(forKey: storageKey) == nil {
            maxItemsPerHour = Self.defaultLimit
        } else {
            maxItemsPerHour = Self.clamp(stored)
        }
        showLaunchTestControls = Self.showLaunchTestControls(from: bundle)
    }

    static func showLaunchTestControls(from bundle: Bundle) -> Bool {
        for key in [showLaunchTestUIInfoKey, showLaunchTestUIInfoKeyTypo] {
            if let value = bundle.object(forInfoDictionaryKey: key) {
                return parseShowLaunchTestFlag(value)
            }
        }
        return false
    }

    static func parseShowLaunchTestFlag(_ value: Any?) -> Bool {
        guard let value else { return false }
        if let flag = value as? Bool {
            return flag
        }
        if let number = value as? NSNumber {
            return number.boolValue
        }
        if let text = value as? String {
            switch text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "yes", "true", "1":
                return true
            default:
                return false
            }
        }
        return false
    }

    static func clamp(_ value: Int) -> Int {
        min(maximumLimit, max(minimumLimit, value))
    }

    func setMaxItemsPerHour(_ value: Int) {
        let clamped = Self.clamp(value)
        guard clamped != maxItemsPerHour else { return }
        maxItemsPerHour = clamped
        userDefaults.set(clamped, forKey: storageKey)
        HourScheduleManager.shared.applyPerHourLimit()
    }

    var launchesEnabled: Bool {
        maxItemsPerHour > 0
    }
}
