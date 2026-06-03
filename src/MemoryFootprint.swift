import Foundation
import os.log

#if canImport(Darwin)
import Darwin
#endif

/// Reads this process resident memory size (macOS).
enum MemoryFootprint {
    static func residentSizeBytes() -> UInt64? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size
        )
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        return info.resident_size
    }

    static func residentSizeMegabytes() -> Double? {
        guard let bytes = residentSizeBytes() else { return nil }
        return Double(bytes) / 1_048_576.0
    }

    static func formattedResidentSize() -> String {
        guard let megabytes = residentSizeMegabytes() else { return "unknown" }
        return String(format: "%.1f MB", megabytes)
    }

    /// Asks the allocator to return freed pages to the system (RSS may drop slowly or not at all on Debug builds).
    static func encourageReturnOfFreedMemory() {
        #if canImport(Darwin)
        malloc_zone_pressure_relief(nil, 0)
        #endif
    }
}

/// Periodic resident-memory logging for long-run observation (developer builds).
final class MemoryFootprintMonitor {
    static let shared = MemoryFootprintMonitor()

    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "MemoryFootprint")
    private var timer: Timer?
    private let interval: TimeInterval

    init(interval: TimeInterval = 60) {
        self.interval = interval
    }

    static func startIfEnabled() {
        guard LaunchScheduleSettings.showLaunchTestControls(from: .main) else { return }
        shared.start()
    }

    func start() {
        stop()
        logCurrent(label: "start")
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.logCurrent(label: "sample")
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func logCurrent(label: String) {
        let memory = MemoryFootprint.formattedResidentSize()
        let waveformEntries = AudioWaveformCache.shared.entryCount
        logger.info("[\(label)] resident=\(memory) waveformCacheEntries=\(waveformEntries)")
    }
}
