import SwiftUI

struct MenuBarView: View {
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var hourlyTimer = HourlyTimer.shared
    @State private var showingSettings = false
    @State private var showingAbout = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "speaker.wave.2")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("Hourly Audio Player")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
                
                Button(action: {
                    // Close the popover by sending a close action
                    NSApp.sendAction(Selector(("performClose:")), to: nil, from: nil)
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
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

                Button("Test Current Hour") {
                    hourlyTimer.playCurrentHourAudio()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .keyboardShortcut("t", modifiers: .command)

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
        .sheet(isPresented: $showingSettings) {
            ContentView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutWindow()
        }
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    private var nextAudioString: String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let nextHour = (currentHour + 1) % 24

        if let audioFile = audioFileManager.audioFiles[nextHour] {
            return "\(nextHour):00 - \(audioFile.name)"
        } else {
            return "\(nextHour):00 - No audio set"
        }
    }
}

#Preview {
    MenuBarView()
}
