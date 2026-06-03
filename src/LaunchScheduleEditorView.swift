import SwiftUI
import AppKit

struct LaunchScheduleEditorView: View {
    let hour: Int
    @ObservedObject private var hourScheduleManager = HourScheduleManager.shared
    @ObservedObject private var launchSettings = LaunchScheduleSettings.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showTestResult = false
    @State private var testResultMessage = ""

    private var items: [ScheduledLaunchItem] {
        hourScheduleManager.launchItems(for: hour)
    }

    private var maxPerHour: Int {
        launchSettings.maxItemsPerHour
    }

    private var remainingSlots: Int {
        hourScheduleManager.remainingLaunchSlots(for: hour)
    }

    private var hasEnabledItems: Bool {
        items.contains(where: \.isEnabled)
    }

    private var showLaunchTestControls: Bool {
        LaunchScheduleSettings.showLaunchTestControls(from: .main)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Launch schedule for \(String(format: "%02d:00", hour))")
                        .font(.headline)

                    Text("Add apps or files to open at this hour (\(items.count)/\(maxPerHour), up to \(maxPerHour) allowed).")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if showLaunchTestControls {
                        Text("Test launches now (developer) opens enabled items without waiting for the clock.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if items.isEmpty {
                        Text("No items configured.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        List {
                            ForEach(items) { item in
                                launchRow(item)
                            }
                        }
                        .frame(minHeight: 120, maxHeight: 220)
                    }

                    HStack {
                        Button("Add app or file…") {
                            DispatchQueue.main.async {
                                hourScheduleManager.addScheduledLaunches(for: hour)
                            }
                        }
                        .disabled(remainingSlots == 0)

                        Spacer()

                        if !items.isEmpty {
                            Button("Clear all") {
                                hourScheduleManager.clearAllLaunchItems(for: hour)
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                .padding(20)
            }
            .frame(maxHeight: showLaunchTestControls ? 340 : 380)
            .layoutPriority(0)

            editorFooter
                .layoutPriority(1)
        }
        .frame(width: 420, height: showLaunchTestControls ? 440 : 400)
        .alert("Launch test", isPresented: $showTestResult) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(testResultMessage)
        }
    }

    @ViewBuilder
    private var editorFooter: some View {
        Divider()

        if showLaunchTestControls {
            HStack(spacing: 10) {
                Button("Test launches now") {
                    runLaunchTest()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasEnabledItems)
                .help("Developer: opens each enabled app or file for this hour immediately.")

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        } else {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func runLaunchTest() {
        let result = hourScheduleManager.executeScheduledLaunches(for: hour)
        testResultMessage = hourScheduleManager.launchTestMessage(for: result, hour: hour)
        showTestResult = true
    }

    @ViewBuilder
    private func launchRow(_ item: ScheduledLaunchItem) -> some View {
        HStack(spacing: 10) {
            launchIcon(for: item)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .lineLimit(2)
                Text(item.kind == .application ? "Application" : "File")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("On", isOn: Binding(
                get: { item.isEnabled },
                set: { hourScheduleManager.setItemEnabled(for: hour, itemID: item.id, enabled: $0) }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()

            Button("Remove") {
                hourScheduleManager.removeLaunchItem(for: hour, itemID: item.id)
            }
            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func launchIcon(for item: ScheduledLaunchItem) -> some View {
        if let icon = hourScheduleManager.launchIcon(for: item) {
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: item.kind == .application ? "app.fill" : "doc.fill")
                .foregroundColor(.secondary)
        }
    }
}
