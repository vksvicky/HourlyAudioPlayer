import Foundation
import os.log

@MainActor
final class AboutViewModel: ObservableObject {
    @Published var currentVersion: String = ""
    @Published var currentSuccessCount: String = ""
    @Published var currentFailureCount: String = ""

    private let versionService: VersionInfoServiceProtocol
    private let logger = Logger(subsystem: "club.cycleruncode.HourlyAudioPlayer", category: "AboutViewModel")
    private var loadTask: Task<Void, Never>?

    init(versionService: VersionInfoServiceProtocol = VersionInfoService()) {
        self.versionService = versionService
        loadVersionInfo()
    }

    func loadVersionInfo() {
        loadTask?.cancel()

        loadTask = Task { @MainActor [weak self] in
            guard let self, !Task.isCancelled else { return }

            self.currentVersion = await self.versionService.getMarketingVersion()
            guard !Task.isCancelled else { return }

            self.currentSuccessCount = await self.versionService.getBuildSuccessCount()
            guard !Task.isCancelled else { return }

            self.currentFailureCount = await self.versionService.getBuildFailureCount()

            let version = self.currentVersion
            let success = self.currentSuccessCount
            let failure = self.currentFailureCount
            self.logger.debug("Loaded — Version: \(version), Success: \(success), Failure: \(failure)")
        }
    }

    func refreshVersionInfo() {
        loadTask?.cancel()

        loadTask = Task { @MainActor [weak self] in
            guard let self, !Task.isCancelled else { return }

            await self.versionService.refresh()
            guard !Task.isCancelled else { return }

            self.currentVersion = await self.versionService.getMarketingVersion()
            self.currentSuccessCount = await self.versionService.getBuildSuccessCount()
            self.currentFailureCount = await self.versionService.getBuildFailureCount()
        }
    }
}
