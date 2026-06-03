import Foundation
import SwiftUI

/// SF Symbols for scheduled app/file launches (macOS 12+).
enum LaunchScheduleIcons {
    static let folder = "folder.fill"
    static let file = "doc.fill"
    static let adjust = "plusminus"
    /// Settings footer — per-hour launch limit.
    static let limitSetting = "plusminus"
}

/// Fixed hour-card layout and SF Symbols for audio actions (macOS 12+).
enum HourSlotLayout {
    static let cardWidth: CGFloat = 120
    static let cardHeightWithLaunch: CGFloat = 192
    static let cardHeightWithoutLaunch: CGFloat = 148
    static let titleHeight: CGFloat = 18
    static let fileNameHeight: CGFloat = 14
    static let waveformHeight: CGFloat = 22
    static let volumeBlockHeight: CGFloat = 34
    static let actionRowHeight: CGFloat = 26
    static let launchBlockHeight: CGFloat = 40
}

enum HourSlotIcons {
    static let addAudio = "plus.circle.fill"
    static let preview = "play.fill"
    static let stopPreview = "stop.fill"
    static let removeAudio = "trash"
}

/// Folder + file with + / ± / count badges overlaid on the icon (not beside it).
struct LaunchItemIconView: View {
    let itemCount: Int
    var badgeLabel: String?
    var canAddMore: Bool = false

    private var isConfigured: Bool { itemCount > 0 }

    var body: some View {
        ZStack(alignment: .center) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: LaunchScheduleIcons.folder)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isConfigured ? .accentColor : Color(NSColor.secondaryLabelColor))

                Image(systemName: LaunchScheduleIcons.file)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isConfigured ? Color(NSColor.labelColor) : Color(NSColor.secondaryLabelColor))
                    .offset(x: 6, y: 1)
            }
            .frame(width: 28, height: 22)

            if let badgeLabel {
                Text(badgeLabel)
                    .font(.system(size: 9, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(NSColor.controlBackgroundColor)))
                    .overlay(Capsule().stroke(Color.accentColor.opacity(0.35), lineWidth: 1))
                    .offset(x: 14, y: -12)
            }

            HStack(spacing: 3) {
                if !isConfigured || canAddMore {
                    iconBadge(systemName: "plus", style: .action)
                }
                if isConfigured {
                    iconBadge(systemName: LaunchScheduleIcons.adjust, style: .neutral)
                }
            }
            .offset(x: 12, y: 11)
        }
        .frame(width: 44, height: 32)
        .fixedSize()
    }

    private enum BadgeStyle {
        case action
        case neutral
    }

    @ViewBuilder
    private func iconBadge(systemName: String, style: BadgeStyle) -> some View {
        let isAction = style == .action
        Image(systemName: systemName)
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(isAction ? .white : Color(NSColor.labelColor))
            .padding(4)
            .background(Circle().fill(isAction ? Color.accentColor : Color(NSColor.controlBackgroundColor)))
            .overlay(Circle().stroke(Color(NSColor.separatorColor), lineWidth: isAction ? 0 : 0.5))
    }
}
