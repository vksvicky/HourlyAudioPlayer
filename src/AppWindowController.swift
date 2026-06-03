import AppKit
import SwiftUI

/// Owns settings and about windows (avoids fragile menu-bar popovers).
final class AppWindowController: NSObject, NSWindowDelegate {
    static let shared = AppWindowController()

    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?

    private override init() {
        super.init()
    }

    var keyWindow: NSWindow? {
        if let settingsWindow, settingsWindow.isVisible { return settingsWindow }
        if let aboutWindow, aboutWindow.isVisible { return aboutWindow }
        return NSApp.mainWindow ?? NSApp.keyWindow
    }

    func openSettings() {
        if let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        if settingsWindow == nil {
            let controller = NSHostingController(rootView: ContentView())
            let window = NSWindow(contentViewController: controller)
            window.title = "Hourly Audio Player Settings"
            window.setContentSize(NSSize(width: 560, height: 680))
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func openAbout() {
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
        settingsWindow?.orderOut(nil)
        aboutWindow?.orderOut(nil)
    }
}
