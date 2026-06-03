import SwiftUI
import AppKit
import os.log

extension Notification.Name {
    static let hourlyPlayerDidLaunchExternalItem = Notification.Name("HourlyPlayerDidLaunchExternalItem")
}

@main
struct HourlyAudioPlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Placeholder only — real settings use AppWindowController (one window, no duplicate on ⌘,).
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Hourly Audio Player Settings…") {
                    AppWindowController.shared.openSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "AppDelegate")

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        installStatusItem()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExternalLaunch),
            name: .hourlyPlayerDidLaunchExternalItem,
            object: nil
        )

        HourlyTimer.shared.start()
        MemoryFootprintMonitor.startIfEnabled()
    }

    func closePopover() {
        // Kept for callers after removing NSPopover; closes auxiliary windows only.
        AppWindowController.shared.closeAuxiliaryWindows()
    }

    @objc private func handleExternalLaunch() {
        // Close settings/about if open; do not recreate the status item (that caused FBSScene noise).
        AppWindowController.shared.closeAuxiliaryWindows()
        refreshStatusItemMenuIfNeeded()
    }

    private func installStatusItem() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            guard let button = statusItem?.button else {
                logger.error("Failed to create status bar button")
                return
            }
            button.image = NSImage(named: "AppIcon")
            button.image?.size = NSSize(width: 18, height: 18)
            button.image?.isTemplate = false
            logger.debug("Status item created")
        }
        statusItem?.menu = makeStatusItemMenu()
    }

    /// Reattach menu without removing the status item (avoids Control Center scene-invalidated log spam).
    private func refreshStatusItemMenuIfNeeded() {
        guard statusItem != nil else {
            installStatusItem()
            return
        }
        statusItem?.menu = makeStatusItemMenu()
    }

    private func makeStatusItemMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let settingsItem = NSMenuItem(
            title: "Open Settings…",
            action: #selector(openSettingsWindow),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let aboutItem = NSMenuItem(
            title: "About…",
            action: #selector(openAboutWindow),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApplication),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func openSettingsWindow() {
        AppWindowController.shared.openSettings()
    }

    @objc private func openAboutWindow() {
        AppWindowController.shared.openAbout()
    }

    @objc private func quitApplication() {
        NSApp.terminate(nil)
    }
}
