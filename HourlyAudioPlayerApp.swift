import SwiftUI

@main
struct HourlyAudioPlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let statusButton = statusItem?.button {
            // Use the app's custom icon for the menu bar
            statusButton.image = NSImage(named: "AppIcon")
            statusButton.image?.size = NSSize(width: 18, height: 18)
            statusButton.image?.isTemplate = false
            statusButton.action = #selector(statusBarButtonClicked)
        }

        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())

        // Start the hourly timer
        HourlyTimer.shared.start()
    }

    @objc func statusBarButtonClicked() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                if let statusButton = statusItem?.button {
                    popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: NSRectEdge.minY)
                }
            }
        }
    }
}
