import SwiftUI
import os.log

struct MenuBarView: View {
    private let logger = Logger(subsystem: "com.example.HourlyAudioPlayer", category: "MenuBarView")
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var hourlyTimer = HourlyTimer.shared
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var currentTime = Date()
    @State private var timeUpdateTimer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                Text("Hourly Audio Player")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    logger.debug("Close button tapped")
                    // Try multiple approaches to close the popover
                    
                    // Approach 1: Direct popover close
                    if let appDelegate = NSApp.delegate as? AppDelegate,
                       let popover = appDelegate.popover {
                        logger.debug("Closing via direct popover reference")
                        popover.performClose(nil)
                        return
                    }
                    
                    // Approach 2: Find popover in windows
                    for window in NSApp.windows {
                        if let popover = window as? NSPopover {
                            logger.debug("Closing popover found in NSApp.windows")
                            popover.performClose(nil)
                            return
                        }
                    }
                    
                    // Approach 3: Close current window
                    if let currentWindow = NSApp.keyWindow {
                        logger.debug("Closing current key window")
                        currentWindow.close()
                        return
                    }
                    
                    // Approach 4: Use status bar button method
                    if let appDelegate = NSApp.delegate as? AppDelegate {
                        logger.debug("Closing via statusBarButtonClicked()")
                        appDelegate.statusBarButtonClicked()
                    } else {
                        logger.error("App delegate not found; cannot close popover")
                    }
                }, label: {
                    Text("×")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                })
                .buttonStyle(.plain)
                .help("Close")
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current Time:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(currentTimeString)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Next Audio:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(nextAudioString)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Divider()

            VStack(spacing: 8) {
                Button("Open Settings") {
                    showingSettings = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .keyboardShortcut("s", modifiers: .command)

                    #if DEBUG_MODE
                    Button("Test Current Hour") {
                        hourlyTimer.playCurrentHourAudio()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .keyboardShortcut("t", modifiers: .command)
                    #endif

                Button("About") {
                    showingAbout = true
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .keyboardShortcut("a", modifiers: .command)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(width: 300)
        .background(Color.white)
        .sheet(isPresented: $showingSettings) {
            ContentView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutWindow()
        }
        .onAppear {
            startTimeUpdateTimer()
        }
        .onDisappear {
            stopTimeUpdateTimer()
        }
    }

    private func startTimeUpdateTimer() {
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }

    private func stopTimeUpdateTimer() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: currentTime)
    }

    private var nextAudioString: String {
        let currentHour = Calendar.current.component(.hour, from: currentTime)
        let nextHour = (currentHour + 1) % 24

        let displayName = audioFileManager.getAudioDisplayName(for: nextHour)
        return "\(nextHour):00 - \(displayName)"
    }
}

#Preview {
    MenuBarView()
}
