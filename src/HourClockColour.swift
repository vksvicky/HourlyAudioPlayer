import AppKit
import SwiftUI

/// RGB components in 0...1 for hour-slot grading.
struct HourRGBColour: Equatable, Codable {
    var red: Double
    var green: Double
    var blue: Double

    init(red: Double, green: Double, blue: Double) {
        self.red = Self.clamp(red)
        self.green = Self.clamp(green)
        self.blue = Self.clamp(blue)
    }

    static func lerp(_ from: HourRGBColour, _ to: HourRGBColour, t: Double) -> HourRGBColour {
        let amount = clamp(t)
        return HourRGBColour(
            red: from.red + (to.red - from.red) * amount,
            green: from.green + (to.green - from.green) * amount,
            blue: from.blue + (to.blue - from.blue) * amount
        )
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }

    init(swiftUIColor: Color) {
        let converted = NSColor(swiftUIColor).usingColorSpace(.deviceRGB) ?? NSColor.gray
        self.init(red: Double(converted.redComponent), green: Double(converted.greenComponent), blue: Double(converted.blueComponent))
    }

    private static func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}

/// Maps each hour on the 24-hour clock to a graded colour from past → now → future.
enum HourClockColourGrading {
    /// Shortest signed offset on a 24-hour dial (−12...12).
    static func signedHourOffset(hour: Int, currentHour: Int) -> Int {
        var diff = hour - currentHour
        if diff > 12 { diff -= 24 }
        if diff < -12 { diff += 24 }
        return diff
    }

    static func colour(
        forHour hour: Int,
        currentHour: Int,
        past: HourRGBColour,
        current: HourRGBColour,
        future: HourRGBColour
    ) -> HourRGBColour {
        let offset = signedHourOffset(hour: hour, currentHour: currentHour)
        if offset == 0 { return current }

        let blend = Double(abs(offset)) / 12.0
        if offset < 0 {
            return HourRGBColour.lerp(past, current, t: 1.0 - blend)
        }
        return HourRGBColour.lerp(current, future, t: blend)
    }
}

/// Persists user hour colours to a property list in Application Support.
final class HourClockColourStore: ObservableObject {
    static let shared = HourClockColourStore()
    static let plistFileName = "HourClockColours.plist"

    private enum PlistKey {
        static let isEnabled = "HourColourGradingEnabled"
        static let pastRed = "PastRed"
        static let pastGreen = "PastGreen"
        static let pastBlue = "PastBlue"
        static let currentRed = "CurrentRed"
        static let currentGreen = "CurrentGreen"
        static let currentBlue = "CurrentBlue"
        static let futureRed = "FutureRed"
        static let futureGreen = "FutureGreen"
        static let futureBlue = "FutureBlue"
    }

    @Published var isEnabled: Bool {
        didSet { guard !isLoading else { return }; save() }
    }

    @Published var pastColour: HourRGBColour {
        didSet { guard !isLoading else { return }; save() }
    }

    @Published var currentHourColour: HourRGBColour {
        didSet { guard !isLoading else { return }; save() }
    }

    @Published var futureColour: HourRGBColour {
        didSet { guard !isLoading else { return }; save() }
    }

    @Published private(set) var systemHour: Int

    private let plistURL: URL
    private var refreshTimer: Timer?
    private var isLoading = false

    init(plistURL: URL? = nil) {
        let resolvedURL = plistURL ?? Self.defaultPlistURL()
        self.plistURL = resolvedURL
        self.isEnabled = false
        self.pastColour = HourRGBColour(red: 0.72, green: 0.76, blue: 0.82)
        self.currentHourColour = HourRGBColour(red: 0.18, green: 0.62, blue: 0.45)
        self.futureColour = HourRGBColour(red: 0.78, green: 0.72, blue: 0.92)
        self.systemHour = Calendar.current.component(.hour, from: Date())
        load()
        startClockRefresh()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    static func defaultPlistURL() -> URL {
        let bundleID = Bundle.main.bundleIdentifier ?? "club.cycleruncode.HourlyAudioPlayer"
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = support.appendingPathComponent(bundleID, isDirectory: true)
        return directory.appendingPathComponent(plistFileName)
    }

    func colour(forHour hour: Int) -> HourRGBColour? {
        guard isEnabled else { return nil }
        return HourClockColourGrading.colour(
            forHour: hour,
            currentHour: systemHour,
            past: pastColour,
            current: currentHourColour,
            future: futureColour
        )
    }

    func isCurrentHour(_ hour: Int) -> Bool {
        isEnabled && hour == systemHour
    }

    func refreshSystemHour(from date: Date = Date()) {
        let hour = Calendar.current.component(.hour, from: date)
        guard hour != systemHour else { return }
        systemHour = hour
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        guard FileManager.default.fileExists(atPath: plistURL.path),
              let data = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return }

        if let enabled = plist[PlistKey.isEnabled] as? Bool {
            isEnabled = enabled
        }
        if let past = Self.readColour(from: plist, prefix: "Past") {
            pastColour = past
        }
        if let current = Self.readColour(from: plist, prefix: "Current") {
            currentHourColour = current
        }
        if let future = Self.readColour(from: plist, prefix: "Future") {
            futureColour = future
        }
    }

    func save() {
        let directory = plistURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let plist: [String: Any] = [
            PlistKey.isEnabled: isEnabled,
            PlistKey.pastRed: pastColour.red,
            PlistKey.pastGreen: pastColour.green,
            PlistKey.pastBlue: pastColour.blue,
            PlistKey.currentRed: currentHourColour.red,
            PlistKey.currentGreen: currentHourColour.green,
            PlistKey.currentBlue: currentHourColour.blue,
            PlistKey.futureRed: futureColour.red,
            PlistKey.futureGreen: futureColour.green,
            PlistKey.futureBlue: futureColour.blue,
        ]

        guard let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) else {
            return
        }
        try? data.write(to: plistURL, options: .atomic)
    }

    private static func readColour(from plist: [String: Any], prefix: String) -> HourRGBColour? {
        guard let red = plist["\(prefix)Red"] as? Double,
              let green = plist["\(prefix)Green"] as? Double,
              let blue = plist["\(prefix)Blue"] as? Double
        else { return nil }
        return HourRGBColour(red: red, green: green, blue: blue)
    }

    private func startClockRefresh() {
        refreshTimer?.invalidate()
        refreshSystemHour()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshSystemHour()
            }
        }
    }
}
