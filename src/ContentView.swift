import SwiftUI

struct ContentView: View {
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var hourlyTimer = HourlyTimer.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Hourly Audio Player")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 8)

                Spacer()

                Text("×")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.trailing, 18)
                    .padding(.top, 6)
                    .onTapGesture {
                        dismiss()
                    }
                    .help("Close Settings")
            }

            Text("Configure audio files for each hour of the day")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(0..<24, id: \.self) { hour in
                        HourSlotView(hour: hour)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()

                #if DEBUG_MODE
                Button("🐛 Test Notification") {
                    hourlyTimer.testNotificationWithAudio()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                #endif

                #if DEBUG_MODE
                Button("Test Current Hour") {
                    hourlyTimer.playCurrentHourAudio()
                }
                .buttonStyle(.bordered)
                #endif

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .background(Color.white)
    }
}

struct HourSlotView: View {
    let hour: Int
    @StateObject private var audioFileManager = AudioFileManager.shared

    var body: some View {
        VStack(spacing: 8) {
            Text("\(hour):00")
                .font(.headline)
                .fontWeight(.semibold)

            let displayName = audioFileManager.getAudioDisplayName(for: hour)
            let hasSpecificAudio = audioFileManager.audioFiles[hour] != nil
            
            VStack(spacing: 4) {
                Text(displayName)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hasSpecificAudio ? .primary : .secondary)

                if hasSpecificAudio {
                    Button("Remove") {
                        audioFileManager.removeAudioFile(for: hour)
                    }
                    .font(.caption2)
                    .foregroundColor(.red)
                } else {
                    Button("Add Audio") {
                        audioFileManager.selectAudioFile(for: hour)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .frame(width: 100, height: 80)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
