import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var hourScheduleManager = HourScheduleManager.shared
    @StateObject private var hourlyTimer = HourlyTimer.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var launchSettings = LaunchScheduleSettings.shared
    @StateObject private var hourColourStore = HourClockColourStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Hourly Audio Player")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)

            Text("Configure audio, volume, and scheduled apps or files for each hour")
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

            hourColourSettingsSection

            if launchSettings.showLaunchTestControls {
                Text("Developer: click a hour’s launch icon (folder + file) to open Test launches now.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
            }

            HStack(alignment: .center, spacing: 8) {
                // Theme Toggle on the left
                Image(systemName: themeManager.themeIcon)
                    .foregroundColor(.secondary)
                    .frame(width: 16, height: 16)

                Text("Theme:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Theme", selection: $themeManager.isDarkMode) {
                    Text("Light").tag(false)
                    Text("Dark").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 100, height: 24)
                .onChange(of: themeManager.isDarkMode) { _ in
                    // Force refresh when theme changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        themeManager.forceRefresh()
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: LaunchScheduleIcons.limitSetting)
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                    Text("Max launches/hour:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper(
                        value: Binding(
                            get: { launchSettings.maxItemsPerHour },
                            set: { launchSettings.setMaxItemsPerHour($0) }
                        ),
                        in: LaunchScheduleSettings.minimumLimit...LaunchScheduleSettings.maximumLimit
                    ) {
                        Text("\(launchSettings.maxItemsPerHour)")
                            .font(.caption)
                            .monospacedDigit()
                            .frame(width: 14, alignment: .trailing)
                    }
                    .frame(width: 120)
                }
                .help("How many apps or files may open at each hour (0–5). Default is 1.")

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
            .frame(height: 40)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(width: 560, height: 720)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var hourColourSettingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Colour hours by clock", isOn: $hourColourStore.isEnabled)
                .font(.caption)
                .help("Grade each hour slot from past → now → future using the system clock.")

            if hourColourStore.isEnabled {
                HStack(spacing: 16) {
                    hourColourPicker(label: "Past", colour: $hourColourStore.pastColour)
                    hourColourPicker(label: "Now", colour: $hourColourStore.currentHourColour)
                    hourColourPicker(label: "Future", colour: $hourColourStore.futureColour)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private func hourColourPicker(label: String, colour: Binding<HourRGBColour>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            ColorPicker(
                "",
                selection: Binding(
                    get: { colour.wrappedValue.swiftUIColor },
                    set: { colour.wrappedValue = HourRGBColour(swiftUIColor: $0) }
                ),
                supportsOpacity: false
            )
            .labelsHidden()
            .frame(width: 44, height: 28)
        }
    }
}

struct HourSlotView: View {
    let hour: Int
    @ObservedObject private var audioFileManager = AudioFileManager.shared
    @ObservedObject private var hourScheduleManager = HourScheduleManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var launchSettings = LaunchScheduleSettings.shared
    @ObservedObject private var hourColourStore = HourClockColourStore.shared

    private var hasSpecificAudio: Bool {
        audioFileManager.audioFiles[hour] != nil
    }

    @State private var showingLaunchEditor = false

    private var launchItems: [ScheduledLaunchItem] {
        hourScheduleManager.launchItems(for: hour)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(String(format: "%02d:00", hour))
                .font(.headline)
                .fontWeight(.semibold)

            let displayName = audioFileManager.getAudioDisplayName(for: hour)
            Text(displayName)
                .font(.caption2)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .foregroundColor(hasSpecificAudio ? .primary : .secondary)

            if hasSpecificAudio {
                VStack(spacing: 2) {
                    Text("Volume")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Slider(
                        value: Binding(
                            get: { Double(audioFileManager.volume(for: hour)) },
                            set: { audioFileManager.setVolume(for: hour, volume: Float($0)) }
                        ),
                        in: 0...1
                    )
                    .controlSize(.mini)
                }
                .frame(maxWidth: .infinity)
                Button("Remove audio") {
                    audioFileManager.removeAudioFile(for: hour)
                }
                .font(.caption2)
                .foregroundColor(.red)
            } else {
                Button("Add audio") {
                    audioFileManager.selectAudioFile(for: hour)
                }
                .font(.caption2)
                .foregroundColor(.blue)
            }

            if launchSettings.launchesEnabled {
                Divider()

                launchSection
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .frame(width: 120, alignment: .top)
        .fixedSize(horizontal: true, vertical: true)
        .background(slotBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(slotBorderColour, lineWidth: hourColourStore.isCurrentHour(hour) ? 2 : 1)
        )
        .sheet(isPresented: $showingLaunchEditor) {
            LaunchScheduleEditorView(hour: hour)
        }
    }

    private var launchSection: some View {
        Button {
            showingLaunchEditor = true
        } label: {
            LaunchItemIconView(
                itemCount: launchItems.count,
                badgeLabel: launchItems.isEmpty ? nil : launchBadgeLabel,
                canAddMore: !launchItems.isEmpty && hourScheduleManager.canAddLaunchItems(for: hour)
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .help(
            launchItems.isEmpty
                ? "Click to add apps or files for this hour"
                : "Manage scheduled launches (\(launchBadgeLabel))"
        )
    }

    private var slotBackground: Color {
        if let graded = hourColourStore.colour(forHour: hour) {
            return graded.swiftUIColor.opacity(themeManager.isDarkMode ? 0.55 : 0.4)
        }
        return themeManager.isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }

    private var slotBorderColour: Color {
        if hourColourStore.isCurrentHour(hour) {
            return Color.accentColor
        }
        return themeManager.isDarkMode ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)
    }

    private var launchBadgeLabel: String {
        let items = launchItems
        let limit = launchSettings.maxItemsPerHour
        let enabled = items.filter(\.isEnabled).count
        return "\(enabled)/\(limit)"
    }
}

#Preview {
    ContentView()
}
