import SwiftUI

struct AboutWindow: View {
    @Environment(\.dismiss) private var dismiss
    
    private var aboutPanelOptions: [String: Any] {
        Bundle.main.object(forInfoDictionaryKey: "NSAboutPanelOptions") as? [String: Any] ?? [:]
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Close button in top-right corner
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                })
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.top, -10)
            .padding(.trailing, -10)
            // App Icon
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .shadow(radius: 2)
            
            // App Name
            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Hourly Audio Player")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.primary)
            
            // Version Information
            Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A") (Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"))")
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

#Preview {
    AboutWindow()
}
