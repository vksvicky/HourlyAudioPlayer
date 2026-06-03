import AppKit
import os.log

/// Presents `NSOpenPanel` reliably from menu-bar apps and nested SwiftUI sheets.
enum FilePanelPresenter {
    private static let logger = Logger(
        subsystem: "club.cycleruncode.HourlyAudioPlayer",
        category: "FilePanelPresenter"
    )

    static func pickFiles(configure: (NSOpenPanel) -> Void) -> [URL] {
        NSApp.activate(ignoringOtherApps: true)

        let panel = NSOpenPanel()
        panel.canCreateDirectories = false
        configure(panel)

        logger.info("Showing open panel (app-modal)")
        let response = panel.runModal()
        logger.info("Open panel response: \(response.rawValue)")

        guard response == .OK else { return [] }
        return panel.urls
    }
}
