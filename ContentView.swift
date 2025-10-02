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

                Spacer()

                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                })
                .buttonStyle(.plain)
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
                Button("Import Audio Files") {
                    audioFileManager.importAudioFiles()
                }
                .buttonStyle(.borderedProminent)

                Spacer()

                Button("Test Current Hour") {
                    hourlyTimer.playCurrentHourAudio()
                }
                .buttonStyle(.bordered)

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
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

            if let audioFile = audioFileManager.audioFiles[hour] {
                VStack(spacing: 4) {
                    Text(audioFile.name)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Button("Remove") {
                        audioFileManager.removeAudioFile(for: hour)
                    }
                    .font(.caption2)
                    .foregroundColor(.red)
                }
            } else {
                Button("Add Audio") {
                    audioFileManager.selectAudioFile(for: hour)
                }
                .font(.caption)
                .foregroundColor(.blue)
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
