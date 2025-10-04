import SwiftUI

struct AboutWindow: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @State private var iconClickCount = 0
    @State private var showPongGame = false
    @State private var currentTransition: AnyTransition = .scale.combined(with: .opacity)

    private var aboutPanelOptions: [String: Any] {
        Bundle.main.object(forInfoDictionaryKey: "NSAboutPanelOptions") as? [String: Any] ?? [:]
    }

    var body: some View {
        if showPongGame {
            PongGameView(onBackToAbout: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showPongGame = false
                    iconClickCount = 0 // Reset counter when returning
                }
            })
            .transition(currentTransition)
        } else {
            VStack(spacing: 14) {
            // Close button in top-right corner
            HStack {
                Spacer()
                Text("×")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                    .onTapGesture {
                        dismiss()
                    }
                    .help("Close")
            }
            .padding(.top, -10)
            .padding(.trailing, -10)
            // App Icon
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .shadow(radius: 2)
                .onTapGesture {
                    iconClickCount += 1
                    if iconClickCount >= 6 {
                        playRandomTransition()
                    }
                }

            // App Name
            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Hourly Audio Player")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.primary)

            // Version Information
            Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A") " +
                 "(Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"))")
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(.primary)

            // Copyright Information
            Text(Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? "Copyright © 2025 CycleRunCode. All rights reserved.")
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Contact Information
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                    Link(aboutPanelOptions["NSApplicationWebsite"] as? String ?? "https://cycleruncode.club",
                         destination: URL(string: aboutPanelOptions["NSApplicationWebsite"] as? String ?? "https://cycleruncode.club")!)
                        .foregroundColor(.blue)
                }

                HStack(spacing: 4) {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                    Link(aboutPanelOptions["NSApplicationSupportEmail"] as? String ?? "support@cycleruncode.club",
                         destination: URL(string: "mailto:\(aboutPanelOptions["NSApplicationSupportEmail"] as? String ?? "support@cycleruncode.club")")!)
                        .foregroundColor(.blue)
                }
            }
            .font(.system(size: 12, weight: .regular, design: .default))
            .padding(.top, 8)
            }
            .padding(30)
            .frame(width: 320, height: 380)
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    private func playRandomTransition() {
        let transitions: [AnyTransition] = [
            // Scale and opacity combinations
            .scale.combined(with: .opacity),
            .scale(scale: 0.1).combined(with: .opacity),
            .scale(scale: 2.0).combined(with: .opacity),
            
            // Slide transitions
            .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ),
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ),
            .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            ),
            .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ),
            
            // Scale variations
            .asymmetric(
                insertion: .scale(scale: 0.5).combined(with: .opacity),
                removal: .scale(scale: 1.5).combined(with: .opacity)
            ),
            .asymmetric(
                insertion: .scale(scale: 1.5).combined(with: .opacity),
                removal: .scale(scale: 0.5).combined(with: .opacity)
            ),
            .asymmetric(
                insertion: .scale(scale: 0.3).combined(with: .opacity),
                removal: .scale(scale: 2.0).combined(with: .opacity)
            ),
            .asymmetric(
                insertion: .scale(scale: 2.0).combined(with: .opacity),
                removal: .scale(scale: 0.3).combined(with: .opacity)
            ),
            
            // Simple opacity fade
            .opacity,
            
            // Identity (no transition)
            .identity,
            
            // More scale combinations
            .scale.combined(with: .opacity).combined(with: .move(edge: .leading)),
            .scale.combined(with: .opacity).combined(with: .move(edge: .trailing)),
            .scale.combined(with: .opacity).combined(with: .move(edge: .top)),
            .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
        ]
        
        // Select a random transition
        currentTransition = transitions.randomElement() ?? .scale.combined(with: .opacity)
        
        // Play the transition with a random duration
        let duration = Double.random(in: 0.6...1.2)
        withAnimation(.easeInOut(duration: duration)) {
            showPongGame = true
        }
    }
}

#Preview {
    AboutWindow()
}
