import AppKit
import SwiftUI
import os.log

/// Owns settings and about windows (avoids fragile menu-bar popovers).
final class AppWindowController: NSObject, NSWindowDelegate {
    static let shared = AppWindowController()

    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "AppWindowController")

    private var settingsWindow: NSWindow?
    private var settingsHostingController: NSHostingController<ContentView>?
    private var aboutWindow: NSWindow?

    private(set) var isSettingsWindowOpen = false

    private override init() {
        super.init()
    }

    var keyWindow: NSWindow? {
        if let settingsWindow, settingsWindow.isVisible { return settingsWindow }
        if let aboutWindow, aboutWindow.isVisible { return aboutWindow }
        return NSApp.mainWindow ?? NSApp.keyWindow
    }

    func openSettings() {
        DispatchQueue.main.async { [weak self] in
            self?.presentSettings()
        }
    }

    private func presentSettings() {
        if settingsHostingController != nil, let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 560, height: 720),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Hourly Audio Player Settings"
            window.delegate = self
            window.isReleasedWhenClosed = true
            settingsWindow = window
        }

        replaceSettingsContent()

        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        logMemory(label: "settings-opened")
    }

    func openAbout() {
        DispatchQueue.main.async { [weak self] in
            self?.presentAbout()
        }
    }

    private func presentAbout() {
        if aboutWindow == nil {
            let controller = NSHostingController(rootView: AboutWindow())
            let window = NSWindow(contentViewController: controller)
            window.title = "About Hourly Audio Player"
            window.setContentSize(NSSize(width: 360, height: 420))
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.delegate = self
            aboutWindow = window
        } else {
            resetAboutContent()
        }

        aboutWindow?.center()
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Intercept the red close button — hide and release content instead of closing the window.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard sender === settingsWindow else { return true }
        DispatchQueue.main.async { [weak self] in
            self?.dismissSettingsWindow()
        }
        return false
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow, window === aboutWindow else { return }
        resetAboutContent()
    }

    private func resetAboutContent() {
        guard let controller = aboutWindow?.contentViewController as? NSHostingController<AboutWindow> else {
            return
        }
        controller.rootView = AboutWindow()
    }

    func closeAuxiliaryWindows() {
        aboutWindow?.orderOut(nil)
        DispatchQueue.main.async { [weak self] in
            self?.dismissSettingsWindow()
        }
    }

    /// Hides settings, releases the SwiftUI grid, then destroys the window shell on the next run-loop turn.
    private func dismissSettingsWindow() {
        guard isSettingsWindowOpen || settingsHostingController != nil || settingsWindow != nil else { return }

        releaseSettingsState()

        guard let window = settingsWindow else {
            detachSettingsContentFromWindow()
            logSettingsReleased()
            return
        }

        window.orderOut(nil)
        detachSettingsContentFromWindow()
        window.delegate = nil
        settingsWindow = nil

        // Close only after hide + detach — avoids `_NSWindowTransformAnimation` crashes while reclaiming RAM.
        DispatchQueue.main.async {
            window.animationBehavior = .none
            window.close()
            MemoryFootprint.encourageReturnOfFreedMemory()
        }

        logSettingsReleased()
    }

    private func logSettingsReleased() {
        MemoryFootprint.encourageReturnOfFreedMemory()
        logMemory(label: "settings-released")
        schedulePostReleaseMemoryLogs()
    }

    private func replaceSettingsContent() {
        releaseSettingsState()
        detachSettingsContentFromWindow()

        let controller = NSHostingController(rootView: ContentView())
        settingsHostingController = controller
        settingsWindow?.contentViewController = controller
        isSettingsWindowOpen = true
    }

    private func releaseSettingsState() {
        guard isSettingsWindowOpen || settingsHostingController != nil else { return }

        isSettingsWindowOpen = false
        AudioFileManager.shared.stopPreview()
        AudioWaveformCache.shared.removeAll()
    }

    private func detachSettingsContentFromWindow() {
        autoreleasepool {
            settingsHostingController = nil
            settingsWindow?.contentViewController = nil
        }
    }

    private func schedulePostReleaseMemoryLogs() {
        MemoryFootprint.encourageReturnOfFreedMemory()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.logMemory(label: "settings-released+1s")
            MemoryFootprint.encourageReturnOfFreedMemory()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.logMemory(label: "settings-released+5s")
            MemoryFootprint.encourageReturnOfFreedMemory()
        }
    }

    private func logMemory(label: String) {
        let memory = MemoryFootprint.formattedResidentSize()
        let waveforms = AudioWaveformCache.shared.entryCount
        logger.info("[\(label)] resident=\(memory) waveformCacheEntries=\(waveforms)")
        MemoryFootprintMonitor.shared.logCurrent(label: label)
    }
}
